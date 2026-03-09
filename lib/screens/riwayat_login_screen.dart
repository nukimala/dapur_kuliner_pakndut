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

const _bulan = [
  '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
];
const _hari = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

class RiwayatLoginScreen extends StatelessWidget {
  const RiwayatLoginScreen({super.key});

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    final local = dt.toLocal();
    final hh = _hari[local.weekday % 7];
    final tgl = local.day.toString().padLeft(2, '0');
    final bln = _bulan[local.month];
    final jam = local.hour.toString().padLeft(2, '0');
    final mnt = local.minute.toString().padLeft(2, '0');
    return '$hh, $tgl $bln ${local.year} · $jam:$mnt WIB';
  }

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu yang lalu';
    return '${(diff.inDays / 30).floor()} bulan yang lalu';
  }

  @override
  Widget build(BuildContext context) {
    final user     = FirebaseAuth.instance.currentUser;
    final meta     = user?.metadata;
    final lastSign  = meta?.lastSignInTime;
    final created  = meta?.creationTime;

    return Scaffold(
      backgroundColor: _cream,
      body: Column(children: [
        _buildHeader(context),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Akun info card
            _infoCard(
              icon: '👤',
              iconBg: const Color(0xFFFFF0DC),
              title: 'Akun',
              subtitle: user?.email ?? '-',
            ),
            const SizedBox(height: 16),

            _sectionLabel('AKTIVITAS LOGIN'),
            const SizedBox(height: 10),

            // Login Terakhir
            _loginCard(
              icon: '🕐',
              iconBg: const Color(0xFFE8F0FF),
              title: 'Login Terakhir',
              date: _formatDate(lastSign),
              badge: _timeAgo(lastSign),
              badgeColor: _green,
            ),
            const SizedBox(height: 12),

            // Pertama Daftar
            _loginCard(
              icon: '🎉',
              iconBg: const Color(0xFFFFF8E1),
              title: 'Akun Dibuat',
              date: _formatDate(created),
              badge: 'Pertama Kali',
              badgeColor: _orange,
            ),
            const SizedBox(height: 24),

            // Keterangan
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('🔒', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  'Jika kamu melihat aktivitas yang mencurigakan, segera ganti password akunmu untuk menjaga keamanan.',
                  style: GoogleFonts.nunito(fontSize: 13, color: _textGray, height: 1.55),
                )),
              ]),
            ),
          ]),
        )),
      ]),
    );
  }

  Widget _loginCard({
    required String icon,
    required Color iconBg,
    required String title,
    required String date,
    required String badge,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w700,
                fontSize: 14, color: _textBlack)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(badge, style: GoogleFonts.nunito(
                  fontSize: 11, fontWeight: FontWeight.w700, color: badgeColor)),
            ),
          ]),
          const SizedBox(height: 4),
          Text(date, style: GoogleFonts.nunito(fontSize: 12, color: _textGray)),
        ])),
      ]),
    );
  }

  Widget _infoCard({
    required String icon,
    required Color iconBg,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.nunito(fontSize: 12, color: _textGray)),
          Text(subtitle, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: _textBlack)),
        ])),
      ]),
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
        Text('Riwayat Login', style: GoogleFonts.nunito(
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
