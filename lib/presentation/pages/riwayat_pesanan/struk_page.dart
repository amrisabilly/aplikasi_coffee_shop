import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../../controllers/order_history_controller.dart';

class StrukPage extends StatefulWidget {
  final int orderId;

  const StrukPage({super.key, required this.orderId});

  @override
  State<StrukPage> createState() => _StrukPageState();
}

class _StrukPageState extends State<StrukPage> {
  final OrderHistoryController orderController = OrderHistoryController();
  Map<String, dynamic>? orderDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    final detail = await orderController.getOrderDetail(widget.orderId);
    setState(() {
      orderDetail = detail;
      isLoading = false;
    });
  }

  void _copyOrderId() {
    Clipboard.setData(ClipboardData(text: widget.orderId.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ID disalin ke clipboard'),
        backgroundColor: Color(0xFFC67C4E),
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

    if (orderDetail == null) {
      return Scaffold(
        backgroundColor: Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Color(0xFFF9F9F9),
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: Colors.black87),
          ),
          title: Text('Struk Pembelian'),
        ),
        body: Center(child: Text('Data pesanan tidak ditemukan')),
      );
    }

    final orderDate = DateTime.parse(orderDetail!['created_at']);
    final items = orderDetail!['items'] as List<dynamic>? ?? [];
    final subtotal = items.fold<double>(0, (sum, item) {
      return sum + (item['qty'] * item['price']);
    });
    final discount = orderDetail!['discount'] ?? 0;
    final discountAmount = subtotal * discount / 100;
    final total = orderDetail!['total'];

    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Color(0xFFC67C4E),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Struk Pembelian',
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFFC67C4E).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_cafe,
                          color: Color(0xFFC67C4E),
                          size: 32,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'KopiKelana',
                        style: GoogleFonts.sora(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC67C4E),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Struk Pembelian',
                        style: GoogleFonts.sora(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.grey.shade300,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Order Info
                _buildInfoRow('Order ID', '#${widget.orderId}', true),
                _buildInfoRow(
                  'Tanggal',
                  '${orderDate.day}/${orderDate.month}/${orderDate.year}',
                ),
                _buildInfoRow(
                  'Waktu',
                  '${orderDate.hour.toString().padLeft(2, '0')}:${orderDate.minute.toString().padLeft(2, '0')}',
                ),
                _buildInfoRow('Status', _getStatusText(orderDetail!['status'])),
                _buildInfoRow(
                  'Metode Bayar',
                  orderDetail!['payment_method'] ?? 'Cash',
                ),

                SizedBox(height: 24),

                // Items
                Text(
                  'Detail Pesanan',
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),

                ...items.map((item) {
                  final itemTotal = item['qty'] * item['price'];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['product']?['name'] ??
                                    'Produk ${item['product_id']}',
                                style: GoogleFonts.sora(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${item['qty']}x @ Rp ${item['price']}',
                                style: GoogleFonts.sora(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Rp ${itemTotal.toStringAsFixed(0)}',
                          style: GoogleFonts.sora(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 16),

                // Summary
                _buildSummaryRow(
                  'Subtotal',
                  'Rp ${subtotal.toStringAsFixed(0)}',
                ),
                if (discount > 0) ...[
                  _buildSummaryRow(
                    'Diskon ($discount%)',
                    '- Rp ${discountAmount.toStringAsFixed(0)}',
                    isDiscount: true,
                  ),
                ],
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFFC67C4E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildSummaryRow(
                    'Total',
                    'Rp ${total.toString()}',
                    isTotal: true,
                  ),
                ),

                SizedBox(height: 32),

                // Footer
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Terima kasih atas pesanan Anda!',
                        style: GoogleFonts.sora(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC67C4E),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Nikmati kopi terbaik dari KopiKelana',
                        style: GoogleFonts.sora(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [bool copyable = false]) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.sora(fontSize: 14, color: Colors.grey.shade600),
          ),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (copyable) ...[
                SizedBox(width: 8),
                GestureDetector(
                  onTap: _copyOrderId,
                  child: Icon(Icons.copy, size: 16, color: Color(0xFFC67C4E)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTotal ? 16 : 0, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.sora(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
              color:
                  isDiscount
                      ? Color(0xFFC67C4E)
                      : (isTotal ? Color(0xFFC67C4E) : Colors.black87),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color:
                  isDiscount
                      ? Color(0xFFC67C4E)
                      : (isTotal ? Color(0xFFC67C4E) : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'processing':
        return 'Sedang Diproses';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}
