import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';



class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'buyer';
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreed = true;

  static const _red = Color(0xFFCC2A2A);
  static const _orange = Color(0xFFF5A623);
  static const _orange2 = Color(0xFFE8920A);

  void _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password tidak cocok')));
      return;
    }
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap setujui Syarat & Ketentuan')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = await _authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        role: _selectedRole,
      );
      if (user != null && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Verifikasi Email'),
            content: Text('Kami telah mengirimkan email verifikasi ke\n${_emailController.text.trim()}\n\nHarap verifikasi email Anda sebelum login.'),
            actions: [
              TextButton(
                onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                child: const Text('Saya Mengerti'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int get _passwordStrength {
    final p = _passwordController.text;
    if (p.length < 4) return 0;
    if (p.length < 6) return 1;
    if (p.length < 8) return 2;
    if (p.contains(RegExp(r'[A-Z]')) && p.contains(RegExp(r'[0-9]'))) return 4;
    return 3;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [_red, Color(0xFF8B1010)]),
              ),
              width: double.infinity,
              padding: const EdgeInsets.only(top: 56, bottom: 28, left: 24, right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(children: [
                      const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 16),
                      Text('Kembali', style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Text('Buat Akun Baru 🎉', style: GoogleFonts.nunito(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('Isi data diri kamu untuk mulai memesan', style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(3, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      width: i == 0 ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == 0 ? _orange : Colors.white38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14)]),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildField(_nameController, 'Nama Lengkap', Icons.person_outline),
                        const SizedBox(height: 12),
                        _buildField(_emailController, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 12),
                        _buildPasswordField(_passwordController, 'Kata Sandi', _obscurePassword,
                            () => setState(() => _obscurePassword = !_obscurePassword)),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(4, (i) => Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: i < _passwordStrength ? _orange : const Color(0xFFF0EBE3),
                              ),
                            ),
                          )),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _passwordStrength < 2 ? 'Lemah' : _passwordStrength < 3 ? 'Sedang' : 'Kuat',
                          style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: _orange2),
                        ),
                        const SizedBox(height: 12),
                        _buildPasswordField(_confirmPasswordController, 'Konfirmasi Kata Sandi', _obscureConfirm,
                            () => setState(() => _obscureConfirm = !_obscureConfirm)),

                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            color: _agreed ? _orange : Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: _agreed ? _orange : const Color(0xFFBFB8B0), width: 2),
                          ),
                          child: _agreed ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.nunito(fontSize: 11, color: const Color(0xFF9A9A9A)),
                              children: [
                                const TextSpan(text: 'Saya menyetujui '),
                                TextSpan(text: 'Syarat & Ketentuan', style: GoogleFonts.nunito(color: _orange2, fontWeight: FontWeight.w800)),
                                const TextSpan(text: ' serta '),
                                TextSpan(text: 'Kebijakan Privasi', style: GoogleFonts.nunito(color: _orange2, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

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
                        onPressed: _isLoading ? null : _register,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text('Daftar Sekarang 🎉', style: GoogleFonts.nunito(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.nunito(fontSize: 13, color: const Color(0xFF9A9A9A)),
                        children: [
                          const TextSpan(text: 'Sudah punya akun? '),
                          TextSpan(text: 'Masuk', style: GoogleFonts.nunito(color: _orange2, fontWeight: FontWeight.w800)),
                        ],
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

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF7F2EC), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const SizedBox(width: 12),
        Icon(icon, color: const Color(0xFFBFB8B0), size: 18),
        const SizedBox(width: 8),
        Expanded(child: TextField(
          controller: ctrl, keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.nunito(color: const Color(0xFFBFB8B0), fontSize: 13),
            border: InputBorder.none, isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        )),
      ]),
    );
  }

  Widget _buildPasswordField(TextEditingController ctrl, String hint, bool obscure, VoidCallback toggle) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF7F2EC), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const SizedBox(width: 12),
        const Icon(Icons.lock_outline, color: Color(0xFFBFB8B0), size: 18),
        const SizedBox(width: 8),
        Expanded(child: TextField(
          controller: ctrl, obscureText: obscure,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.nunito(color: const Color(0xFFBFB8B0), fontSize: 13),
            border: InputBorder.none, isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        )),
        IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: const Color(0xFFBFB8B0), size: 18),
          onPressed: toggle,
        ),
      ]),
    );
  }


}
