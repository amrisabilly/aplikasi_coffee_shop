import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/detail-model.dart';
import '../../../controllers/detail_controller.dart';

class DetailPage extends StatefulWidget {
  final String productId;
  final String from; // Tambahkan parameter ini

  const DetailPage({super.key, required this.productId, required this.from});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final DetailController detailController = DetailController();

  late Future<ProductDetail> productDetailFuture;
  String selectedSize = 'M';
  String selectedTemperature = 'hot'; // 'hot', 'ice', 'warm'
  bool isFavorite = false;
  double userRating = 0.0; // Rating yang dipilih user
  bool hasRated = false; // Apakah user sudah rating

  @override
  void initState() {
    super.initState();
    productDetailFuture = detailController.fetchDetail(
      int.parse(widget.productId),
    );
  }

  // Saat order
  void _onOrder(ProductDetail product) async {
    await detailController.addToCart(
      product,
      1, // qty, bisa tambahkan input qty jika mau
      selectedSize,
      selectedTemperature,
      product.price.toString(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} berhasil ditambahkan ke keranjang!'),
        backgroundColor: Color(0xFFC67C4E),
      ),
    );
  }

  // Saat submit rating
  void _submitRating(double rating) async {
    await detailController.submitRating(int.parse(widget.productId), rating);
    // ...lanjutkan feedback UI...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        toolbarHeight: 100,
        centerTitle: true,
        backgroundColor: Color(0xFFF9F9F9),
        title: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            "Detail",
            style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 30, top: 20),
          child: IconButton(
            icon: const Icon(Icons.keyboard_arrow_left_sharp),
            onPressed: () {
              // Kembali berdasarkan parameter 'from'
              if (widget.from == 'menu') {
                context.go('/menu');
              } else {
                context.go('/home');
              }
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30, top: 20),
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_outline_outlined,
                color: isFavorite ? Colors.red : Colors.black,
              ),
              onPressed: () {
                setState(() {
                  isFavorite = !isFavorite;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isFavorite
                          ? 'Ditambahkan ke favorit'
                          : 'Dihapus dari favorit',
                    ),
                    backgroundColor: Color(0xFFC67C4E),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<ProductDetail>(
        future: productDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Color(0xFFC67C4E)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Gagal memuat detail produk'),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        productDetailFuture = detailController.fetchDetail(
                          int.parse(widget.productId),
                        );
                      });
                    },
                    child: Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final product = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Gambar Produk
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        width: 320,
                        height: 202,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child:
                            product.imageUrl != null &&
                                    product.imageUrl!.isNotEmpty
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    product.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.local_cafe,
                                          size: 60,
                                          color: Color(0xFFC67C4E),
                                        ),
                                      );
                                    },
                                  ),
                                )
                                : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.local_cafe,
                                    size: 60,
                                    color: Color(0xFFC67C4E),
                                  ),
                                ),
                      ),

                      SizedBox(height: 20),

                      // Info Produk
                      Padding(
                        padding: EdgeInsets.only(right: 40, left: 40),
                        child: Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nama Produk
                              Text(
                                product.name,
                                style: GoogleFonts.sora(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              // Kategori dan Icons
                              Row(
                                children: [
                                  Text(
                                    product.category.name,
                                    style: GoogleFonts.sora(fontSize: 12),
                                  ),
                                  Spacer(),
                                  Row(
                                    children: [
                                      // Hot
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedTemperature = 'hot';
                                          });
                                        },
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color:
                                                selectedTemperature == 'hot'
                                                    ? Color(0xFFC67C4E)
                                                    : Color(0xFFEDEDED),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.local_cafe,
                                            color:
                                                selectedTemperature == 'hot'
                                                    ? Colors.white
                                                    : Color(0xFFC67C4E),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      // Ice
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedTemperature = 'ice';
                                          });
                                        },
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color:
                                                selectedTemperature == 'ice'
                                                    ? Color(0xFFC67C4E)
                                                    : Color(0xFFEDEDED),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.ac_unit,
                                            color:
                                                selectedTemperature == 'ice'
                                                    ? Colors.white
                                                    : Color(0xFFC67C4E),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      // Warm
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedTemperature = 'warm';
                                          });
                                        },
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color:
                                                selectedTemperature == 'warm'
                                                    ? Color(0xFFC67C4E)
                                                    : Color(0xFFEDEDED),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.whatshot,
                                            color:
                                                selectedTemperature == 'warm'
                                                    ? Colors.white
                                                    : Color(0xFFC67C4E),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: 18),
                              // Rating & Rating Button
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    product.rating.toString(),
                                    style: GoogleFonts.sora(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    "(${product.reviewCount})",
                                    style: GoogleFonts.sora(
                                      color: Colors.blueGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Spacer(),
                                  // Tombol Rating
                                  ElevatedButton.icon(
                                    onPressed: () => _showRatingDialog(context),
                                    icon: Icon(
                                      hasRated ? Icons.star : Icons.star_border,
                                      size: 16,
                                      color:
                                          hasRated
                                              ? Colors.amber
                                              : Colors.white,
                                    ),
                                    label: Text(
                                      hasRated ? 'Rated' : 'Rate',
                                      style: GoogleFonts.sora(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          hasRated
                                              ? Colors.green
                                              : Color(0xFFC67C4E),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 8),
                              Divider(
                                color: Color(0xFFE3E3E3),
                                thickness: 1,
                                indent: 5,
                                endIndent: 5,
                              ),
                              SizedBox(height: 8),

                              // Description
                              Text(
                                "Description",
                                style: GoogleFonts.sora(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                product.description,
                                style: GoogleFonts.sora(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),

                              SizedBox(height: 16),

                              // Size Selection
                              Text(
                                "Size",
                                style: GoogleFonts.sora(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 15),
                              Row(
                                children: [
                                  _buildSizeButton('S'),
                                  Spacer(),
                                  _buildSizeButton('M'),
                                  Spacer(),
                                  _buildSizeButton('L'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Navigation Bar dengan Harga
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40),
                alignment: Alignment.center,
                height: 118,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Price",
                          style: GoogleFonts.sora(
                            color: Color(0xFF909090),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Rp ${product.price.toStringAsFixed(0)}",
                          style: GoogleFonts.sora(
                            color: Color(0xFFC67C4E),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        _onOrder(product);
                      },
                      child: Text(
                        "Buy Now",
                        style: GoogleFonts.sora(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 70,
                          vertical: 14,
                        ),
                        backgroundColor: Color(0xFFC67C4E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSizeButton(String size) {
    final isSelected = selectedSize == size;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSize = size;
        });
      },
      child: Container(
        width: 96,
        height: 41,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFEDD6C8) : Colors.white,
          border: Border.all(
            color: isSelected ? Color(0xFFC67C4E) : Color(0xFFE3E3E3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            size,
            style: GoogleFonts.sora(
              color: isSelected ? Color(0xFFC67C4E) : Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    double tempRating = userRating;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Berikan Rating',
                style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bagaimana pendapat Anda tentang produk ini?',
                    style: GoogleFonts.sora(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  // Rating Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            tempRating = index + 1.0;
                          });
                        },
                        child: Icon(
                          index < tempRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 10),
                  Text(
                    tempRating > 0 ? '${tempRating.toInt()}/5' : 'Pilih rating',
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFC67C4E),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.sora(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      tempRating > 0
                          ? () {
                            setState(() {
                              userRating = tempRating;
                              hasRated = true;
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Terima kasih! Rating ${tempRating.toInt()}/5 berhasil diberikan.',
                                ),
                                backgroundColor: Color(0xFFC67C4E),
                              ),
                            );
                            // TODO: Kirim rating ke backend/API
                            // _submitRating(tempRating);
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFC67C4E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Kirim Rating',
                    style: GoogleFonts.sora(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// void _submitRating(double rating) {
//   // TODO: Kirim rating ke API backend
//   print('Rating ${rating} untuk produk ${widget.productId} berhasil dikirim');
//   // Contoh: await ratingController.submitRating(widget.productId, rating);
// }
