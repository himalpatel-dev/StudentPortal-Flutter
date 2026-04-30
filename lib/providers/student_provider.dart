import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_portal/models/student.dart';
import 'package:student_portal/models/master.dart';
import 'package:student_portal/models/student_stats.dart';
import 'package:student_portal/utils/api_constants.dart';

class StudentProvider extends ChangeNotifier {
  Student? _student;
  StudentStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  List<Country> _countries = [];
  List<StateModel> _states = [];
  List<District> _districts = [];
  List<City> _cities = [];
  List<RequiredDocument> _requiredDocuments = [];

  Student? get student => _student;
  StudentStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Country> get countries => _countries;
  List<StateModel> get states => _states;
  List<District> get districts => _districts;
  List<City> get cities => _cities;
  List<RequiredDocument> get requiredDocuments => _requiredDocuments;

  Future<void> fetchCountries() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.authBaseUrl}/master-country/getAllCountry'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        _countries = data.map((json) => Country.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching countries: $e');
    }
  }

  Future<void> fetchStates(int countryId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.authBaseUrl}/master-state/getStateByCountry?country_id=$countryId',
        ),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        _states = data.map((json) => StateModel.fromJson(json)).toList();
        _districts = [];
        _cities = [];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching states: $e');
    }
  }

  Future<void> fetchDistricts(int stateId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.authBaseUrl}/master-district/getDistrictByState?state_id=$stateId',
        ),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        _districts = data.map((json) => District.fromJson(json)).toList();
        _cities = [];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching districts: $e');
    }
  }

  Future<void> fetchCities(int districtId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.authBaseUrl}/master-city/getCityByDistrict?district_id=$districtId',
        ),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        _cities = data.map((json) => City.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching cities: $e');
    }
  }

  Future<void> fetchRequiredDocuments() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.kudoUrl}/api/required-doc-list/getReqDocListMasterByProcessIdForStudent?process_id=1',
        ),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        _requiredDocuments = data
            .map((json) => RequiredDocument.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching required documents: $e');
    }
  }

  Future<void> fetchStudentDetails() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString('studentId') ?? '1';

      final token = prefs.getString('authToken');
      final response = await http
          .get(
            Uri.parse('${ApiConstants.authBaseUrl}/student/$studentId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _student = Student.fromJson(data);
      } else {
        _errorMessage = 'Failed to load student details';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> createStudent(
    Map<String, dynamic> studentData,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.authBaseUrl}/student'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(studentData),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return data; // Return the entire response map
      } else {
        _errorMessage = data['message'] ?? 'Failed to create student';
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> createStudentKudo(
    Map<String, dynamic> studentData,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConstants.kudoUrl}/api/students/create-student-by-student',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(studentData),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return data; // Return the entire response map
      } else {
        _errorMessage = data['message'] ?? 'Failed to create student in Kudo';
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStudentStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString('studentId') ?? '124';

      final token = prefs.getString('authToken');
      final response = await http.get(
        Uri.parse('${ApiConstants.kudoUrl}/api/students/get-stats/$studentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        _stats = StudentStats.fromJson(body['data']);
      } else {
        debugPrint('Failed to load stats: ${response.statusCode}');
        _stats = StudentStats.empty();
      }
    } catch (e) {
      debugPrint('Error fetching student stats: $e');
      _stats = StudentStats.empty();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStudentProfileImage(int studentId, String imageUrl) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.authBaseUrl}/student/$studentId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "Student": {
            "student_profile_image": {
              "doc_id": 0,
              "is_active": true,
              "uuid": studentId.toString(),
              "doc_file_name": imageUrl,
              "doc_content_type": imageUrl.toLowerCase().endsWith('pdf')
                  ? 'application/pdf'
                  : 'image/jpeg',
              "doc_type": null,
              "document_type_id": 0,
              "document_type_name": "Profile Image",
              "document_number": "",
              "doc_file_ext": imageUrl.split('.').last,
            },
          },
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error updating local profile image: $e');
      return false;
    }
  }
}
