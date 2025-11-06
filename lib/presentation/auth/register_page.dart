import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Model dan fetch data Registrasi
import '../../controllers/auth/registrasi_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isAgreed = false;

  final registrasiController = RegistrasiController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),

                  Row(
                    children: [
                      IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/landing');
                              }
                            },
                          )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 400.ms)
                          .slideX(begin: -0.3, end: 0),
                    ],
                  ),

                  SizedBox(height: 30),

                  // Judul
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Headline
                      Text(
                            "Buat Akun Barumu",
                            style: GoogleFonts.sora(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),

                      SizedBox(height: 8),

                      Text(
                            "Hanya perlu beberapa langkah untuk memulai petualanganmu",
                            style: GoogleFonts.sora(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),
                    ],
                  ),

                  SizedBox(height: 40),

                  Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Input Nama Lengkap
                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: "Nama Lengkap",
                                hintText: "Masukkan nama lengkap Anda",
                                labelStyle: GoogleFonts.sora(
                                  color: Colors.grey.shade600,
                                ),
                                hintStyle: GoogleFonts.sora(
                                  color: Colors.grey.shade400,
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: Color(0xFFC67C4E),
                                ),
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
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),

                            SizedBox(height: 20),

                            // Input Email
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: "Email",
                                hintText: "Masukkan email aktif Anda",
                                labelStyle: GoogleFonts.sora(
                                  color: Colors.grey.shade600,
                                ),
                                hintStyle: GoogleFonts.sora(
                                  color: Colors.grey.shade400,
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: Color(0xFFC67C4E),
                                ),
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
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),

                            SizedBox(height: 20),

                            // Input Password
                            TextField(
                              controller: passwordController,
                              obscureText: !isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: "Buat Password",
                                hintText: "Minimal 8 karakter",
                                labelStyle: GoogleFonts.sora(
                                  color: Colors.grey.shade600,
                                ),
                                hintStyle: GoogleFonts.sora(
                                  color: Colors.grey.shade400,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFFC67C4E),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
                                  },
                                ),
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
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),

                            SizedBox(height: 24),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: isAgreed,
                                  onChanged: (value) {
                                    setState(() {
                                      isAgreed = value!;
                                    });
                                  },
                                  activeColor: Color(0xFFC67C4E),
                                  checkColor: Colors.white,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 12),
                                    child: RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.sora(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                        children: [
                                          TextSpan(text: "Saya setuju dengan "),
                                          TextSpan(
                                            text: "Syarat & Ketentuan",
                                            style: TextStyle(
                                              color: Color(0xFFC67C4E),
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          TextSpan(text: " dan "),
                                          TextSpan(
                                            text: "Kebijakan Privasi",
                                            style: TextStyle(
                                              color: Color(0xFFC67C4E),
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          TextSpan(text: "."),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 30),

                            // Tombol Daftar Utama
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isAgreed
                                          ? Color(0xFFC67C4E)
                                          : Colors.grey.shade400,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                                onPressed:
                                    isAgreed
                                        ? () async {
                                          final registrasi = Registrasi(
                                            full_name: nameController.text,
                                            email: emailController.text,
                                            password: passwordController.text,
                                          );
                                          final success =
                                              await registrasiController
                                                  .registerUser(
                                                    registrasi,
                                                  ); // Pakai controller
                                          if (success) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Berhasil Daftar",
                                                ),
                                              ),
                                            );
                                            context.go('/login');
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Pendaftaran Gagal!",
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                        : null,
                                child: Text(
                                  "Daftar",
                                  style: GoogleFonts.sora(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 20),

                            // Divider "ATAU"
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.grey.shade400),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    "ATAU",
                                    style: GoogleFonts.sora(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Colors.grey.shade400),
                                ),
                              ],
                            ),

                            SizedBox(height: 20),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),

                  SizedBox(height: 30),

                  // F. Ajakan untuk Masuk
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sudah punya akun? ",
                        style: GoogleFonts.sora(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: Text(
                          "Masuk di sini",
                          style: GoogleFonts.sora(
                            color: Color(0xFFC67C4E),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFC67C4E),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 900.ms, duration: 500.ms),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
