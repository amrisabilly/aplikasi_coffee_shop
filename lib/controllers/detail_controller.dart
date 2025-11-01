import '../models/detail-model.dart';
import '../fetch_data/detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DetailController {
  Future<ProductDetail> fetchDetail(int productId) async {
    return await fetchProductDetail(productId);
  }

  // Simulasi order (misal: simpan ke keranjang, dsb)
  Future<void> orderProduct(ProductDetail product) async {
    // TODO: Implementasi order ke backend/keranjang
    await Future.delayed(Duration(milliseconds: 500));
  }

  // Simulasi rating (misal: kirim ke backend)
  Future<void> submitRating(int productId, double rating) async {
    // TODO: Implementasi kirim rating ke backend
    await Future.delayed(Duration(milliseconds: 500));
  }

  Future<void> addToCart(
    ProductDetail product,
    int qty,
    String size,
    String temp,
    String price,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final cartKey = await getCartKey();
    final cart = prefs.getStringList(cartKey) ?? [];
    final item = jsonEncode({
      'product_id': product.id,
      'product_name': product.name,
      'qty': qty,
      'size': size,
      'temperature': temp,
      'price': price,
      'image': product.imageUrl, // Tambahkan ini
    });
    cart.add(item);
    await prefs.setStringList(cartKey, cart);
  }

  /// Ambil semua item cart
  Future<List<Map<String, dynamic>>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartKey = await getCartKey();
    final cart = prefs.getStringList(cartKey) ?? [];
    return cart.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  /// Hapus item cart berdasarkan index
  Future<void> removeFromCart(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final cartKey = await getCartKey();
    final cart = prefs.getStringList(cartKey) ?? [];
    if (index >= 0 && index < cart.length) {
      cart.removeAt(index);
      await prefs.setStringList(cartKey, cart);
    }
  }

  /// Hapus semua cart (opsional)
  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartKey = await getCartKey();
    await prefs.remove(cartKey);
  }

  /// Method untuk mendapatkan SharedPreferences instance
  Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<String> getCartKey() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email') ?? '';
    return 'cart_$email';
  }
}
