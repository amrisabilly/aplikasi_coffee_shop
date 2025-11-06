import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Import controller
import '../../../../controllers/home-controller.dart';
import '../../../../models/kategori-model.dart';
import '../../../../models/product-model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;

  // Controller
  final homeController = HomeController();

  // Data variables
  String userName = "User";
  List<Kategori> categories = [];
  bool isLoadingCategories = true;
  List<Product> products = [];
  bool isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Load semua data initial menggunakan controller
  Future<void> _loadInitialData() async {
    await Future.wait([_loadUserName(), _loadCategories(), _loadProducts()]);
  }

  Future<void> _loadUserName() async {
    final name = await homeController.getUserName();
    setState(() {
      userName = name;
    });
  }

  Future<void> _loadCategories() async {
    final data = await homeController.loadCategories();
    setState(() {
      categories = data;
      isLoadingCategories = false;
    });
  }

  Future<void> _loadProducts() async {
    final data = await homeController.getRecommendedProducts();
    setState(() {
      products = data;
      isLoadingProducts = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // A. Header & Sapaan Personal
            Container(
              padding: EdgeInsets.only(
                top: 50,
                left: 30,
                right: 30,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF111111), Color(0xFF313131)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sapaan & Profil (menggunakan data dari controller)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                  "Selamat Datang, $userName! 👋",
                                  style: GoogleFonts.sora(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 200.ms, duration: 600.ms)
                                .slideX(begin: -0.3, end: 0),
                            SizedBox(height: 4),
                            Text(
                                  "Siap untuk petualangan kopimu hari ini?",
                                  style: GoogleFonts.sora(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 400.ms, duration: 600.ms)
                                .slideX(begin: -0.3, end: 0),
                          ],
                        ),
                      ),
                      // Ikon Aksi Cepat
                      Row(
                        children: [
                          SizedBox(width: 12),
                          Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () {},
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 800.ms, duration: 400.ms)
                              .scale(
                                begin: Offset(0.8, 0.8),
                                end: Offset(1, 1),
                              ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // B. Konten Dinamis & Rekomendasi
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Promosi Utama
                  Container(
                        height: 160,
                        child: PageView(
                          controller: _bannerController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentBannerIndex = index;
                            });
                          },
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: AssetImage('assets/images/banner.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.black.withOpacity(0.7),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "PROMO",
                                        style: GoogleFonts.sora(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Jelajahi Rasa dari Ethiopia!",
                                      style: GoogleFonts.sora(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Diskon 20% untuk semua kopi single origin",
                                      style: GoogleFonts.sora(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFC67C4E),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () => context.go('/explore'),
                                      child: Text(
                                        "Jelajahi Sekarang",
                                        style: GoogleFonts.sora(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 1000.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),

                  SizedBox(height: 30),

                  // Kategori Menu (data dari controller)
                  Text(
                    "Pilih Kategori",
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ).animate().fadeIn(delay: 1200.ms, duration: 400.ms),

                  SizedBox(height: 16),

                  Container(
                    height: 100,
                    child:
                        isLoadingCategories
                            ? Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFC67C4E),
                              ),
                            )
                            : categories.isEmpty
                            ? Center(
                              child: Text(
                                "Tidak ada kategori",
                                style: GoogleFonts.sora(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            )
                            : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                return Container(
                                      width: 80,
                                      margin: EdgeInsets.only(right: 16),
                                      child: GestureDetector(
                                        onTap: () {
                                          homeController.handleCategoryTap(
                                            category,
                                          ); // Gunakan controller
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.08),
                                                    blurRadius: 10,
                                                    offset: Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.local_cafe,
                                                  size: 24,
                                                  color: Color(0xFFC67C4E),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              category.name,
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.sora(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(
                                      delay: (1400 + index * 100).ms,
                                      duration: 400.ms,
                                    )
                                    .slideX(begin: 0.3, end: 0);
                              },
                            ),
                  ),

                  SizedBox(height: 15),

                  // Rekomendasi Produk (data dari controller)
                  Text(
                    "Pilihan Barista Untukmu",
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ).animate().fadeIn(delay: 1800.ms, duration: 400.ms),

                  SizedBox(height: 16),

                  isLoadingProducts
                      ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFC67C4E),
                        ),
                      )
                      : products.isEmpty
                      ? Center(
                        child: Text(
                          "Tidak ada produk",
                          style: GoogleFonts.sora(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      )
                      : GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return GestureDetector(
                                onTap: () {
                                  // Gunakan controller untuk mendapatkan route
                                  final route = homeController
                                      .getProductDetailRoute(product, 'home');
                                  context.go(route);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Gambar produk
                                      Expanded(
                                        flex: 3,
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                      top: Radius.circular(16),
                                                    ),
                                                color: Colors.grey.shade200,
                                              ),
                                              child:
                                                  product.imageUrl != null
                                                      ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                              top:
                                                                  Radius.circular(
                                                                    16,
                                                                  ),
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
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade200,
                                                              child: Icon(
                                                                Icons
                                                                    .local_cafe,
                                                                size: 50,
                                                                color: Color(
                                                                  0xFFC67C4E,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          loadingBuilder: (
                                                            context,
                                                            child,
                                                            loadingProgress,
                                                          ) {
                                                            if (loadingProgress ==
                                                                null)
                                                              return child;
                                                            return Center(
                                                              child: CircularProgressIndicator(
                                                                color: Color(
                                                                  0xFFC67C4E,
                                                                ),
                                                                value:
                                                                    loadingProgress.expectedTotalBytes !=
                                                                            null
                                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                                            loadingProgress.expectedTotalBytes!
                                                                        : null,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      )
                                                      : Container(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade200,
                                                        child: Icon(
                                                          Icons.local_cafe,
                                                          size: 50,
                                                          color: Color(
                                                            0xFFC67C4E,
                                                          ),
                                                        ),
                                                      ),
                                            ),
                                            // Rating badge
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.7),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      size: 12,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      "4.8",
                                                      style: GoogleFonts.sora(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Info produk
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
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
                                              Text(
                                                product.category.name,
                                                style: GoogleFonts.sora(
                                                  fontSize: 11,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              Spacer(),
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
                              )
                              .animate()
                              .fadeIn(
                                delay: (2000 + index * 200).ms,
                                duration: 600.ms,
                              )
                              .slideY(begin: 0.3, end: 0);
                        },
                      ),

                  SizedBox(height: 30),

                  // Sorotan Fitur Unik "Jelajah"
                  Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFC67C4E), Color(0xFFE5A777)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "🌍 Janjian Kopi Lintas Waktu",
                                    style: GoogleFonts.sora(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Punya teman di luar negeri? Cari waktu terbaik untuk 'ngopi bareng' virtual!",
                                    style: GoogleFonts.sora(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Color(0xFFC67C4E),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => context.go('/explore'),
                                    child: Text(
                                      "Mulai Jelajahi",
                                      style: GoogleFonts.sora(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                Icons.explore,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 2500.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),

                  SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
