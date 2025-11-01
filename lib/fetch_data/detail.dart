import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/detail-model.dart';

Future<ProductDetail> fetchProductDetail(int productId) async {
  final response = await http.get(
    Uri.parse(
      'https://monitoringweb.decoratics.id/api/coffe/products/$productId',
    ),
  );

  print('Response Body: ${response.body}');

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return ProductDetail.fromJson(jsonResponse);
  } else {
    throw Exception('Gagal memuat detail produk');
  }
}
