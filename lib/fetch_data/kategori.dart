import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/kategori-model.dart';

Future<List<Kategori>> fetchKategoris() async {
  final response = await http.get(
    Uri.parse('https://monitoringweb.decoratics.id/api/coffe/categories'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => Kategori.fromJson(item)).toList();
  } else {
    throw Exception('Gagal memuat data dari server');
  }
}
