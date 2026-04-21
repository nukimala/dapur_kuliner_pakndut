import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/menu_model.dart';
import 'admin_tambah_menu_screen.dart';
import 'admin_edit_menu_screen.dart';
import 'admin_hapus_menu_screen.dart';

const _red     = Color(0xFFC0321A);
const _redDark = Color(0xFF8B1A0A);
const _orange  = Color(0xFFF5A524);
const _cream   = Color(0xFFF7F0E6);
const _textBlack = Color(0xFF1C1C1C);
const _textMid   = Color(0xFF555555);
const _textGray  = Color(0xFF888888);

class AdminKelolaMenuScreen extends StatefulWidget {
  const AdminKelolaMenuScreen({super.key});

  @override
  State<AdminKelolaMenuScreen> createState() => _AdminKelolaMenuScreenState();
}

class _AdminKelolaMenuScreenState extends State<AdminKelolaMenuScreen> {
  String _tab    = 'Semua';
  String _search = '';

  final _tabs = ['Semua', 'Makanan', 'Minuman'];

  String _fmt(num n) => 'Rp. ${n.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

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
              padding: const EdgeInsets.fromLTRB(4, 6, 16, 14),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(child: Text('Kelola Menu',
                    style: GoogleFonts.nunito(color: Colors.white,
                        fontWeight: FontWeight.w800, fontSize: 20))),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const AdminTambahMenuScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(children: [
                      Text('+', style: GoogleFonts.nunito(color: _red,
                          fontWeight: FontWeight.w900, fontSize: 18)),
                      const SizedBox(width: 4),
                      Text('Tambah', style: GoogleFonts.nunito(color: _red,
                          fontWeight: FontWeight.w800, fontSize: 13)),
                    ]),
                  ),
                ),
              ]),
            )),
          ]),
        ),

        // ── Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8)]),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Icon(Icons.search, color: Colors.grey[400], size: 20),
              const SizedBox(width: 10),
              Expanded(child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: GoogleFonts.nunito(fontSize: 14, color: _textBlack),
                decoration: InputDecoration(
                  isDense: true, border: InputBorder.none,
                  hintText: 'Cari Nama Menu....',
                  hintStyle: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[400]),
                ),
              )),
            ]),
          ),
        ),

        // ── Category tabs
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
          child: Row(children: _tabs.map((t) {
            final sel = _tab == t;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _tab = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: sel ? _orange : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [BoxShadow(
                      color: sel ? _orange.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.08),
                      blurRadius: sel ? 12 : 4,
                    )],
                  ),
                  child: Text(t,
                    style: GoogleFonts.nunito(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: sel ? Colors.white : _textMid,
                    )),
                ),
              ),
            );
          }).toList()),
        ),

        // ── Menu list
        Expanded(child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('menus').snapshots(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: _orange));
            }
            if (snap.hasError) {
              return Center(child: Text('Error: ${snap.error}'));
            }
            final docs = snap.data?.docs ?? [];
            final menus = docs.map((d) =>
                MenuModel.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();

            final filtered = menus.where((m) {
              final okTab = _tab == 'Semua' || m.category == _tab;
              final okSrc = m.name.toLowerCase().contains(_search.toLowerCase());
              return okTab && okSrc;
            }).toList();

            if (filtered.isEmpty) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('🍽️', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text('Belum ada menu', style: GoogleFonts.nunito(color: _textGray, fontSize: 15)),
              ]));
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final item = filtered[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10)],
                  ),
                  child: Row(children: [
                    // image
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                      child: item.imageUrl.isNotEmpty
                          ? Image.network(item.imageUrl, width: 88, height: 80, fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(width: 88, height: 80,
                                color: const Color(0xFFFFF4E0),
                                child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 30)))))
                          : Container(width: 88, height: 80,
                              color: const Color(0xFFFFF4E0),
                              child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 30)))),
                    ),
                    // info
                    Expanded(child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.name,
                          style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: _textBlack)),
                        const SizedBox(height: 2),
                        Text(_fmt(item.price),
                          style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: _orange)),
                        const SizedBox(height: 8),
                        Row(children: [
                          // Edit button
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                                builder: (_) => AdminEditMenuScreen(menu: item))),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: _orange, width: 1.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(children: [
                                Icon(Icons.edit_outlined, size: 13, color: _orange),
                                const SizedBox(width: 4),
                                Text('Edit', style: GoogleFonts.nunito(
                                    fontSize: 12, fontWeight: FontWeight.w700, color: _orange)),
                              ]),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Delete button
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                                builder: (_) => AdminHapusMenuScreen(menu: item))),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(Icons.delete_outline_rounded,
                                  size: 22, color: Colors.grey[400]),
                            ),
                          ),
                        ]),
                      ]),
                    )),
                  ]),
                );
              },
            );
          },
        )),
      ]),
    );
  }
}
