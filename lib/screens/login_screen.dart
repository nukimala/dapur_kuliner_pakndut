import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'admin_dashboard.dart';
import 'buyer_home_screen.dart';
import 'reset_password_screen.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  static const _red = Color(0xFFCC2A2A);
  static const _orange = Color(0xFFF5A623);
  static const _orange2 = Color(0xFFE8920A);

  void _login() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (user != null && mounted) {
        if (user.role == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BuyerHomeScreen()));
        }
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('email-not-verified')) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Verifikasi Email'),
              content: const Text('Kamu perlu verifikasi email terlebih dahulu.\nApakah kamu ingin dikirimkan verifikasi ulang?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tidak, kembali')),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      );
                      final firebaseUser = FirebaseAuth.instance.currentUser;
                      if (firebaseUser != null) await firebaseUser.sendEmailVerification();
                      await FirebaseAuth.instance.signOut();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Email verifikasi ulang telah dikirim!'), backgroundColor: Colors.green),
                        );
                      }
                    } catch (resendErr) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $resendErr'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: const Text('Kirim ulang'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_red, Color(0xFF8B1010), Color(0xFF5A0A0A)],
                ),
              ),
              width: double.infinity,
              padding: const EdgeInsets.only(top: 80, bottom: 50, left: 28, right: 28),
              child: Column(
                children: [
                  Container(
                    width: 88, height: 88,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_orange, _orange2]),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: _orange.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))],
                    ),
                    child: const Center(child: Text('🧑‍🍳', style: TextStyle(fontSize: 40))),
                  ),
                  const SizedBox(height: 16),
                  Text('Dapur Kuliner\nPak Ndut', textAlign: TextAlign.center, style: GoogleFonts.nunito(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text('Dapur Rasa Lokal, Kualitas Bintang Lima ⭐',
                      style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
                  const SizedBox(height: 7),
                  _buildInputField(controller: _emailController, hint: 'Masukkan email kamu',
                      icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 14),
                  Text('Kata Sandi', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
                  const SizedBox(height: 7),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF0EBE3), width: 2),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Icon(Icons.lock_outline, color: Color(0xFFBFB8B0), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: GoogleFonts.nunito(color: const Color(0xFFBFB8B0), fontSize: 13),
                              border: InputBorder.none, isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: const Color(0xFFBFB8B0), size: 18),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ],
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordScreen())),
                      child: Text('Lupa Kata Sandi?', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: _orange2)),
                    ),
                  ),

                  SizedBox(
                    width: double.infinity, height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_orange, _orange2]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: _orange.withValues(alpha: 0.45), blurRadius: 20, offset: const Offset(0, 6))],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text('🚀 Masuk Sekarang', style: GoogleFonts.nunito(fontSize: 16, color: Colors.white, letterSpacing: 0.5, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.nunito(fontSize: 13, color: const Color(0xFF9A9A9A)),
                          children: [
                            const TextSpan(text: 'Belum punya akun? '),
                            TextSpan(text: 'Daftar Sekarang', style: GoogleFonts.nunito(color: _orange2, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0EBE3), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(icon, color: const Color(0xFFBFB8B0), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller, keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.nunito(color: const Color(0xFFBFB8B0), fontSize: 13),
                border: InputBorder.none, isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
