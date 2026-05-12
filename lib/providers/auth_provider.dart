import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stradia_ace/utils/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.authBaseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'UserEmail': email, 'UserPassword': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', token);

          // Save student ID
          final studentId = data['studentId'];
          if (studentId != null) {
            await prefs.setString('studentId', studentId.toString());
            debugPrint('Student ID saved: $studentId');
          } else {
            // Fallback for older API versions or if studentId is missing
            final id = data['id'];
            if (id != null) {
              await prefs.setString('studentId', id.toString());
              debugPrint('Student ID saved from id field: $id');
            }
          }
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          _errorMessage = errorData['message'] ?? 'Login failed';
        } catch (e) {
          _errorMessage = 'Login failed: ${response.statusCode}';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendOtp(String mobileNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.authBaseUrl}/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobileNumber': mobileNumber}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          _errorMessage = errorData['message'] ?? 'Failed to send OTP';
        } catch (e) {
          _errorMessage = 'Failed to send OTP: ${response.statusCode}';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String mobileNumber, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.authBaseUrl}/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobileNumber': mobileNumber, 'otp': otp}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token =
            data['token']; // Assuming the API returns a token on verification

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', token);
          await prefs.setBool('isLoggedIn', true);

          // Save student ID if available (assuming similar response structure to login)
          final studentId = data['studentId'];
          if (studentId != null) {
            await prefs.setString('studentId', studentId.toString());
          }
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          _errorMessage = errorData['message'] ?? 'Invalid OTP';
        } catch (e) {
          _errorMessage = 'Verification failed: ${response.statusCode}';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data or specify keys
    notifyListeners();
  }
}
