import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'admin_kelola_menu_screen.dart';
import 'admin_laporan_screen.dart';
import 'admin_ulasan_screen.dart';
import 'admin_cetak_struk_screen.dart';

// ── Warna
const _redCircle = Color(0xFF9B1005);
const _cream     = Color(0xFFF5EDE0);
const _textBlack = Color(0xFF1A1A1A);

// ─────────────────────────────────────────────────────────────────────────────
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(children: [
                _MenuCard(
                  icon: '📜',
                  iconBg: const Color(0xFFFFF3E0),
                  label: 'Kelola Menu',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AdminKelolaMenuScreen())),
                ),
                const SizedBox(height: 12),
                _MenuCard(
                  icon: '📊',
                  iconBg: const Color(0xFFE3F2FD),
                  label: 'Laporan Penjualan',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AdminLaporanScreen())),
                ),
                const SizedBox(height: 12),
                _MenuCard(
                  icon: '⭐',
                  iconBg: const Color(0xFFFFF9C4),
                  label: 'Ulasan Pelanggan',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AdminUlasanScreen())),
                ),
                const SizedBox(height: 12),
                _MenuCard(
                  icon: '🖨️',
                  iconBg: const Color(0xFFE8F5E9),
                  label: 'Cetak Struk',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AdminCetakStrukScreen())),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFCC1A0A), Color(0xFF8B1A0A)],
        ),
      ),
      child: Stack(
        children: [
          // ── Lingkaran dekorasi
          Positioned(right: -45, top: -45, child: Container(
            width: 170, height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _redCircle.withValues(alpha: 0.7),
            ),
          )),
          Positioned(right: 30, top: -35, child: Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
            ),
          )),
          Positioned(left: -30, top: 30, child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _redCircle.withValues(alpha: 0.5),
            ),
          )),
          Positioned(left: -40, bottom: -40, child: Container(
            width: 150, height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _redCircle.withValues(alpha: 0.6),
            ),
          )),
          Positioned(right: -35, bottom: -25, child: Container(
            width: 110, height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _redCircle.withValues(alpha: 0.55),
            ),
          )),

          // ── Konten
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
              child: Column(
                children: [
                  // Top bar: Admin pill + Logout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35), width: 1.5),
                        ),
                        child: Text('Admin',
                          style: GoogleFonts.nunito(
                            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async => await AuthService().signOut(),
                        child: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35), width: 1.5),
                          ),
                          child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Logo DAPUR KULINER PAK NDUT
                  Image.asset(
                    'assets/icons/logo.png',
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Menu card: icon dengan background berwarna + label + chevron right
class _MenuCard extends StatelessWidget {
  final String icon;
  final Color iconBg;
  final String label;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon dengan background berwarna
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 18),
            // Label
            Expanded(
              child: Text(label,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textBlack,
                ),
              ),
            ),
            // Chevron right
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 26),
          ],
        ),
      ),
    );
  }
}
