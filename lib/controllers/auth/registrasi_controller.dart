import 'dart:convert';
import 'package:http/http.dart' as http;

// Model Registrasi langsung di controller
class Registrasi {
  final String full_name;
  final String email;
  final String password;

  Registrasi({
    required this.full_name,
    required this.email,
    required this.password,
  });

  factory Registrasi.fromJson(Map<String, dynamic> json) {
    return Registrasi(
      full_name: json['full_name'],
      email: json['email'],
      password: json['password'],
    );
  }
}

class RegistrasiController {
  /// Registrasi user baru ke backend
  Future<bool> registerUser(Registrasi registrasi) async {
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
}
