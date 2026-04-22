import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cart_item_model.dart';
import '../services/database_helper.dart';
import '../widgets/shared_bottom_nav.dart';
import '../nav_helper.dart';
import 'cart_screen.dart';

const _redDark  = Color(0xFF8B1A0A);
const _orange   = Color(0xFFF5A524);
const _orangeL  = Color(0xFFFFCA57);
const _cream    = Color(0xFFF7F0E6);
const _textBlack = Color(0xFF1C1C1C);
const _textGray  = Color(0xFF888888);
const _green     = Color(0xFF2BB84A);
const _redBtn    = Color(0xFFE8331A);

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});
  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _reorder(BuildContext ctx, List<dynamic> items) async {
    bool added = false;
    for (final item in items) {
      final menuId = item['menuId']?.toString() ?? item['id']?.toString() ?? '';
      final qty    = (item['quantity'] ?? 1) as int;
      if (menuId.isEmpty) continue;
      await _db.addToCart(CartItemModel(menuId: menuId, quantity: qty, userUid: _uid));
      added = true;
    }
    if (!ctx.mounted) return;
    if (added) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text('Item ditambahkan ke keranjang! 🛒',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ));
      await Future.delayed(const Duration(milliseconds: 900));
      if (ctx.mounted) {
        Navigator.push(ctx, MaterialPageRoute(builder: (_) => const CartScreen()));
      }
    }
  }

  String _fmt(double n) => 'Rp. ${n.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Column(
        children: [
          // ── Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFFD63010), _redDark]),
            ),
            child: Stack(children: [
              Positioned.fill(child: _blobs()),
              SafeArea(bottom: false, child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 20, 14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('Riwayat Pembelian', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                  ]),
                  Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: Text('Semua transaksi Anda tersimpan di sini',
                        style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12)),
                  ),
                ]),
              )),
            ]),
          ),

          // ── Orders list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('buyerUid', isEqualTo: _uid)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Error: ${snap.error}',
                        style: GoogleFonts.nunito(color: Colors.red, fontSize: 12)),
                  ));
                }
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: _orange));
                }
                // Sort client-side: newest first
                final docs = (snap.data?.docs ?? [])
                  ..sort((a, b) {
                    final ta = (a.data() as Map)['timestamp'];
                    final tb = (b.data() as Map)['timestamp'];
                    if (ta == null || tb == null) return 0;
                    return tb.compareTo(ta);
                  });
                if (docs.isEmpty) {
                  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('📋', style: TextStyle(fontSize: 60)),
                    const SizedBox(height: 12),
                    Text('Belum ada riwayat pesanan', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 18, color: _textBlack)),
                    const SizedBox(height: 4),
                    Text('Yuk, mulai pesan makanan favoritmu!', style: GoogleFonts.nunito(fontSize: 13, color: _textGray)),
                  ]));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    final status = d['status']?.toString() ?? 'Pending';
                    final total  = (d['totalPrice'] ?? 0).toDouble();
                    final ts     = d['timestamp']?.toDate() ?? DateTime.now();
                    final items  = (d['items'] as List<dynamic>?) ?? [];
                    final orderId = '#${docs[i].id.substring(0, 8).toUpperCase()}';

                    final isSelesai   = status == 'Completed' || status == 'Selesai';
                    final isDibatalkan = status == 'Cancelled' || status == 'Dibatalkan';
                    final statusLabel = isSelesai ? 'Selesai' : isDibatalkan ? 'Dibatalkan' : 'Diproses';
                    final sClr = isSelesai ? _green : isDibatalkan ? _redBtn : const Color(0xFFF39C12);
                    final sBg  = isSelesai ? const Color(0xFFE8F8EF) : isDibatalkan ? const Color(0xFFFFF0EE) : const Color(0xFFFFF8E1);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(orderId, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16, color: _textBlack)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(color: sBg, borderRadius: BorderRadius.circular(20)),
                            child: Text(statusLabel, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: sClr)),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Text('${ts.day} ${_monthName(ts.month)} ${ts.year}, ${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}',
                            style: GoogleFonts.nunito(fontSize: 12, color: _textGray)),
                        const SizedBox(height: 12),

                        Container(
                          decoration: BoxDecoration(color: _cream, borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: items.take(3).indexed.map((e) {
                              final name = e.$2['name'] ?? 'Item';
                              final qty  = e.$2['quantity'] ?? 1;
                              return Padding(
                                padding: EdgeInsets.only(bottom: e.$1 < items.length - 1 ? 4 : 0),
                                child: Text('${e.$1 + 1}. $name ×$qty',
                                    style: GoogleFonts.nunito(fontSize: 13, color: const Color(0xFF555555))),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Total Bayar', style: GoogleFonts.nunito(fontSize: 12, color: _textGray)),
                            Text(_fmt(total), style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 19, color: _redBtn)),
                          ]),
                          GestureDetector(
                            onTap: () => _reorder(context, items),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [_orange, _orangeL]),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [BoxShadow(color: _orange.withValues(alpha: 0.4), blurRadius: 12)],
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Text('Pesan Lagi', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                              ]),
                            ),
                          ),
                        ]),
                      ]),
                    );
                  },
                );
              },
            ),
          ),
          SharedBottomNav(
            activeIndex: 2,
            onTap: (i) => navigateToTab(context, i),
          ),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agt','Sep','Okt','Nov','Des'];
    return names[m - 1];
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
