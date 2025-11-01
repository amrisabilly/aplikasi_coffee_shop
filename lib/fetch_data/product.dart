import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product-model.dart'; // Import model Product
import '../models/kategori-model.dart'; // Import model Category

Future<List<Product>> fetchProducts() async {
  final response = await http.get(
    Uri.parse('https://monitoringweb.decoratics.id/api/coffe/products'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => Product.fromJson(item)).toList();
  } else {
    throw Exception('Gagal memuat data dari server');
  }
}
