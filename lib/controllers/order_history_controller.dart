import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderHistoryController {
  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token') ?? '';
  }

  Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0;
  }

  Future<List<Map<String, dynamic>>> getOrderHistory() async {
    try {
      final token = await getToken();
      final userId = await getUserId();

      if (token.isEmpty || userId == 0) return [];

      final uri = Uri.parse(
        'https://monitoringweb.decoratics.id/api/coffe/orders?user_id=$userId',
      );
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      print('Order history response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
        return [];
      }
      return [];
    } catch (e) {
      print('Error fetching order history: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getOrderDetail(int orderId) async {
    try {
      final token = await getToken();
      if (token.isEmpty) return null;

      final uri = Uri.parse(
        'https://monitoringweb.decoratics.id/api/coffe/orders/$orderId',
      );
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      print('Order detail response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      }
      return null;
    } catch (e) {
      print('Error fetching order detail: $e');
      return null;
    }
  }
}
