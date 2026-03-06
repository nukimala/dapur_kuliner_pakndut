import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/menu_model.dart';
import '../models/cart_item_model.dart';
import '../services/database_helper.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';
import 'profile_screen.dart';

// ── Design tokens
const _red      = Color(0xFFC0321A);
const _redDark  = Color(0xFF8B1A0A);
const _orange   = Color(0xFFF5A524);
const _orangeL  = Color(0xFFFFCA57);
const _cream    = Color(0xFFF7F0E6);
const _white    = Colors.white;
const _textBlack = Color(0xFF1C1C1C);
const _textGray  = Color(0xFF888888);

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});
  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  int _cartCount = 0;
  int _navIdx = 0;

  @override
  void initState() { super.initState(); _loadCart(); }

  Future<void> _loadCart() async {
    final items = await _db.getCartItems(_uid);
    int c = 0;
    for (var i in items) c += i.quantity;
    if (mounted) setState(() => _cartCount = c);
  }

  Future<void> _addToCart(MenuModel menu) async {
    if (_uid.isEmpty) return;
    await _db.addToCart(CartItemModel(menuId: menu.id!, quantity: 1, userUid: _uid));
    _loadCart();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${menu.name} ditambahkan ke keranjang! 🛒'),
        backgroundColor: const Color(0xFF2BB84A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void _goToCart() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
    _loadCart();
  }

  void _onNav(int idx) {
    if (idx == 0) { setState(() => _navIdx = 0); return; }
    if (idx == 1) { _goToCart(); return; }
    if (idx == 2) { Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen())); return; }
    if (idx == 3) { Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())); return; }
  }

  String get _userName {
    final u = FirebaseAuth.instance.currentUser;
    return u?.displayName ?? u?.email?.split('@').first ?? 'Pengguna';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Column(
        children: [
          // ── Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFFD63010), _redDark],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(child: _blobs()),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Selamat Datang 👋',
                                    style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13)),
                                Text('Dapur Kuliner Pak Ndut',
                                    style: GoogleFonts.nunito(color: _white, fontWeight: FontWeight.w900, fontSize: 20)),
                              ],
                            ),
                            _cartBadge(),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                          child: Row(children: [
                            const Icon(Icons.search, color: Colors.white70, size: 18),
                            const SizedBox(width: 10),
                            Text('Cari menu favorit kamu...',
                                style: GoogleFonts.nunito(color: Colors.white60, fontSize: 14)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Menu Populer 🔥',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16, color: _textBlack)),
                  const SizedBox(height: 14),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('menus').snapshots(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(color: _red),
                        ));
                      }
                      if (!snap.hasData || snap.data!.docs.isEmpty) {
                        return Center(child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Text('Belum ada menu tersedia.',
                              style: GoogleFonts.nunito(color: _textGray, fontSize: 14)),
                        ));
                      }
                      final menus = snap.data!.docs
                          .map((d) => MenuModel.fromMap(d.data() as Map<String, dynamic>, d.id))
                          .toList();
                      return Column(
                        children: menus.map((menu) => _MenuCard(
                          menu: menu,
                          onAdd: () => _addToCart(menu),
                        )).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Nav
          _BottomNav(activeIndex: _navIdx, cartCount: _cartCount, onTap: _onNav),
        ],
      ),
    );
  }

  Widget _cartBadge() => GestureDetector(
    onTap: _goToCart,
    child: Stack(clipBehavior: Clip.none, children: [
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: const Icon(Icons.shopping_bag_outlined, color: _white, size: 20),
      ),
      if (_cartCount > 0)
        Positioned(
          top: -4, right: -4,
          child: Container(
            width: 18, height: 18,
            decoration: const BoxDecoration(color: _orange, shape: BoxShape.circle),
            child: Center(child: Text('$_cartCount',
                style: const TextStyle(color: _white, fontSize: 10, fontWeight: FontWeight.w800))),
          ),
        ),
    ]),
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

class _MenuCard extends StatelessWidget {
  final MenuModel menu;
  final VoidCallback onAdd;
  const _MenuCard({required this.menu, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 64, height: 64, decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(
                menu.imageUrl.isEmpty ? '🍱' : '🍽️',
                style: const TextStyle(fontSize: 32),
              )),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(menu.name, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 15, color: _textBlack)),
                const SizedBox(height: 2),
                Text(menu.description, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(fontSize: 12, color: _textGray)),
                const SizedBox(height: 6),
                Text('Rp. ${menu.price.toStringAsFixed(0)}',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: _orange, fontSize: 14)),
              ],
            )),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_orange, _orangeL]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: _orange.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 3))],
                ),
                child: const Icon(Icons.add, color: _white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int activeIndex;
  final int cartCount;
  final Function(int) onTap;
  const _BottomNav({required this.activeIndex, required this.cartCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Beranda'),
              _navItem(1, Icons.shopping_bag_rounded, Icons.shopping_bag_outlined, 'Keranjang', badge: cartCount),
              _navItem(2, Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Riwayat'),
              _navItem(3, Icons.person_rounded, Icons.person_outlined, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData activeIcon, IconData inactiveIcon, String label, {int badge = 0}) {
    final on = activeIndex == idx;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(idx),
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
              Icon(on ? activeIcon : inactiveIcon, color: on ? _orange : Colors.grey.shade400, size: 24),
              if (badge > 0)
                Positioned(top: -6, right: -8,
                  child: Container(width: 16, height: 16,
                    decoration: const BoxDecoration(color: _red, shape: BoxShape.circle),
                    child: Center(child: Text('$badge',
                        style: const TextStyle(color: _white, fontSize: 9, fontWeight: FontWeight.w800))))),
            ]),
            const SizedBox(height: 3),
            Text(label, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700,
                color: on ? _orange : Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }
}
