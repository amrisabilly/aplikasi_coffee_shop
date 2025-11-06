import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class GamiFikasi extends StatefulWidget {
  final Function(int)? onPointsEarned; // Callback untuk mengirim poin

  const GamiFikasi({super.key, this.onPointsEarned});

  @override
  State<GamiFikasi> createState() => _GamiFikasiState();
}

class _GamiFikasiState extends State<GamiFikasi> {
  int points = 0;
  StreamSubscription? _accelSub;
  double _lastX = 0, _lastY = 0, _lastZ = 0;
  DateTime _lastShake = DateTime.now();

  @override
  void initState() {
    super.initState();
    _accelSub = accelerometerEvents.listen((event) {
      double deltaX = (event.x - _lastX).abs();
      double deltaY = (event.y - _lastY).abs();
      double deltaZ = (event.z - _lastZ).abs();

      // Deteksi goyangan kuat (shake)
      if ((deltaX > 2 || deltaY > 2 || deltaZ > 2) &&
          DateTime.now().difference(_lastShake) > Duration(milliseconds: 400)) {
        setState(() {
          points += 1;
        });
        _lastShake = DateTime.now();
      }

      _lastX = event.x;
      _lastY = event.y;
      _lastZ = event.z;
    });
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    super.dispose();
  }

  void _finishGame() {
    // Kirim poin yang didapat ke ProfilePage
    if (widget.onPointsEarned != null) {
      widget.onPointsEarned!(points);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _finishGame,
        ),
        title: Text(
          'Shake Game',
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFFC67C4E),
        elevation: 0,
        actions: [
          // Tombol selesai
          TextButton(
            onPressed: _finishGame,
            child: Text(
              'Selesai',
              style: GoogleFonts.sora(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFC67C4E), Color(0xFFD2824B)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon shake
              Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.vibration, size: 80, color: Colors.white),
              ),
              SizedBox(height: 40),
              Text(
                'Goyangkan HP untuk\nmenambah poin!',
                textAlign: TextAlign.center,
                style: GoogleFonts.sora(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 40),
              // Poin counter
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '$points',
                      style: GoogleFonts.sora(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC67C4E),
                      ),
                    ),
                    Text(
                      'Poin Didapat',
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              // Instruksi
              Container(
                margin: EdgeInsets.symmetric(horizontal: 40),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Goyang HP dengan kuat untuk mendapat poin lebih banyak!',
                        style: GoogleFonts.sora(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
