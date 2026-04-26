import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

const _redDark  = Color(0xFF8B1A0A);
const _orange   = Color(0xFFF5A524);
const _redBtn   = Color(0xFFE8331A);
const _textBlack = Color(0xFF1C1C1C);
const _textGray  = Color(0xFF888888);
const _textMid   = Color(0xFF555555);

class KeluarScreen extends StatelessWidget {
  final VoidCallback onConfirm;
  const KeluarScreen({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name  = user?.displayName ?? user?.email?.split('@').first ?? 'Pengguna';
    final email = user?.email ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F0E6),
      body: Column(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFFD63010), _redDark]),
          ),
          child: Stack(children: [
            Positioned.fill(child: _blobs()),
            SafeArea(bottom: false, child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 20, 0),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text('Keluar', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                child: Column(children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(child: Text('🚪', style: TextStyle(fontSize: 40))),
                  ),
                  const SizedBox(height: 12),
                  Text('Yakin Mau Keluar?', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
                  const SizedBox(height: 6),
                  Text('Kamu akan keluar dari akun $name\ndan perlu login kembali nanti',
                      textAlign: TextAlign.center, style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13, height: 1.55)),
                ]),
              ),
            ])),
          ]),
        ),

        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Column(children: [
            // User card
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
                  .get(),
              builder: (context, snap) {
                final avatar = (snap.hasData && snap.data!.exists)
                    ? ((snap.data!.data() as Map<String, dynamic>?)?['avatar'] as String? ?? '👤')
                    : '👤';
                return Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)]),
                  child: Row(children: [
                    Container(width: 50, height: 50,
                        decoration: const BoxDecoration(color: Color(0xFFF5F0E0), shape: BoxShape.circle),
                        child: Center(child: Text(avatar, style: const TextStyle(fontSize: 28)))),
                    const SizedBox(width: 14),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(name, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 15, color: _textBlack)),
                      const SizedBox(height: 2),
                      Text(email, style: GoogleFonts.nunito(fontSize: 12, color: _textGray)),
                    ]),
                  ]),
                );
              },
            ),

            // Warning
            Container(
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(bottom: 28),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Text('⚠️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text('Perlu diketahui!', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 15, color: _redBtn)),
                ]),
                const SizedBox(height: 12),
                ...[
                  'Keranjang Belanja akan tetap tersimpan',
                  'Riwayat transaksi tidak akan hilang',
                  'Notifikasi akan dihentikan sementara',
                ].asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text('${e.key + 1}. ${e.value}', style: GoogleFonts.nunito(fontSize: 13, color: _textMid, height: 1.5)),
                )),
              ]),
            ),

            // Cancel button
            Container(
              width: double.infinity, margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.white,
                  foregroundColor: _textMid,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32),
                      side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.5)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('Batal, Tetap di sini', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),

            // Confirm logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  elevation: 0,
                ),
                onPressed: () async {
                  await AuthService().signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                child: Text('Ya, Keluar Sekarang', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
          ]),
        )),
      ]),
    );
  }
}

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
