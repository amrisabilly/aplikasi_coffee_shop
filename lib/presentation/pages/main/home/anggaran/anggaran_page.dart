import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../fetch_data/product.dart';
import '../../../../../models/product-model.dart';

class AnggaranPage extends StatefulWidget {
  const AnggaranPage({super.key});

  @override
  State<AnggaranPage> createState() => _AnggaranPageState();
}

class _AnggaranPageState extends State<AnggaranPage> {
  final TextEditingController _budgetController = TextEditingController();

  // Daftar mata uang dan nilai tukar ke Rupiah (kisaran, tidak bisa diubah user)
  final List<Map<String, dynamic>> currencies = [
    {'code': 'USD', 'name': 'US Dollar', 'rate': 15500},
    {'code': 'EUR', 'name': 'Euro', 'rate': 17000},
    {'code': 'MYR', 'name': 'Malaysian Ringgit', 'rate': 3300},
    {'code': 'SGD', 'name': 'Singapore Dollar', 'rate': 11500},
    {'code': 'JPY', 'name': 'Japanese Yen', 'rate': 105},
    {'code': 'AUD', 'name': 'Australian Dollar', 'rate': 10200},
  ];

  String selectedCurrency = 'USD';
  double selectedRate = 15500;

  double? budget;
  bool isLoading = false;
  bool isCalculated = false;
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];

  Future<void> loadProducts() async {
    setState(() {
      isLoading = true;
    });
    try {
      final products = await fetchProducts();
      setState(() {
        allProducts = products;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat produk dari server")),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  void calculateRecommendation() {
    if (_budgetController.text.isEmpty) return;

    budget = double.tryParse(_budgetController.text);

    if (budget == null) return;

    double budgetIDR = budget! * selectedRate;
    filteredProducts =
        allProducts.where((p) => p.price <= budgetIDR).toList()
          ..sort((a, b) => a.price.compareTo(b.price));
    if (filteredProducts.length > 3) {
      filteredProducts = filteredProducts.sublist(0, 3);
    }

    setState(() {
      isCalculated = true;
    });
  }

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Color(0xFFF9F9F9),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Coffee Budget Recommendation",
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Info
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFC67C4E), Color(0xFFD2824B)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Text("🌏", style: TextStyle(fontSize: 40)),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Find Your Indonesian Coffee!",
                                  style: GoogleFonts.sora(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Enter your budget and currency to get coffee recommendations you can buy in Indonesia.",
                                  style: GoogleFonts.sora(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32),

                    // Input Budget, Currency
                    Text(
                      "Enter Your Coffee Budget",
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        // Mata uang dropdown
                        Container(
                          width: 160,
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCurrency,
                              isExpanded: true,
                              onChanged: (value) {
                                final currency = currencies.firstWhere(
                                  (c) => c['code'] == value,
                                );
                                setState(() {
                                  selectedCurrency = value!;
                                  selectedRate = currency['rate'] * 1.0;
                                  isCalculated = false;
                                });
                              },
                              items:
                                  currencies.map<DropdownMenuItem<String>>((
                                    currency,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: currency['code'],
                                      child: Text(
                                        "${currency['name']} (${currency['code']})",
                                        style: GoogleFonts.sora(fontSize: 14),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        // Budget
                        Expanded(
                          child: TextField(
                            controller: _budgetController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "e.g. 10",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFFC67C4E),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    // Nilai tukar (tidak bisa diubah user)
                    Text(
                      "Exchange Rate (1 $selectedCurrency = ${selectedRate.toStringAsFixed(0)} Rupiah)",
                      style: GoogleFonts.sora(fontSize: 14),
                    ),

                    SizedBox(height: 24),

                    // Info konversi ke IDR
                    if (_budgetController.text.isNotEmpty)
                      Text(
                        "≈ Rp ${(double.tryParse(_budgetController.text) != null ? (double.parse(_budgetController.text) * selectedRate).toStringAsFixed(0) : '0')}",
                        style: GoogleFonts.sora(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC67C4E),
                        ),
                      ),

                    SizedBox(height: 32),

                    // Tombol Hitung
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              calculateRecommendation();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Color(0xFFC67C4E),
                            ),
                            child: Text(
                              "Get Recommendations",
                              style: GoogleFonts.sora(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32),

                    // Daftar produk (setelah dihitung)
                    if (isCalculated && filteredProducts.isNotEmpty) ...{
                      Text(
                        "Recommended Coffee Products:",
                        style: GoogleFonts.sora(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),
                      ...filteredProducts.map((product) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Gambar produk
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  product.imageUrl ??
                                      'https://via.placeholder.com/80',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 16),
                              // Info produk
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: GoogleFonts.sora(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "${product.price} Rupiah",
                                      style: GoogleFonts.sora(
                                        fontSize: 14,
                                        color: Color(0xFFC67C4E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    } else if (isCalculated && filteredProducts.isEmpty) ...{
                      Center(
                        child: Text(
                          "No products found within your budget.",
                          style: GoogleFonts.sora(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    },
                  ],
                ),
              ),
    );
  }
}
