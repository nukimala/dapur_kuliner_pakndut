import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../widgets/shared_bottom_nav.dart';
import '../nav_helper.dart';
import 'edit_profil_screen.dart';
import 'keamanan_screen.dart';
import 'hubungi_cs_screen.dart';
import 'beri_ulasan_screen.dart';
import 'keluar_screen.dart';

const _red      = Color(0xFFC0321A);
const _redDark  = Color(0xFF8B1A0A);
const _orange   = Color(0xFFF5A524);
const _cream    = Color(0xFFF7F0E6);
const _textBlack = Color(0xFF1C1C1C);
const _textGray  = Color(0xFF888888);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _avatar = '👤';
  String? _photoBase64;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _avatar      = (data['avatar']      as String?) ?? '👤';
          _photoBase64 = data['photoBase64']  as String?;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final user  = FirebaseAuth.instance.currentUser;
    final name  = user?.displayName ?? user?.email?.split('@').first ?? 'Pengguna';
    final email = user?.email ?? '-';
    final phone = (user?.phoneNumber?.isNotEmpty == true) ? user!.phoneNumber! : '-';

    return Scaffold(
      backgroundColor: _cream,
      body: Column(
        children: [
          // ── Hero header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFFD63010), _redDark]),
            ),
            child: Stack(children: [
              Positioned.fill(child: _blobs()),
              SafeArea(bottom: false, child: Column(children: [
                // back row
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 6, 20, 0),
                  child: Row(children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('Profil', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                  ]),
                ),
                // avatar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
                  child: Column(children: [
                    Stack(children: [
                      Container(
                        width: 78, height: 78,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F0E0), shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 10)],
                        ),
                        child: _photoBase64 != null
                          ? (() {
                              try {
                                return ClipOval(
                                  child: Image.memory(
                                    base64Decode(_photoBase64!),
                                    width: 78, height: 78, fit: BoxFit.cover,
                                  ),
                                );
                              } catch (_) {
                                return Center(child: Text(_avatar, style: const TextStyle(fontSize: 42)));
                              }
                            })()
                          : Center(child: Text(_avatar, style: const TextStyle(fontSize: 42))),
                      ),
                      Positioned(bottom: 2, right: 2,
                        child: Container(
                          width: 23, height: 23,
                          decoration: BoxDecoration(color: _orange, shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2)),
                          child: const Center(child: Icon(Icons.edit, color: Colors.white, size: 11)),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Text(name, style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                    const SizedBox(height: 3),
                    Text(email, style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13)),
                    if (phone != '-') ...[
                      const SizedBox(height: 2),
                      Text(phone, style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13)),
                    ],
                  ]),
                ),
              ])),
            ]),
          ),

          // ── Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('PROFIL SAYA'),
                _card([
                  _menuRow(context, icon: '👤', iconBg: const Color(0xFFFFF0DC),
                      title: 'Edit Profil', sub: 'Nama, Avatar dan Info Pribadi',
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilScreen()));
                        // Reload avatar setelah kembali dari edit profil
                        _loadAvatar();
                      },
                      last: true),
                ]),

                _sectionLabel('PENGATURAN', mt: 16),
                _card([
                  _menuRow(context, icon: '🔒', iconBg: const Color(0xFFE8F0FF),
                      title: 'Keamanan', sub: 'Kata Sandi dan Riwayat Login',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KeamananScreen())),
                      last: true),
                ]),

                _sectionLabel('BANTUAN', mt: 16),
                _card([
                  _menuRow(context, icon: '🎧', iconBg: const Color(0xFFFFF0DC),
                      title: 'Hubungi CS', sub: 'Chat via Whatsapp',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HubungiCSScreen()))),
                  _menuRow(context, icon: '⭐', iconBg: const Color(0xFFFFF8E1),
                      title: 'Beri Ulasan Kami', sub: 'Dukung Kami Berkembang',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BeriUlasanScreen()))),
                  _logoutRow(context),
                ]),
              ]),
            ),
          ),
          SharedBottomNav(
            activeIndex: 3,
            onTap: (i) => navigateToTab(context, i),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String t, {double mt = 0}) => Padding(
    padding: EdgeInsets.only(bottom: 8, top: mt, left: 2),
    child: Text(t, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFFAAAAAA), letterSpacing: 1.2)),
  );

  Widget _card(List<Widget> rows) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 2))]),
    child: ClipRRect(borderRadius: BorderRadius.circular(18), child: Column(children: rows)),
  );

  Widget _menuRow(BuildContext ctx, {required String icon, required Color iconBg,
      required String title, required String sub, required VoidCallback onTap, bool last = false}) {
    return InkWell(
      onTap: onTap,
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
            Text(sub, style: GoogleFonts.nunito(fontSize: 12, color: _textGray)),
          ])),
          const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC)),
        ]),
      ),
    );
  }

  Widget _logoutRow(BuildContext ctx) => InkWell(
    onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => KeluarScreen(onConfirm: () => AuthService().signOut()))),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(color: const Color(0xFFFFE8E5), borderRadius: BorderRadius.circular(14)),
          child: Center(child: Icon(Icons.logout_rounded, color: _red, size: 22)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Keluar', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 15, color: _red)),
          Text('Logout dari Akun ini', style: GoogleFonts.nunito(fontSize: 12, color: _textGray)),
        ])),
        const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC)),
      ]),
    ),
  );
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
