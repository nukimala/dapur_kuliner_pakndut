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
const _orange   = Color(0xFFF5A524);
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
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  final List<String> _categories = ['Semua', 'Makanan', 'Minuman'];

  @override
  void initState() { super.initState(); _loadCart(); }

  Future<void> _loadCart() async {
    final items = await _db.getCartItems(_uid);
    int c = 0;
    for (var i in items) {
      c += i.quantity;
    }
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
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFFF91605), Color(0xFF631105)], // matched with login_screen design colors
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(child: _blobs()),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 12, 28, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Selamat datang kembali di',
                                      style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.2)),
                                  const SizedBox(height: 12),
                                  Image.asset('assets/icons/logo.png', width: 220, fit: BoxFit.contain),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: _cartBadge(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: TextField(
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.toLowerCase();
                              });
                            },
                            style: GoogleFonts.nunito(color: _textBlack, fontSize: 16, fontWeight: FontWeight.w700),
                            decoration: InputDecoration(
                              hintText: 'Cari Menu Favoritmu....',
                              hintStyle: GoogleFonts.nunito(color: Colors.grey.shade400, fontWeight: FontWeight.w800, fontSize: 15),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                                child: Icon(Icons.search, color: Colors.grey.shade400, size: 28),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
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
                  Text('Kategori',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 22, color: _textBlack)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = cat == _selectedCategory;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? _orange : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: isSelected ? [] : [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))
                              ],
                            ),
                            child: Center(
                              child: Text(
                                cat,
                                style: GoogleFonts.nunito(
                                  color: isSelected ? Colors.white : _orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text('🍽️', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text('Menu Kami',
                          style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 22, color: _textBlack)),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                          .where((m) {
                             final matchesQuery = m.name.toLowerCase().contains(_searchQuery);
                             final matchesCategory = _selectedCategory == 'Semua' || m.category.toLowerCase() == _selectedCategory.toLowerCase();
                             return matchesQuery && matchesCategory;
                          })
                          .toList();
                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: menus.length,
                        itemBuilder: (context, index) {
                          return _MenuCard(
                            menu: menus[index],
                            onAdd: () => _addToCart(menus[index]),
                          );
                        },
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
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.shopping_cart, color: _white, size: 24),
      ),
      if (_cartCount > 0)
        Positioned(
          top: -2, right: -2,
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
  Positioned(right: -60, top: -60,
      child: Container(width: 280, height: 280,
          decoration: BoxDecoration(shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.07)))),
]);

class _MenuCard extends StatelessWidget {
  final MenuModel menu;
  final VoidCallback onAdd;
  const _MenuCard({required this.menu, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              child: menu.imageUrl.isNotEmpty
                  ? Image.network(menu.imageUrl, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey.shade200,
                      child: Icon(Icons.fastfood, color: Colors.grey.shade400, size: 40),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 14, color: _textBlack),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Rp. ${menu.price.toStringAsFixed(0)}',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: _orange, fontSize: 14),
                      ),
                    ),
                    GestureDetector(
                      onTap: onAdd,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: _white, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
              _navItem(0, Icons.home, Icons.home_outlined, 'Beranda'),
              _navItem(1, Icons.shopping_cart, Icons.shopping_cart_outlined, 'Keranjang', badge: cartCount),
              _navItem(2, Icons.library_books, Icons.library_books_outlined, 'Riwayat'),
              _navItem(3, Icons.person, Icons.person_outline, 'Profil'),
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
