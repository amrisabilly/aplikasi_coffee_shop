import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_satu/presentation/pages/main/profile/game/game_page.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project_satu/controllers/profile_controller.dart';
import 'package:project_satu/presentation/pages/main/profile/riwayat_pesanan/riwayat_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController profileController = ProfileController();
  final ImagePicker _picker = ImagePicker();

  File? _profileImage;
  String? _networkPhotoUrl;
  String userName = "";
  String userEmail = "";
  int userPoints = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await profileController.syncUserFromDatabase();
    final data = await profileController.loadUserData();
    setState(() {
      userName = data['userName'];
      userEmail = data['userEmail'];
      userPoints = data['userPoints'];
      _networkPhotoUrl = data['photoUrl'];
      final imagePath = data['imagePath'];
      if (imagePath != null && imagePath.isNotEmpty) {
        _profileImage = File(imagePath);
      }
      isLoading = false;
    });
  }

  Future<void> _saveProfileImage(String path) async {
    await profileController.saveProfileImage(path);
  }

  Future<void> _savePhotoUrl(String url) async {
    await profileController.savePhotoUrl(url);
    setState(() => _networkPhotoUrl = url);
  }

  Future<String?> _uploadProfileImage(File file) async {
    final token = await profileController.getToken();
    return await profileController.uploadProfileImage(file, token);
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Ambil dari Kamera'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1024,
                    maxHeight: 1024,
                  );
                  if (image != null) {
                    final file = File(image.path);
                    setState(() => _profileImage = file);
                    await _saveProfileImage(file.path);
                    final uploadedUrl = await _uploadProfileImage(file);
                    if (uploadedUrl != null) await _savePhotoUrl(uploadedUrl);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Pilih dari Galeri'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1024,
                    maxHeight: 1024,
                  );
                  if (image != null) {
                    final file = File(image.path);
                    setState(() => _profileImage = file);
                    await _saveProfileImage(file.path);
                    final uploadedUrl = await _uploadProfileImage(file);
                    if (uploadedUrl != null) await _savePhotoUrl(uploadedUrl);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _logout() async {
    await profileController.logout();
    if (!mounted) return;
    context.go('/login');
  }

  void _addPointsFromGame(int earnedPoints) async {
    if (earnedPoints <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Belum ada poin yang didapat.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final success = await profileController.addPoints(earnedPoints);
    if (success) {
      await _loadUserData(); // refresh UI
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selamat! Anda mendapat $earnedPoints poin!'),
          backgroundColor: Color(0xFFC67C4E),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan poin ke server.'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        backgroundColor: Color(0xFFF9F9F9),
        elevation: 0,
        automaticallyImplyLeading: false, // Hilangkan tombol back
        centerTitle: true, // Center title
        title: Text(
          'Profile',
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
            // Profile Header
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
                children: [
                  // Profile Picture
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage:
                            _profileImage != null
                                ? FileImage(_profileImage!)
                                : (_networkPhotoUrl != null &&
                                        _networkPhotoUrl!.isNotEmpty
                                    ? NetworkImage(_networkPhotoUrl!)
                                        as ImageProvider
                                    : null),
                        child:
                            (_profileImage == null &&
                                    (_networkPhotoUrl == null ||
                                        _networkPhotoUrl!.isEmpty))
                                ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey.shade600,
                                )
                                : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFFC67C4E),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // User Info
                  Text(
                    userName.isNotEmpty ? userName : "User",
                    style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    userEmail.isNotEmpty ? userEmail : "user@email.com",
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Points Section
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
                  Icon(Icons.stars, color: Colors.white, size: 40),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Poin Rewards',
                          style: GoogleFonts.sora(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '$userPoints Poin',
                          style: GoogleFonts.sora(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Kumpulkan lebih banyak untuk diskon!',
                          style: GoogleFonts.sora(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => GamiFikasi(
                                onPointsEarned: _addPointsFromGame,
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFFC67C4E),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Main Game',
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Menu Options
            Container(
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
                children: [
                  _buildMenuItem(
                    icon: Icons.redeem,
                    title: 'Tukar Poin',
                    subtitle: 'Gunakan poin untuk diskon',
                    onTap: () {
                      _showRedeemDialog();
                    },
                  ),
                  Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.history,
                    title: 'Riwayat Pesanan',
                    subtitle: 'Lihat pesanan sebelumnya',
                    onTap: () {
                      context.go('/riwayat');
                    },
                  ),
                  Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.code,
                    title: 'Developer',
                    subtitle: 'Tentang pengembang aplikasi',
                    onTap: () {
                      context.go('/developer');
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Logout Button - Pindah ke sini
            Container(
              width: double.infinity,
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
              child: _buildMenuItem(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Keluar dari akun',
                onTap: _logout,
                isLogout: true, // Parameter baru untuk styling logout
              ),
            ),

            SizedBox(height: 30),

            // App Version
            Text(
              'KopiKelana v1.0.0',
              style: GoogleFonts.sora(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false, // Parameter baru
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isLogout
                  ? Colors.red.withOpacity(0.1)
                  : Color(0xFFC67C4E).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isLogout ? Colors.red : Color(0xFFC67C4E),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.sora(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isLogout ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.sora(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showRedeemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tukar Poin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Poin Anda: $userPoints'),
              SizedBox(height: 16),
              Text('Pilih reward:'),
              SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.local_offer, color: Color(0xFFC67C4E)),
                title: Text('Diskon 10%'),
                subtitle: Text('50 Poin'),
                enabled: userPoints >= 50,
                onTap:
                    userPoints >= 50
                        ? () async {
                          final success = await profileController
                              .redeemPointsFromDatabase(50);
                          if (success) {
                            final prefs = await SharedPreferences.getInstance();
                            // Ambil diskon yang sudah ada dan tambahkan
                            final currentDiscount =
                                prefs.getInt('active_discount') ?? 0;
                            await prefs.setInt(
                              'active_discount',
                              currentDiscount + 10,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Diskon 10% berhasil diklaim!'),
                                backgroundColor: Color(0xFFC67C4E),
                              ),
                            );
                            await _loadUserData(); // Refresh data
                          } else {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal menukar poin!')),
                            );
                          }
                        }
                        : null,
              ),
              ListTile(
                leading: Icon(Icons.local_offer, color: Color(0xFFC67C4E)),
                title: Text('Diskon 20%'),
                subtitle: Text('100 Poin'),
                enabled: userPoints >= 100,
                onTap:
                    userPoints >= 100
                        ? () async {
                          final success = await profileController
                              .redeemPointsFromDatabase(100);
                          if (success) {
                            final prefs = await SharedPreferences.getInstance();
                            // Ambil diskon yang sudah ada dan tambahkan
                            final currentDiscount =
                                prefs.getInt('active_discount') ?? 0;
                            await prefs.setInt(
                              'active_discount',
                              currentDiscount + 20,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Diskon 20% berhasil diklaim!'),
                                backgroundColor: Color(0xFFC67C4E),
                              ),
                            );
                            await _loadUserData(); // Refresh data
                          } else {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal menukar poin!')),
                            );
                          }
                        }
                        : null,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}
