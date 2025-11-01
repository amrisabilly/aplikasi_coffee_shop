import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/user/registrasi-model.dart';

Future<bool> createUser(Registrasi registrasi) async {
  final response = await http.post(
    Uri.parse('https://monitoringweb.decoratics.id/api/auth/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'full_name': registrasi.full_name,
      'email': registrasi.email,
      'password': registrasi.password,
    }),
  );

  if (response.statusCode == 201 || response.statusCode == 200) {
    return true; // Berhasil
  } else {
    print('Error: ${response.body}');
    return false; // Gagal
  }
}

class LoginResponse {
  final String message;
  final Map<String, dynamic>? user;
  final String? token; // tetap ada jika backend nanti menambah token

  LoginResponse({required this.message, this.user, this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      user: json['user'],
      token: json['token'], // akan null jika tidak ada di response
    );
  }
}
