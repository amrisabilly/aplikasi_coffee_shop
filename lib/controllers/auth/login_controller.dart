import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// Controller untuk autentikasi user
class UserController {
  /// Login user ke backend, return LoginResponse
  Future<LoginResponse> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('https://monitoringweb.decoratics.id/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return LoginResponse.fromJson(jsonResponse);
    } else {
      try {
        final jsonResponse = json.decode(response.body);
        return LoginResponse(
          message: jsonResponse['message'] ?? 'Email atau password salah!',
          user: null,
          token: null,
        );
      } catch (_) {
        return LoginResponse(
          message: 'Email atau password salah!',
          user: null,
          token: null,
        );
      }
    }
  }

  /// SharedPreferences
  Future<void> saveUserData(Map<String, dynamic> user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user_name', user['full_name'] ?? '');
    prefs.setString('user_email', user['email'] ?? '');
    prefs.setInt('user_id', user['id']);
    prefs.setString('user_token', token);
    prefs.setString('user_photo_url', user['photo_url'] ?? '');
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? '';
  }

  Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email') ?? '';
  }

  Future<String> getUserPhotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_photo_url') ?? '';
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

// Model login
class LoginResponse {
  final String message;
  final Map<String, dynamic>? user;
  final String? token;

  LoginResponse({required this.message, this.user, this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      user: json['user'],
      token: json['token'],
    );
  }
}
