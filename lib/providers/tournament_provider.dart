import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_portal/models/tournament.dart';
import 'package:student_portal/models/fixture.dart';
import 'package:student_portal/utils/api_constants.dart';

class TournamentProvider with ChangeNotifier {
  List<Tournament> _myTournaments = [];
  List<Tournament> _upcomingTournaments = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _totalTournaments = 0;
  List<Fixture> _fixtureDetails = [];
  bool _isFixtureLoading = false;

  List<Tournament> get myTournaments => _myTournaments;
  List<Tournament> get upcomingTournaments => _upcomingTournaments;
  bool get isLoading => _isLoading;
  bool get isFixtureLoading => _isFixtureLoading;
  String? get errorMessage => _errorMessage;
  int get totalTournaments => _totalTournaments;
  List<Fixture> get fixtureDetails => _fixtureDetails;

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
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

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
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString('studentId') ?? '124';
      final token = prefs.getString('authToken');

      final url = Uri.parse(
        '${ApiConstants.kudoUrl}/api/tournament/get-by-id?id=$studentId&tournament_id=$tournamentId',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data']['fixtures'] != null) {
          final List fixturesJson = data['data']['fixtures'];
          _fixtureDetails =
              fixturesJson.map((json) => Fixture.fromJson(json)).toList();
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
}
