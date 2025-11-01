import 'package:shared_preferences/shared_preferences.dart';
import '../models/kategori-model.dart';
import '../fetch_data/kategori.dart';
import '../models/product-model.dart';
import '../fetch_data/product.dart';

class HomeController {
  // Mendapatkan nama user dari SharedPreferences
  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? 'User';
  }

  // Mengambil data kategori dari API
  Future<List<Kategori>> loadCategories() async {
    try {
      return await fetchKategoris();
    } catch (e) {
      print('Error loading categories: $e');
      return [];
    }
  }

  // Mengambil data produk dari API
  Future<List<Product>> loadProducts() async {
    try {
      return await fetchProducts();
    } catch (e) {
      print('Error loading products: $e');
      return [];
    }
  }

  // Mendapatkan produk terbatas untuk homepage (max 4 item)
  Future<List<Product>> getRecommendedProducts() async {
    try {
      final products = await fetchProducts();
      return products.length > 4 ? products.take(4).toList() : products;
    } catch (e) {
      print('Error loading recommended products: $e');
      return [];
    }
  }

  // Handle kategori selection
  void handleCategoryTap(Kategori category) {
    print('Kategori dipilih: ${category.name}');
    // TODO: Implement navigation to category page or filter products
  }

  // Handle product navigation
  String getProductDetailRoute(Product product, String from) {
    return '/detail/${product.id}?from=$from';
  }
}
