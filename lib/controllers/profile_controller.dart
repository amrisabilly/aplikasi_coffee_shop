import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileController {
  Future<Map<String, dynamic>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userName': prefs.getString('user_name') ?? "User",
      'userEmail': prefs.getString('user_email') ?? "user@email.com",
      'userPoints': prefs.getInt('user_points') ?? 0,
      'imagePath': prefs.getString('user_profile_image'),
      'photoUrl': prefs.getString('user_photo_url'),
    };
  }

  Future<void> saveProfileImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile_image', path);
  }

  Future<void> savePhotoUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_photo_url', url);
  }

  Future<String?> uploadProfileImage(File file, String token) async {
    final uri = Uri.parse(
      'https://monitoringweb.decoratics.id/api/auth/profile/upload-photo',
    );
    final req = http.MultipartRequest('POST', uri);
    req.headers['Authorization'] = 'Bearer $token';
    req.files.add(await http.MultipartFile.fromPath('photo', file.path));
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      return data['photo_url'];
    }
    return null;
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token') ?? '';
  }

  Future<void> savePoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_points', points);
  }

  /// Tambah poin ke database via endpoint /profile/add-point
  Future<bool> addPointsToDatabase(int addPoints) async {
    try {
      final token = await getToken();
      if (token.isEmpty) return false;

      final uri = Uri.parse(
        'https://monitoringweb.decoratics.id/api/auth/profile/add-point',
      );
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'points': addPoints}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final points = data['points'] ?? 0;
        await savePoints(points); // update local
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding points to database: $e');
      return false;
    }
  }

  /// Tambah poin (untuk game atau aktivitas lain)
  Future<bool> addPoints(int earnedPoints) async {
    return await addPointsToDatabase(earnedPoints);
  }

  /// Kurangi poin (untuk redeem reward) - hanya update lokal
  Future<bool> redeemPoints(int pointsToRedeem) async {
    try {
      final currentData = await loadUserData();
      final currentPoints = currentData['userPoints'] as int;

      if (currentPoints < pointsToRedeem) {
        return false;
      }

      final newPoints = currentPoints - pointsToRedeem;
      await savePoints(newPoints);
      return true;
    } catch (e) {
      print('Error redeeming points: $e');
      return false;
    }
  }

  /// Sync poin dari database (untuk refresh data)
  Future<void> syncPointsFromDatabase() async {
    try {
      final token = await getToken();
      if (token.isEmpty) return;

      final uri = Uri.parse(
        'https://monitoringweb.decoratics.id/api/auth/users',
      );
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final points = data['points'] ?? 0;
        await savePoints(points);
      }
    } catch (e) {
      print('Error syncing points from database: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> syncUserFromDatabase() async {
    final token = await getToken();
    if (token.isEmpty) return;

    final uri = Uri.parse('https://monitoringweb.decoratics.id/api/auth/users');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // data adalah List, cari user yang sesuai id login
      final prefs = await SharedPreferences.getInstance();
      final currentEmail = prefs.getString('user_email') ?? '';
      // Atau jika kamu simpan id user:
      // final currentId = prefs.getInt('user_id') ?? 0;

      Map<String, dynamic>? user;
      if (data is List) {
        user = data.firstWhere(
          (u) => u['email'] == currentEmail,
          orElse: () => null,
        );
      }

      if (user != null) {
        await prefs.setInt('user_points', user['points'] ?? 0);
        await prefs.setString('user_name', user['full_name'] ?? '');
        await prefs.setString('user_email', user['email'] ?? '');
        await prefs.setString('user_photo_url', user['photo_url'] ?? '');
      }
    }
  }

  Future<bool> redeemPointsFromDatabase(int pointsToRedeem) async {
    try {
      final token = await getToken();
      if (token.isEmpty) return false;

      final uri = Uri.parse(
        'https://monitoringweb.decoratics.id/api/auth/profile/redeem-points',
      );
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'points': pointsToRedeem}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final points = data['points'] ?? 0;
        await savePoints(points); // update local
        return true;
      }
      return false;
    } catch (e) {
      print('Error redeeming points from database: $e');
      return false;
    }
  }
}
