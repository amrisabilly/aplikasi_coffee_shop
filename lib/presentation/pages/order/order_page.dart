import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_notifications/awesome_notifications.dart';
import '../../../controllers/detail_controller.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final DetailController detailController = DetailController();
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;

  String _selectedPayment = 'Cash';
  final List<String> _paymentMethods = ['Cash', 'Wallet'];

  int _activeDiscount = 0;
  bool _isDiscountApplied = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
    _loadDiscount();
  }

  Future<void> _loadCart() async {
    final items = await detailController.getCart();
    setState(() {
      cartItems = items;
      isLoading = false;
    });
  }

  Future<void> _loadDiscount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _activeDiscount = prefs.getInt('active_discount') ?? 0;
    });
  }

  Future<void> _removeItem(int index) async {
    await detailController.removeFromCart(index);
    await _loadCart();
  }

  Future<void> _updateQuantity(int index, int newQty) async {
    if (newQty <= 0) {
      await _removeItem(index);
      return;
    }

    cartItems[index]['qty'] = newQty;
    final prefs = await detailController.getPrefs();
    final cartKey = await detailController.getCartKey(); // Tambahkan baris ini
    final cartStrings = cartItems.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList(cartKey, cartStrings); // Simpan ke key user
    setState(() {});
  }

  void _showOrderDetail(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Detail Pesanan',
            style: GoogleFonts.sora(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hapus baris product_id dari tampilan detail
              _buildDetailRow('Nama Produk', item['product_name'] ?? 'Unknown'),
              _buildDetailRow('Jumlah', '${item['qty']}'),
              _buildDetailRow('Ukuran', item['size'] ?? '-'),
              _buildDetailRow('Suhu', item['temperature'] ?? '-'),
              _buildDetailRow('Harga Satuan', 'Rp ${item['price']}'),
              _buildDetailRow(
                'Total Harga',
                'Rp ${(num.parse(item['price'].toString()) * int.parse(item['qty'].toString())).toStringAsFixed(0)}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Tutup',
                style: GoogleFonts.sora(color: Color(0xFFC67C4E)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.sora(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value, style: GoogleFonts.sora(fontSize: 12))),
        ],
      ),
    );
  }

  double _getTotalPrice() {
    return cartItems.fold<double>(0, (sum, item) {
      final price = num.tryParse(item['price'].toString()) ?? 0;
      final qty = int.tryParse(item['qty'].toString()) ?? 1;
      return sum + (price * qty);
    });
  }

  double _getTotalAfterDiscount() {
    final total = _getTotalPrice();
    if (_activeDiscount > 0 && _isDiscountApplied) {
      return total * (1 - _activeDiscount / 100);
    }
    return total;
  }

  Future<void> _showOrderNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'order_channel',
        title: 'Pesanan Berhasil!',
        body: 'Pesanan kopi kamu sedang diproses.',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFF9F9F9),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        toolbarHeight: 50,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.only(left: 30, top: 20),
          child: IconButton(
            onPressed: () => context.go('/menu'),
            icon: const Icon(Icons.keyboard_arrow_left_sharp),
          ),
        ),
        title: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            "Order",
            style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor: Color(0xFFF9F9F9),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Pick Up button (tetap sama)
            Column(
              children: [
                SizedBox(height: 24),
                Divider(
                  color: Color(0xFFE3E3E3),
                  thickness: 2,
                  indent: 10,
                  endIndent: 10,
                ),
                SizedBox(height: 10),
              ],
            ),

            // Daftar produk dari cart (dinamis)
            Expanded(
              child:
                  cartItems.isEmpty
                      ? Center(
                        child: Text(
                          "Keranjang kosong",
                          style: GoogleFonts.sora(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          final qty = int.tryParse(item['qty'].toString()) ?? 1;
                          final price =
                              num.tryParse(item['price'].toString()) ?? 0;
                          final totalItemPrice = price * qty;

                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Gambar produk
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Color(0xFFF5F5F5),
                                    border: Border.all(
                                      color: Color(0xFFE8E8E8),
                                      width: 1,
                                    ),
                                  ),
                                  child:
                                      item['image'] != null &&
                                              item['image']
                                                  .toString()
                                                  .isNotEmpty
                                          ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.network(
                                              item['image'],
                                              fit: BoxFit.cover,
                                              width: 64,
                                              height: 64,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Icon(
                                                    Icons.local_cafe,
                                                    color: Color(0xFFC67C4E),
                                                    size: 28,
                                                  ),
                                            ),
                                          )
                                          : Icon(
                                            Icons.local_cafe,
                                            color: Color(0xFFC67C4E),
                                            size: 28,
                                          ),
                                ),

                                SizedBox(width: 16),

                                // Detail produk
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Nama produk
                                      GestureDetector(
                                        onTap: () => _showOrderDetail(item),
                                        child: Text(
                                          item['product_name'] ??
                                              'Unknown Product',
                                          style: GoogleFonts.sora(
                                            color: Colors.black87,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      SizedBox(height: 4),

                                      // Size dan temperature
                                      GestureDetector(
                                        onTap: () => _showOrderDetail(item),
                                        child: Text(
                                          "${item['size'] ?? 'M'} • ${item['temperature'] ?? 'Hot'}",
                                          style: GoogleFonts.sora(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF9B9B9B),
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 8),

                                      // Harga dan controls
                                      Row(
                                        children: [
                                          // Harga total item
                                          Text(
                                            "Rp ${totalItemPrice.toStringAsFixed(0)}",
                                            style: GoogleFonts.sora(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFC67C4E),
                                            ),
                                          ),

                                          Spacer(),

                                          // Quantity controls
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Color(0xFFF9F9F9),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Color(0xFFE8E8E8),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Tombol minus
                                                InkWell(
                                                  onTap:
                                                      () => _updateQuantity(
                                                        index,
                                                        qty - 1,
                                                      ),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    child: Icon(
                                                      Icons.remove,
                                                      size: 16,
                                                      color:
                                                          qty > 1
                                                              ? Colors.black87
                                                              : Colors.grey,
                                                    ),
                                                  ),
                                                ),

                                                // Quantity
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                                  child: Text(
                                                    "$qty",
                                                    style: GoogleFonts.sora(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),

                                                // Tombol plus
                                                InkWell(
                                                  onTap:
                                                      () => _updateQuantity(
                                                        index,
                                                        qty + 1,
                                                      ),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    child: Icon(
                                                      Icons.add,
                                                      size: 16,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(width: 8),

                                // Tombol hapus
                                InkWell(
                                  onTap: () => _removeItem(index),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red.shade400,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),

            SizedBox(height: 10),
            Divider(
              color: Color(0xFFE3E3E3),
              thickness: 2,
              indent: 10,
              endIndent: 10,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed:
                  (_activeDiscount > 0 && !_isDiscountApplied)
                      ? () {
                        setState(() {
                          _isDiscountApplied = true;
                        });
                      }
                      : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset("assets/images/icons.png"),
                  Text(
                    _activeDiscount > 0 && !_isDiscountApplied
                        ? "Apply $_activeDiscount% Discount"
                        : _isDiscountApplied
                        ? "$_activeDiscount% Discount Applied"
                        : "No Discount Available",
                    style: GoogleFonts.sora(
                      color:
                          _activeDiscount > 0 ? Color(0xFFC67C4E) : Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    _isDiscountApplied
                        ? Icons.check_circle
                        : Icons.keyboard_arrow_right_outlined,
                    size: 20,
                    color: _isDiscountApplied ? Color(0xFFC67C4E) : Colors.grey,
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                fixedSize: Size(327, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color:
                        _activeDiscount > 0
                            ? Color(0xFFC67C4E)
                            : Color(0xFFEDEDED),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Payment Summary",
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Harga sebelum diskon
                    Row(
                      children: [
                        Text(
                          "Subtotal",
                          style: GoogleFonts.sora(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Spacer(),
                        Text(
                          "Rp ${_getTotalPrice().toStringAsFixed(0)}",
                          style: GoogleFonts.sora(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            decoration:
                                _isDiscountApplied
                                    ? TextDecoration.lineThrough
                                    : null,
                            color:
                                _isDiscountApplied ? Colors.grey : Colors.black,
                          ),
                        ),
                      ],
                    ),

                    // Tampilkan diskon jika ada
                    if (_isDiscountApplied) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "Diskon ($_activeDiscount%)",
                            style: GoogleFonts.sora(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFC67C4E),
                            ),
                          ),
                          Spacer(),
                          Text(
                            "- Rp ${(_getTotalPrice() * _activeDiscount / 100).toStringAsFixed(0)}",
                            style: GoogleFonts.sora(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFC67C4E),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Divider(thickness: 1, color: Colors.grey.shade300),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "Total",
                            style: GoogleFonts.sora(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          Text(
                            "Rp ${_getTotalAfterDiscount().toStringAsFixed(0)}",
                            style: GoogleFonts.sora(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFC67C4E),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Jika tidak ada diskon, tampilkan total normal
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "Total",
                            style: GoogleFonts.sora(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          Text(
                            "Rp ${_getTotalPrice().toStringAsFixed(0)}",
                            style: GoogleFonts.sora(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFC67C4E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 165,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wallet_outlined,
                    color: Color(0xFFC67C4E),
                    size: 20,
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Metode Pembayaran",
                        style: GoogleFonts.sora(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Rp ${_getTotalAfterDiscount().toStringAsFixed(0)}",
                        style: GoogleFonts.sora(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  DropdownButton<String>(
                    value: _selectedPayment,
                    items:
                        _paymentMethods
                            .map(
                              (method) => DropdownMenuItem(
                                value: method,
                                child: Text(method),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedPayment = value;
                        });
                      }
                    },
                    underline: SizedBox(),
                    style: GoogleFonts.sora(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    icon: Icon(Icons.keyboard_arrow_down_sharp, size: 20),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final total = _getTotalPrice();
                    final discount = _isDiscountApplied ? _activeDiscount : 0;
                    final totalAfterDiscount = _getTotalAfterDiscount();

                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('user_token') ?? '';
                    final userId = prefs.getInt('user_id');

                    // Siapkan data items
                    final items =
                        cartItems
                            .map(
                              (item) => {
                                'product_id': item['product_id'],
                                'qty': item['qty'],
                                'price': item['price'],
                              },
                            )
                            .toList();

                    final response = await http.post(
                      Uri.parse(
                        'https://monitoringweb.decoratics.id/api/coffe/orders',
                      ),
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $token',
                      },
                      body: jsonEncode({
                        'user_id': userId,
                        'items': items,
                        'status': 'pending',
                        'payment_method': _selectedPayment,
                        'discount': discount,
                      }),
                    );

                    if (response.statusCode == 200 ||
                        response.statusCode == 201) {
                      // Hapus diskon setelah checkout
                      if (_isDiscountApplied) {
                        await prefs.remove('active_discount');
                        setState(() {
                          _activeDiscount = 0;
                          _isDiscountApplied = false;
                        });
                      }
                      // Hapus cart setelah order berhasil
                      final cartKey = await detailController.getCartKey();
                      await prefs.remove(cartKey);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Order berhasil!'),
                          backgroundColor: Color(0xFFC67C4E),
                        ),
                      );
                      // Refresh cart
                      await _loadCart();

                      // Tambahkan delay 3 detik lalu tampilkan notifikasi
                      Future.delayed(Duration(seconds: 3), () {
                        _showOrderNotification();
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal membuat order!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Checkout Now",
                    style: GoogleFonts.sora(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Color(0xFFC67C4E),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
