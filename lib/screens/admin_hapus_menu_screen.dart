import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/menu_model.dart';

const _red     = Color(0xFFC0321A);
const _redDark = Color(0xFF8B1A0A);
const _orange  = Color(0xFFF5A524);
const _cream   = Color(0xFFF7F0E6);
const _textBlack = Color(0xFF1C1C1C);
const _textMid   = Color(0xFF555555);
const _textGray  = Color(0xFF888888);

class AdminHapusMenuScreen extends StatefulWidget {
  final MenuModel menu;
  const AdminHapusMenuScreen({super.key, required this.menu});

  @override
  State<AdminHapusMenuScreen> createState() => _AdminHapusMenuScreenState();
}

class _AdminHapusMenuScreenState extends State<AdminHapusMenuScreen> {
  bool _deleting = false;

  String _fmt(num n) => 'Rp. ${n.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  Future<void> _hapus() async {
    if (widget.menu.id == null) return;
    setState(() => _deleting = true);
    try {
      await FirebaseFirestore.instance.collection('menus').doc(widget.menu.id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Menu berhasil dihapus!',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          backgroundColor: const Color(0xFF2BB84A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        // Pop twice: hapus screen → kelola screen
        Navigator.pop(context);
        if (Navigator.canPop(context)) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal menghapus: $e',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        setState(() => _deleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Column(children: [
        // ── Header
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFFD63010), _redDark]),
          ),
          child: Stack(children: [
            Positioned(right: -30, top: -50, child: Container(width: 160, height: 160,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07)))),
            SafeArea(bottom: false, child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 20, 14),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Text('Hapus Menu',
                    style: GoogleFonts.nunito(color: Colors.white,
                        fontWeight: FontWeight.w800, fontSize: 20)),
              ]),
            )),
          ]),
        ),

        // ── Body
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 32, 22, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            // Warning triangle (custom painter)
            CustomPaint(painter: _TrianglePainter(), size: const Size(130, 115)),
            const SizedBox(height: 20),

            Text('Yakin Hapus Menu Ini?',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: _textBlack)),
            const SizedBox(height: 10),
            Text(
              'Menu yang dihapus tidak bisa dikembalikan. Semua data riwayat pesanan menu ini '
              'juga akan ikut terhapus secara otomatis.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 13, color: _textGray, height: 1.65)),
            const SizedBox(height: 24),

            // Preview card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _orange, width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10)],
              ),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: widget.menu.imageUrl.isNotEmpty
                      ? Image.network(widget.menu.imageUrl, width: 68, height: 62, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 68, height: 62,
                            color: const Color(0xFFFFF4E0),
                            child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 28)))))
                      : Container(width: 68, height: 62,
                          color: const Color(0xFFFFF4E0),
                          child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 28)))),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.menu.name,
                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: _textBlack)),
                  const SizedBox(height: 3),
                  Text(_fmt(widget.menu.price),
                    style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: _orange)),
                ])),
              ]),
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: _deleting ? null : () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5),
                  ),
                  child: Center(child: Text('Batal',
                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: _textMid))),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: GestureDetector(
                onTap: _deleting ? null : _hapus,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFD63010), _redDark]),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: _red.withValues(alpha: 0.4), blurRadius: 20)],
                  ),
                  child: Center(child: _deleting
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text('Ya, Hapus!',
                          style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white))),
                ),
              )),
            ]),
          ]),
        )),
      ]),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 6)
      ..lineTo(size.width - 6, size.height - 4)
      ..lineTo(6, size.height - 4)
      ..close();

    canvas.drawPath(path, Paint()..color = const Color(0xFFD63010));

    final innerPath = Path()
      ..moveTo(size.width / 2, 16)
      ..lineTo(size.width - 16, size.height - 8)
      ..lineTo(16, size.height - 8)
      ..close();

    canvas.drawPath(innerPath, Paint()..color = const Color(0xFFC02010).withValues(alpha: 0.4));

    // Exclamation mark
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '!',
        style: TextStyle(fontSize: 56, color: Color(0xFFFFD700), fontWeight: FontWeight.w900),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas,
        Offset((size.width - textPainter.width) / 2, size.height - textPainter.height - 8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
