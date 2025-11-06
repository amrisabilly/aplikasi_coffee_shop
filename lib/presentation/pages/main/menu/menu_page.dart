import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

// Import controller
import 'package:project_satu/controllers/menu__list_controller.dart';
import '../../../../models/product-model.dart';
import '../../../../models/kategori-model.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  // Controller
  final menuController = MenuListController();

  // Data variables
  List<Kategori> categories = [];
  int selectedCategoryId = 0; // 0 untuk "Semua"
  bool isLoadingCategories = true;
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setupSearchListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Setup search listener
  void _setupSearchListener() {
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.trim().toLowerCase();
        _filterProducts();
      });
    });
  }

  // Load data menggunakan controller
  Future<void> _loadInitialData() async {
    await Future.wait([_loadCategories(), _loadProducts()]);
  }

  Future<void> _loadCategories() async {
    final data = await menuController.loadCategories();
    setState(() {
      categories = data;
      isLoadingCategories = false;
    });
  }

  Future<void> _loadProducts() async {
    final products = await menuController.loadProducts();
    setState(() {
      allProducts = products;
      _filterProducts();
    });
  }

  // Handle kategori selection menggunakan controller
  void _onCategorySelected(int id) {
    setState(() {
      selectedCategoryId = id;
      _filterProducts();
    });
    menuController.handleCategoryTap(id);
  }

  // Filter produk menggunakan controller
  void _filterProducts() {
    final filtered = menuController.filterProducts(
      allProducts: allProducts,
      selectedCategoryId: selectedCategoryId,
      searchQuery: searchQuery,
    );
    setState(() {
      filteredProducts = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Pilihan KopiKelana",
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari produk...",
                hintStyle: GoogleFonts.sora(fontSize: 13, color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 12,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey),
                isDense: true,
              ),
              style: GoogleFonts.sora(fontSize: 13),
            ),
          ),

          // FILTER KATEGORI
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child:
                isLoadingCategories
                    ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black54,
                        ),
                      ),
                    )
                    : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length + 1,
                      itemBuilder: (context, index) {
                        final isAll = index == 0;
                        final category = isAll ? null : categories[index - 1];
                        final categoryId = isAll ? 0 : category!.id;

                        // Gunakan controller untuk format nama dan cek selection
                        final categoryName = menuController
                            .getCategoryDisplayName(category, isAll);
                        final isSelected = menuController.isCategorySelected(
                          categoryId,
                          selectedCategoryId,
                        );

                        return GestureDetector(
                          onTap: () => _onCategorySelected(categoryId),
                          child: Container(
                            margin: EdgeInsets.only(right: 16),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Color(0xFFC67C4E)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Color(0xFFC67C4E)
                                        : Colors.grey.shade300,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                categoryName,
                                style: GoogleFonts.sora(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),

          // DAFTAR PRODUK
          Expanded(
            child: Builder(
              builder: (context) {
                if (allProducts.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.black54),
                  );
                }

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.coffee_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Tidak ada produk',
                          style: GoogleFonts.sora(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return GestureDetector(
                      onTap: () {
                        // Gunakan controller untuk generate route
                        final route = menuController.getProductDetailRoute(
                          product,
                        );
                        context.go(route);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gambar Produk
                            Expanded(
                              flex: 3,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  color: Colors.grey.shade100,
                                ),
                                child:
                                    product.imageUrl != null &&
                                            product.imageUrl!.isNotEmpty
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                          child: Image.network(
                                            product.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Container(
                                                width: double.infinity,
                                                height: double.infinity,
                                                color: Colors.grey.shade100,
                                                child: Icon(
                                                  Icons.local_cafe,
                                                  size: 32,
                                                  color: Colors.grey.shade400,
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                        : Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          color: Colors.grey.shade100,
                                          child: Icon(
                                            Icons.local_cafe,
                                            size: 32,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                              ),
                            ),

                            // Info Produk
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Nama Produk
                                    Text(
                                      product.name,
                                      style: GoogleFonts.sora(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),

                                    // Kategori
                                    Text(
                                      product.category.name,
                                      style: GoogleFonts.sora(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),

                                    Spacer(),

                                    // Harga
                                    Text(
                                      'Rp ${product.price.toStringAsFixed(0)}',
                                      style: GoogleFonts.sora(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFC67C4E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
