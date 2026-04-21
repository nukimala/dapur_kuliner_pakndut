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

  static const _redTopLeft = Color(0xFFF91605);
  static const _redBottomRight = Color(0xFF631105);
  static const _orange = Color(0xFFF09E18);
  static const _bgCream = Color(0xFFF9F2E7);
  static const _textDark = Color(0xFF282828);
  static const _textGrey = Color(0xFFC0BAB2);

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
      if (!mounted) return;
      if (e.toString().contains('email-not-verified')) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Verifikasi Email'),
            content: const Text('Kamu perlu verifikasi email terlebih dahulu.\nApakah kamu ingin dikirimkan verifikasi ulang?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Tidak, kembali')),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                    );
                    final firebaseUser = FirebaseAuth.instance.currentUser;
                    if (firebaseUser != null) await firebaseUser.sendEmailVerification();
                    await FirebaseAuth.instance.signOut();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email verifikasi ulang telah dikirim!'), backgroundColor: Colors.green),
                    );
                  } catch (resendErr) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $resendErr'), backgroundColor: Colors.red),
                    );
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
      backgroundColor: _bgCream,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_redTopLeft, _redBottomRight],
                    ),
                  ),
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40, bottom: 30, left: 24, right: 24),
                  child: Column(
                    children: [
                      Container(
                        width: 130, height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: const DecorationImage(
                            image: AssetImage('assets/icons/pakndut.png'),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 15, offset: const Offset(0, 5)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Login', style: GoogleFonts.nunito(fontSize: 34, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      const SizedBox(height: 2),
                      Text('Dapur Kuliner Pak Ndut', textAlign: TextAlign.center, style: GoogleFonts.nunito(fontSize: 18, color: _orange, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      const SizedBox(height: 6),
                      Text('Dapur Rasa Lokal, Kualitas Bintang Lima ⭐',
                          style: GoogleFonts.nunito(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EMAIL / NO. WHATSAPP', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w900, color: _textDark, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  _buildInputField(controller: _emailController, hint: 'Masukkan email kamu',
                      iconPath: Icons.email, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  
                  Text('KATA SANDI', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w900, color: _textDark, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 18),
                        const Icon(Icons.lock, color: _textGrey, size: 22),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: GoogleFonts.nunito(color: _textGrey, fontSize: 18, letterSpacing: 3),
                              border: InputBorder.none, isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 20),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: _textGrey, size: 22),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordScreen())),
                      child: Text('Lupa Kata Sandi?', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: _orange)),
                    ),
                  ),

                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity, height: 56,
                    decoration: BoxDecoration(
                      color: _orange,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: _orange.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Masuk Sekarang', style: GoogleFonts.nunito(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  Center(child: Text('atau masuk dengan', style: GoogleFonts.nunito(fontSize: 13, color: _textGrey, fontWeight: FontWeight.w800))),
                  const SizedBox(height: 20),
                  
                  Container(
                    width: double.infinity, height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        // Google Login placeholder
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Google belum diimplementasi')));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildGoogleIcon(),
                          const SizedBox(width: 12),
                          Text('Google', style: GoogleFonts.nunito(fontSize: 16, color: _textDark, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Center(
                    child: GestureDetector(
                       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                       child: RichText(
                         text: TextSpan(
                           style: GoogleFonts.nunito(fontSize: 13, color: _textGrey, fontWeight: FontWeight.w800),
                           children: [
                             const TextSpan(text: 'Belum punya akun? '),
                             TextSpan(text: 'Daftar Sekarang', style: GoogleFonts.nunito(color: _orange, fontWeight: FontWeight.w900)),
                           ],
                         ),
                       ),
                    ),
                  ),
                  const SizedBox(height: 40),
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
    required IconData iconPath,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
          Icon(iconPath, color: _textGrey, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller, keyboardType: keyboardType,
              style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.nunito(color: _textGrey, fontSize: 15, fontWeight: FontWeight.w800),
                border: InputBorder.none, isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 24, height: 24,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Color(0xFFEA4335), // Google Red
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Roboto',
          ),
        )
      ),
    );
  }
}
