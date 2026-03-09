import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ganti_sandi_screen.dart';
import 'riwayat_login_screen.dart';

const _redDark  = Color(0xFF8B1A0A);
const _green    = Color(0xFF2BB84A);
const _textBlack = Color(0xFF1C1C1C);
const _textGray  = Color(0xFF888888);

class KeamananScreen extends StatelessWidget {
  const KeamananScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F0E6),
      body: Column(children: [
        _header(context, title: 'Keamanan'),
        Expanded(child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _sectionLabel('AUTENTIKASI'),
            _card([
              _menuRow(
                context: context,
                icon: '🔐', iconBg: const Color(0xFFE8F0FF),
                title: 'Kata Sandi', sub: 'Aktif · Ubah kata sandi akun',
                subColor: _green, last: true,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const GantiSandiScreen())),
              ),
            ]),
            const SizedBox(height: 18),
            _sectionLabel('AKTIVITAS'),
            _card([
              _menuRow(
                context: context,
                icon: '📋', iconBg: const Color(0xFFF0F0F0),
                title: 'Riwayat Login', sub: 'Lihat semua aktivitas login', last: true,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RiwayatLoginScreen())),
              ),
            ]),
          ]),
        )),
      ]),
    );
  }
}

Widget _sectionLabel(String t, {double mt = 0}) => Padding(
  padding: EdgeInsets.only(bottom: 8, top: mt, left: 2),
  child: Text(t, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFFAAAAAA), letterSpacing: 1.2)),
);

Widget _card(List<Widget> rows) => Container(
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)]),
  child: ClipRRect(borderRadius: BorderRadius.circular(18), child: Column(children: rows)),
);

Widget _menuRow({
  required BuildContext context,
  required String icon,
  required Color iconBg,
  required String title,
  required String sub,
  required VoidCallback onTap,
  Color? subColor,
  bool last = false,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: last
        ? const BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18))
        : BorderRadius.zero,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Row(children: [
        Container(width: 46, height: 46, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 24)))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 15, color: _textBlack)),
          const SizedBox(height: 2),
          Text(sub, style: GoogleFonts.nunito(fontSize: 12, color: subColor ?? _textGray,
              fontWeight: subColor != null ? FontWeight.w600 : FontWeight.w400)),
        ])),
        const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC)),
      ]),
    ),
  );
}

Widget _header(BuildContext context, {required String title}) => Container(
  decoration: const BoxDecoration(
    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFFD63010), _redDark]),
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
        Text(title, style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
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
