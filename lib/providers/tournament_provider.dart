import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stradia_ace/models/tournament.dart';
import 'package:stradia_ace/models/fixture.dart';
import 'package:stradia_ace/models/student.dart';
import 'package:stradia_ace/utils/api_constants.dart';

class TournamentProvider with ChangeNotifier {
  List<Tournament> _myTournaments = [];
  List<Tournament> _upcomingTournaments = [];
  List<Tournament> _completedTournaments = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _totalTournaments = 0;
  List<Fixture> _fixtureDetails = [];
  bool _isFixtureLoading = false;
  String? _participantSlipUrl;
  Tournament? _tournamentRecap;
  bool _isRecapLoading = false;

  bool _isApplying = false;
  String? _lastFetchedFixtureTournamentId;
  Map<String, dynamic>? _lastFixtureResponse;
  
  List<Tournament> get myTournaments => _myTournaments;
  List<Tournament> get upcomingTournaments => _upcomingTournaments;
  List<Tournament> get completedTournaments => _completedTournaments;
  bool get isLoading => _isLoading;
  bool get isApplying => _isApplying;
  String? get lastFetchedFixtureTournamentId => _lastFetchedFixtureTournamentId;
  bool get isFixtureLoading => _isFixtureLoading;
  String? get errorMessage => _errorMessage;
  int get totalTournaments => _totalTournaments;
  List<Fixture> get fixtureDetails => _fixtureDetails;
  String? get participantSlipUrl => _participantSlipUrl;
  Tournament? get tournamentRecap => _tournamentRecap;
  bool get isRecapLoading => _isRecapLoading;

