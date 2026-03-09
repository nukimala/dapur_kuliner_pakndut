import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

const _redDark   = Color(0xFF8B1A0A);
const _redGrad   = Color(0xFFD63010);
const _orange    = Color(0xFFF5A524);
const _green     = Color(0xFF2BB84A);
const _textBlack = Color(0xFF1C1C1C);
const _textGray  = Color(0xFF888888);
const _cream     = Color(0xFFF7F0E6);

class GantiSandiScreen extends StatefulWidget {
  const GantiSandiScreen({super.key});

  @override
  State<GantiSandiScreen> createState() => _GantiSandiScreenState();
}

class _GantiSandiScreenState extends State<GantiSandiScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _lamCtrl      = TextEditingController();
  final _baruCtrl     = TextEditingController();
  final _konfCtrl     = TextEditingController();

  bool _showLama      = false;
  bool _showBaru      = false;
  bool _showKonf      = false;
  bool _isLoading     = false;

  @override
  void dispose() {
    _lamCtrl.dispose();
    _baruCtrl.dispose();
    _konfCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      _showSnack('Sesi tidak valid. Silakan login ulang.', isError: true);
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Re-authenticate terlebih dahulu
      final cred = EmailAuthProvider.credential(
        email:    user.email!,
        password: _lamCtrl.text.trim(),
      );
      await user.reauthenticateWithCredential(cred);

      // Ganti password
      await user.updatePassword(_baruCtrl.text.trim());

      if (!mounted) return;
      _showSnack('Password berhasil diubah! 🔐', isError: false);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String msg = 'Terjadi kesalahan. Coba lagi.';
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        msg = 'Password lama salah. Coba lagi.';
      } else if (e.code == 'weak-password') {
        msg = 'Password baru terlalu lemah (min. 6 karakter).';
      } else if (e.code == 'requires-recent-login') {
        msg = 'Sesi sudah lama. Silakan logout lalu login ulang.';
      }
      _showSnack(msg, isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
      backgroundColor: isError ? const Color(0xFFD63010) : _green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Column(children: [
        _buildHeader(context),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFDC7A)),
                ),
                child: Row(children: [
                  const Text('💡', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                    'Masukkan password lama untuk verifikasi, lalu buat password baru yang kuat.',
                    style: GoogleFonts.nunito(fontSize: 13, color: const Color(0xFF7A5A00), height: 1.5),
                  )),
                ]),
              ),
              const SizedBox(height: 24),

              _sectionLabel('PASSWORD LAMA'),
              const SizedBox(height: 8),
              _buildField(
                ctrl:         _lamCtrl,
                hint:         'Masukkan password lama',
                obscure:      !_showLama,
                toggleShow:   () => setState(() => _showLama = !_showLama),
                isShowing:    _showLama,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password lama tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _sectionLabel('PASSWORD BARU'),
              const SizedBox(height: 8),
              _buildField(
                ctrl:         _baruCtrl,
                hint:         'Minimal 6 karakter',
                obscure:      !_showBaru,
                toggleShow:   () => setState(() => _showBaru = !_showBaru),
                isShowing:    _showBaru,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password baru tidak boleh kosong';
                  if (v.length < 6) return 'Password minimal 6 karakter';
                  if (v == _lamCtrl.text.trim()) return 'Password baru tidak boleh sama dengan yang lama';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _sectionLabel('KONFIRMASI PASSWORD BARU'),
              const SizedBox(height: 8),
              _buildField(
                ctrl:         _konfCtrl,
                hint:         'Ulangi password baru',
                obscure:      !_showKonf,
                toggleShow:   () => setState(() => _showKonf = !_showKonf),
                isShowing:    _showKonf,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Konfirmasi password tidak boleh kosong';
                  if (v != _baruCtrl.text.trim()) return 'Password tidak cocok';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _simpan,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _redGrad,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text('Simpan Password Baru',
                          style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
            ]),
          ),
        )),
      ]),
    );
  }

  Widget _buildField({
    required TextEditingController ctrl,
    required String hint,
    required bool obscure,
    required VoidCallback toggleShow,
    required bool isShowing,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller:    ctrl,
      obscureText:   obscure,
      validator:     validator,
      style:         GoogleFonts.nunito(fontSize: 14, color: _textBlack),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(color: _textGray, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(isShowing ? Icons.visibility_off : Icons.visibility,
              color: _textGray, size: 20),
          onPressed: toggleShow,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEAEAEA))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEAEAEA), width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _orange, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD63010), width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD63010), width: 1.5)),
      ),
    );
  }
}

Widget _sectionLabel(String t) => Padding(
  padding: const EdgeInsets.only(left: 2),
  child: Text(t, style: GoogleFonts.nunito(
      fontSize: 11, fontWeight: FontWeight.w800,
      color: const Color(0xFFAAAAAA), letterSpacing: 1.2)),
);

Widget _buildHeader(BuildContext context) => Container(
  decoration: const BoxDecoration(
    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [_redGrad, _redDark]),
  ),
  child: Stack(children: [
    Positioned.fill(child: _blobs()),
    SafeArea(bottom: false, child: Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 20, 14),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        Text('Ganti Sandi', style: GoogleFonts.nunito(
            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
      ]),
    )),
  ]),
);

Widget _blobs() => Stack(children: [
  Positioned(right: -35, top: -55,
      child: Container(width: 170, height: 170,
          decoration: BoxDecoration(shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.07)))),
  Positioned(right: 75, bottom: 5,
      child: Container(width: 110, height: 110,
          decoration: BoxDecoration(shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05)))),
]);
