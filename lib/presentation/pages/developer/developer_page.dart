import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DeveloperPage extends StatelessWidget {
  const DeveloperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Color(0xFFF9F9F9),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/profile');
              }
            },
          ),
        ),
        centerTitle: true,
        title: Text(
          'Developer',
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Developer Profile Card
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFFC67C4E),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey.shade200,

                      backgroundImage: AssetImage(
                        'assets/images/profile_billy.png',
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Developer Name
                  Text(
                    'Amri Sabilly', // Ganti dengan nama asli
                    style: GoogleFonts.sora(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Student ID & Major
                  Text(
                    'NIM: 124230147', // Ganti dengan NIM asli
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      color: Color(0xFFC67C4E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Sistem Informasi', // Ganti dengan jurusan asli
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // About Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFFC67C4E)),
                      SizedBox(width: 12),
                      Text(
                        'Tentang Aplikasi',
                        style: GoogleFonts.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'KopiKelana adalah aplikasi pemesanan kopi yang dikembangkan sebagai tugas akhir mata kuliah Pemrograman Aplikasi. Aplikasi ini memungkinkan pengguna untuk memesan berbagai jenis kopi dengan mudah dan nyaman.',
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Course Reflection
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFC67C4E), Color(0xFFD2824B)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.school, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Pesan & Kesan Mata Kuliah',
                        style: GoogleFonts.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Mata kuliah Pemrograman Aplikasi telah memberikan pengalaman berharga dalam mengembangkan aplikasi mobile menggunakan Flutter. Melalui mata kuliah ini, saya belajar:',
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.95),
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildBulletPoint('Konsep dasar Flutter dan Dart'),
                  _buildBulletPoint('State management dan navigation'),
                  _buildBulletPoint('Integrasi dengan REST API'),
                  _buildBulletPoint('UI/UX design principles'),
                  _buildBulletPoint('Best practices dalam mobile development'),
                  SizedBox(height: 16),
                  Text(
                    'Terima kasih kepada dosen pengampu yang telah membimbing dan memberikan ilmu yang sangat bermanfaat. Semoga ilmu yang didapat dapat terus dikembangkan dan bermanfaat di masa depan.',
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.95),
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Technical Details
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.build_circle_outlined,
                        color: Color(0xFFC67C4E),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Teknologi yang Digunakan',
                        style: GoogleFonts.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildTechItem('Flutter', 'Framework UI cross-platform'),
                  _buildTechItem('Dart', 'Bahasa pemrograman'),
                  _buildTechItem('REST API', 'Backend integration'),
                  _buildTechItem('SharedPreferences', 'Local storage'),
                  _buildTechItem('GoRouter', 'Navigation management'),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Footer
            Text(
              '© 2024 KopiKelana Developer\nDibuat dengan ❤️ untuk Pemrograman Aplikasi',
              textAlign: TextAlign.center,
              style: GoogleFonts.sora(
                fontSize: 12,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.sora(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.sora(
                fontSize: 14,
                color: Colors.white.withOpacity(0.95),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Color(0xFFC67C4E),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
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
    );
  }
}