  Future<void> fetchTournaments({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString('studentId');

      if (studentId == null) {
        _errorMessage = 'Session expired. Please login again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final token = prefs.getString('authToken');

      final url = Uri.parse(
        '${ApiConstants.kudoUrl}/api/tournament/getTournamentsByPlayerId?player_id=$studentId',
      );
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tournamentData = data['data'];

        if (tournamentData != null) {
          _totalTournaments = tournamentData['total_tournaments'] ?? 0;

          // Parse My Tournaments
          final myTournamentsList = tournamentData['my_tournaments'] as List?;
          if (myTournamentsList != null) {
            _myTournaments = myTournamentsList
                .map((json) => Tournament.fromJson(json))
                .toList();

            // Sort: IN_PROGRESS -> SCHEDULED -> COMPLETED
            _myTournaments.sort((a, b) {
              int getStatusWeight(String status) {
                switch (status) {
                  case 'IN_PROGRESS':
                    return 1;
                  case 'SCHEDULED':
                    return 2;
                  case 'COMPLETED':
                    return 3;
                  default:
                    return 4;
                }
              }

              return getStatusWeight(
                a.tournamentStatus,
              ).compareTo(getStatusWeight(b.tournamentStatus));
            });
          } else {
            _myTournaments = [];
          }

          // Parse Upcoming Tournaments
          final upcomingTournamentsList =
              tournamentData['upcoming_tournaments'] as List?;
          if (upcomingTournamentsList != null) {
            _upcomingTournaments = upcomingTournamentsList
                .map((json) => Tournament.fromJson(json))
                .toList();
          } else {
            _upcomingTournaments = [];
          }

          // Parse Completed Tournaments
          final completedTournamentsList =
              tournamentData['completed_tournaments'] as List?;
          if (completedTournamentsList != null) {
            _completedTournaments = completedTournamentsList
                .map((json) => Tournament.fromJson(json))
                .toList();
          } else {
            _completedTournaments = [];
          }
        }
      } else {
        _errorMessage =
            'Failed to load tournaments. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error fetching tournaments: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> fetchFixtureDetails(String tournamentId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _lastFetchedFixtureTournamentId == tournamentId && _lastFixtureResponse != null) {
      return _lastFixtureResponse;
    }

    _isFixtureLoading = true;
    _fixtureDetails = [];
    _participantSlipUrl = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString('studentId');

      if (studentId == null) {
        _errorMessage = 'Session expired. Please login again.';
        _isFixtureLoading = false;
        notifyListeners();
        return null;
      }
      final token = prefs.getString('authToken');

      final url = Uri.parse(
        '${ApiConstants.kudoUrl}/api/tournament/get-by-id?id=$studentId&tournament_id=$tournamentId',
      );

      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          _lastFetchedFixtureTournamentId = tournamentId;
          _lastFixtureResponse = data['data'];
          _participantSlipUrl = data['data']['participant_slip'];
          if (data['data']['fixtures'] != null) {
            final List fixturesJson = data['data']['fixtures'];
            _fixtureDetails = fixturesJson
                .map((json) => Fixture.fromJson(json))
                .toList();
          }
          return data['data'];
        }
      } else {
        _errorMessage = 'Failed to load fixture details';
      }
    } catch (e) {
      _errorMessage = 'Error fetching fixtures: $e';
    } finally {
      _isFixtureLoading = false;
      notifyListeners();
    }
    return null;
  }

  int? _calculateTournamentAge(String dob, String cutoffDate) {
    if (dob.isEmpty || cutoffDate.isEmpty) return null;
    try {
      final birthDate = DateTime.parse(dob);
      final cutoff = DateTime.parse(cutoffDate);
      int age = cutoff.year - birthDate.year;
      if (cutoff.month < birthDate.month ||
          (cutoff.month == birthDate.month && cutoff.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> findMatchingCategory(
    String tournamentId,
    Student student,
    Tournament tournament,
  ) async {
    _isApplying = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      final url = Uri.parse(
        '${ApiConstants.kudoUrl}/api/tournament/getCategoriesByTournamentId/$tournamentId',
      );
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final table = data['Table'];
        if (table != null && table['Tournament_Category_Model'] != null) {
          final List categories = table['Tournament_Category_Model'];
          if (categories.isEmpty) return {'categories': [], 'match': null};

          final studentHeight = double.tryParse(student.height) ?? 0.0;
          final studentWeight = double.tryParse(student.weight) ?? 0.0;
          final studentPI = double.tryParse(student.physicalIndex) ?? 0.0;

          int studentAge = student.age;
          if (student.dob.isNotEmpty && tournament.ageCutoffDate.isNotEmpty) {
            studentAge =
                _calculateTournamentAge(
                  student.dob,
                  tournament.ageCutoffDate,
                ) ??
                studentAge;
          }
          final studentGender = student.gender.toUpperCase();

          final List filteredCategories = [];
          Map<String, dynamic>? exactMatch;

          double parseMin(dynamic val) {
            final v = double.tryParse(val?.toString() ?? '');
            if (v == null || v == 0.0) return 0.0;
            return v;
          }

          double parseMax(dynamic val) {
            final v = double.tryParse(val?.toString() ?? '');
            if (v == null || v == 0.0) return double.infinity;
            return v;
          }

          final effectivePI =
              studentPI > 0 ? studentPI : (studentHeight + studentWeight);

          for (final cat in categories) {
            final matchGender =
                studentGender == (cat['gender']?.toString().toUpperCase());
            if (!matchGender) continue;

            final minAge = parseMin(cat['minimum_age']);
            final maxAge = parseMax(cat['maximum_age']);
            if (studentAge < minAge || studentAge > maxAge) continue;

            final catName = cat['category_division_name']?.toString() ?? '';
            final isUnder16 = RegExp(
              r'U-(\d+)',
              caseSensitive: false,
            ).hasMatch(catName);

            bool isEligibleForFilter = false;
            bool isExactMatch = false;

            if (isUnder16) {
              final maxWeight = parseMax(cat['maximum_weight']);
              if (studentWeight <= maxWeight) {
                isEligibleForFilter = true;
                final minWeight = parseMin(cat['minimum_weight']);
                if (studentWeight >= minWeight) {
                  isExactMatch = true;
                }
              }
            } else {
              final maxPI = parseMax(cat['maximum_PI_index']);
              if (effectivePI <= maxPI) {
                isEligibleForFilter = true;
                final minPI = parseMin(cat['minimum_PI_index']);
                if (effectivePI >= minPI) {
                  isExactMatch = true;
                }
              }
            }

            if (isEligibleForFilter) {
              filteredCategories.add(cat);
              if (isExactMatch && exactMatch == null) {
                exactMatch = cat as Map<String, dynamic>;
              }
            }
          }

          return {'match': exactMatch, 'categories': filteredCategories};
        }
      }
    } catch (e) {
      _errorMessage = 'Error in findMatchingCategory: $e';
    } finally {
      _isApplying = false;
      notifyListeners();
    }
    return null;
  }

  Future<bool> applyToTournament({
    required int tournamentId,
    required int studentId,
    required int categoryId,
  }) async {
    _isApplying = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      final url = Uri.parse(
        '${ApiConstants.kudoUrl}/api/tournament/add-students-to-tournament',
      );
      final body = json.encode([
        {
          "tournament_id": tournamentId,
          "student_id": studentId,
          "category_id": categoryId,
        },
      ]);

      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Trigger silent refresh in background without awaiting it
        // This ensures the loader stops immediately after application
        fetchTournaments(silent: true);
        return true;
      } else {
        final data = json.decode(response.body);
        _errorMessage = data['message'] ?? 'Failed to apply to tournament';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error applying to tournament: $e';
      return false;
    } finally {
      _isApplying = false;
      notifyListeners();
    }
  }

  Future<void> fetchTournamentRecap(String tournamentId) async {
    _isRecapLoading = true;
    _tournamentRecap = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString('studentId');

      if (studentId == null) {
        _errorMessage = 'Session expired. Please login again.';
        _isRecapLoading = false;
        notifyListeners();
        return;
      }
      final token = prefs.getString('authToken');

      final url = Uri.parse(
        '${ApiConstants.kudoUrl}/api/tournament/getCompletedTournamentsByPlayerId?player_id=$studentId&tournament_id=$tournamentId',
      );

      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && (data['data'] as List).isNotEmpty) {
          // The API returns a list, we take the first matching tournament recap
          _tournamentRecap = Tournament.fromJson(data['data'][0]);
        }
      } else {
        _errorMessage = 'Failed to load tournament recap details';
      }
    } catch (e) {
      _errorMessage = 'Error fetching recap: $e';
    } finally {
      _isRecapLoading = false;
      notifyListeners();
    }
  }
}
