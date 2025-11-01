import '../models/kategori-model.dart';
import '../fetch_data/kategori.dart';
import '../models/product-model.dart';
import '../fetch_data/product.dart';

class MenuListController {
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

  // Filter produk berdasarkan kategori dan pencarian
  List<Product> filterProducts({
    required List<Product> allProducts,
    required int selectedCategoryId,
    required String searchQuery,
  }) {
    List<Product> products = allProducts;

    // Filter kategori (0 = semua kategori)
    if (selectedCategoryId != 0) {
      products =
          products
              .where((product) => product.category.id == selectedCategoryId)
              .toList();
    }

    // Filter pencarian
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      products =
          products
              .where(
                (product) =>
                    product.name.toLowerCase().contains(query) ||
                    product.category.name.toLowerCase().contains(query),
              )
              .toList();
    }

    return products;
  }

  // Handle kategori selection
  void handleCategoryTap(int categoryId) {
    print('Kategori dipilih: $categoryId');
    // Logic tambahan bisa ditambah di sini
  }

  // Generate route untuk detail produk
  String getProductDetailRoute(Product product) {
    return '/detail/${product.id}?from=menu';
  }

  // Validasi search query
  bool isValidSearchQuery(String query) {
    return query.trim().isNotEmpty && query.length >= 2;
  }

  // Format kategori untuk tampilan
  String getCategoryDisplayName(Kategori? category, bool isAll) {
    if (isAll) return "Semua";
    return category?.name ?? "Unknown";
  }

  // Check apakah kategori dipilih
  bool isCategorySelected(int categoryId, int selectedCategoryId) {
    return categoryId == selectedCategoryId;
  }
}
