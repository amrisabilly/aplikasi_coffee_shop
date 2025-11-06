import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/auth/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  final userController = UserController();

  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Email dan password wajib diisi!');
      return;
    }

    try {
      final response = await userController.loginUser(email, password);

      if (response.token != null) {
        await userController.saveUserData(response.user ?? {}, response.token!);
        if (!mounted) return;
        context.go('/home');
      } else {
        _showError(
          response.message.isNotEmpty
              ? response.message
              : 'Email atau password salah!',
        );
      }
    } catch (e) {
      _showError('Login gagal: Email atau password salah!');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage("assets/images/bg.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Logo & Welcome
                  Column(
                    children: [
                      Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC67C4E),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.coffee,
                              size: 40,
                              color: Colors.white,
                            ),
                          )
                          .animate()
                          .scale(delay: 200.ms, duration: 600.ms)
                          .fadeIn(),
                      const SizedBox(height: 30),
                      Text(
                            "Selamat Datang Kembali",
                            style: GoogleFonts.sora(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),
                      const SizedBox(height: 8),
                      Text(
                            "Lanjutkan petualangan kopimu",
                            style: GoogleFonts.sora(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 600.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),
                    ],
                  ),
                  const SizedBox(height: 50),
                  // Form Login
                  Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Email
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: "Email",
                                hintText: "Masukkan email Anda",
                                labelStyle: GoogleFonts.sora(
                                  color: Colors.grey.shade600,
                                ),
                                hintStyle: GoogleFonts.sora(
                                  color: Colors.grey.shade400,
                                ),
                                prefixIcon: const Icon(
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
                                  borderSide: const BorderSide(
                                    color: Color(0xFFC67C4E),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Password
                            TextField(
                              controller: passwordController,
                              obscureText: !isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: "Password",
                                hintText: "Masukkan password Anda",
                                labelStyle: GoogleFonts.sora(
                                  color: Colors.grey.shade600,
                                ),
                                hintStyle: GoogleFonts.sora(
                                  color: Colors.grey.shade400,
                                ),
                                prefixIcon: const Icon(
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
                                  borderSide: const BorderSide(
                                    color: Color(0xFFC67C4E),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                            const SizedBox(height: 30),
                            // Tombol Login
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC67C4E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                                onPressed: _handleLogin,
                                child: Text(
                                  "Masuk",
                                  style: GoogleFonts.sora(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Divider "ATAU"
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.grey.shade400),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
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
                            const SizedBox(height: 20),
                            // Tombol Google Login (opsional, nonaktif)
                            // ...
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 30),
                  // Ajakan daftar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Belum punya akun? ",
                        style: GoogleFonts.sora(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go('/register');
                        },
                        child: Text(
                          "Daftar di sini",
                          style: GoogleFonts.sora(
                            color: const Color(0xFFC67C4E),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFFC67C4E),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 1000.ms, duration: 500.ms),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
