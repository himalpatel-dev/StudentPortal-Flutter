import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_portal/models/tournament.dart';
import 'package:student_portal/models/fixture.dart';
import 'package:student_portal/models/student.dart';
import 'package:student_portal/utils/api_constants.dart';

class TournamentProvider with ChangeNotifier {
  List<Tournament> _myTournaments = [];
  List<Tournament> _upcomingTournaments = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _totalTournaments = 0;
  List<Fixture> _fixtureDetails = [];
  bool _isFixtureLoading = false;
  String? _participantSlipUrl;

  List<Tournament> get myTournaments => _myTournaments;
  List<Tournament> get upcomingTournaments => _upcomingTournaments;
  bool get isLoading => _isLoading;
  bool get isFixtureLoading => _isFixtureLoading;
  String? get errorMessage => _errorMessage;
  int get totalTournaments => _totalTournaments;
  List<Fixture> get fixtureDetails => _fixtureDetails;
  String? get participantSlipUrl => _participantSlipUrl;

  Future<void> fetchTournaments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString('studentId') ?? '1';

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

  Future<void> fetchFixtureDetails(String tournamentId) async {
    _isFixtureLoading = true;
    _fixtureDetails = [];
    _participantSlipUrl = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString('studentId') ?? '124';
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
          _participantSlipUrl = data['data']['participant_slip'];
          if (data['data']['fixtures'] != null) {
            final List fixturesJson = data['data']['fixtures'];
            _fixtureDetails = fixturesJson
                .map((json) => Fixture.fromJson(json))
                .toList();
          }
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
  }

  int? _calculateTournamentAge(String dob, String cutoffDate) {
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

          final effectivePI = studentPI > 0 ? studentPI : (studentHeight + studentWeight);

          for (final cat in categories) {
            final matchGender = studentGender == (cat['gender']?.toString().toUpperCase());
            if (!matchGender) continue;

            final minAge = parseMin(cat['minimum_age']);
            final maxAge = parseMax(cat['maximum_age']);
            if (studentAge < minAge || studentAge > maxAge) continue;

            final catName = cat['category_division_name']?.toString() ?? '';
            final isUnder16 = RegExp(r'U-(\d+)', caseSensitive: false).hasMatch(catName);
            
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

          return {
            'match': exactMatch,
            'categories': filteredCategories,
          };
        }
      }
    } catch (e) {
      // Ignore error
    }
    return null;
  }
}
