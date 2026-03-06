import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'admin_kelola_menu_screen.dart';
import 'admin_laporan_screen.dart';
import 'admin_presentase_screen.dart';
import 'admin_ulasan_screen.dart';


const _redDark = Color(0xFF8B1A0A);
const _orange  = Color(0xFFF5A524);
const _cream   = Color(0xFFF7F0E6);
const _textBlack = Color(0xFF1C1C1C);
const _textGray  = Color(0xFF888888);

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Column(children: [
        // ── Hero Header ──────────────────────────────────────
        Stack(children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFFD63010), _redDark],
              ),
            ),
            child: Stack(children: [
              // decorative blobs
              Positioned(right: -40, top: -60,
                child: Container(width: 180, height: 180,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.07)))),
              Positioned(left: -10, top: 50,
                child: Container(width: 90, height: 90,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05)))),
              Positioned(left: 20, bottom: -20,
                child: Container(width: 120, height: 120,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06)))),
              SafeArea(bottom: false, child: Column(children: [
                // top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                        ),
                        child: Text('Admin',
                            style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                      ),
                      GestureDetector(
                        onTap: () async { await AuthService().signOut(); },
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                          ),
                          child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                // app title
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(children: [
                    Text('DAPUR\nKULINER',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 48, color: Colors.white, height: 1.0,
                        fontWeight: FontWeight.w900, fontStyle: FontStyle.italic,
                        shadows: [const Shadow(color: Colors.black26, offset: Offset(3,3), blurRadius: 0)],
                      )),
                    Text('PAK NDUT',
                      style: GoogleFonts.nunito(
                        fontSize: 42, color: _orange, height: 1.1,
                        fontWeight: FontWeight.w900, fontStyle: FontStyle.italic,
                        shadows: [const Shadow(color: Colors.black26, offset: Offset(3,3), blurRadius: 0)],
                      )),
                  ]),
                ),
              ])),
            ]),
          ),
        ]),

        // ── Body ────────────────────────────────────────────
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // stats row
            Row(children: [
              Expanded(child: _StatCard(emoji: '🧺', value: '24', label: 'Pesanan Hari Ini')),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(emoji: '💵', value: 'Rp 480.000', label: 'Pendapatan Hari Ini', valueSize: 16)),
            ]),
            const SizedBox(height: 10),
            _StatCard(emoji: '🍽️', value: '18', label: 'Menu Aktif'),
            const SizedBox(height: 18),

            // quick actions
            Text('AKSI CEPAT',
              style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800,
                  color: _textBlack, letterSpacing: 1.0)),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
              childAspectRatio: 1.15,
              children: [
                _ActionCard(emoji: '📋', label: 'Kelola Menu',
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const AdminKelolaMenuScreen()))),
                _ActionCard(emoji: '📈', label: 'Presentase',
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const AdminPresentaseScreen()))),
                _ActionCard(emoji: '📊', label: 'Laporan',
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const AdminLaporanScreen()))),
                _ActionCard(emoji: '⭐', label: 'Ulasan Pelanggan',
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const AdminUlasanScreen()))),
              ],
            ),
          ]),
        )),
      ]),
    );
  }
}

// ── Stat card ──────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String emoji, value, label;
  final double valueSize;
  const _StatCard({required this.emoji, required this.value, required this.label, this.valueSize = 26});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10)],
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
            style: GoogleFonts.nunito(fontSize: valueSize, fontWeight: FontWeight.w900,
                color: _textBlack, height: 1.1)),
          const SizedBox(height: 2),
          Text(label,
            style: GoogleFonts.nunito(fontSize: 11, color: _textGray)),
        ])),
      ]),
    );
  }
}

// ── Action card ────────────────────────────────────────────
class _ActionCard extends StatelessWidget {
  final String emoji, label;
  final VoidCallback onTap;
  const _ActionCard({required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10)],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: _textBlack)),
        ]),
      ),
    );
  }
}
