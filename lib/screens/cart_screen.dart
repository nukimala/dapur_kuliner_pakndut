import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_helper.dart';
import '../widgets/shared_bottom_nav.dart';
import '../nav_helper.dart';

const _red      = Color(0xFFC0321A);
const _redDark  = Color(0xFF8B1A0A);
const _orange   = Color(0xFFF5A524);
const _cream    = Color(0xFFF7F0E6);
const _textBlack = Color(0xFF1C1C1C);
const _textGray  = Color(0xFF888888);
const _green     = Color(0xFF2BB84A);

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  List<CartItemModel> _items = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    _items = await _db.getCartItems(_uid);
    setState(() => _loading = false);
  }

  double get _subtotal => _items.fold(0, (s, i) => s + (i.menu?.price ?? 0) * i.quantity);

  Future<void> _update(CartItemModel item, int delta) async {
    final nq = item.quantity + delta;
    if (nq < 1) { await _db.removeCartItem(item.id!); }
    else { await _db.updateCartQuantity(item.id!, nq); }
    _load();
  }

  void _checkout() {
    if (_items.isEmpty) return;
    const phone = "6285730803962";
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? user?.email ?? "Pelanggan";

    // Build message preview
    final StringBuffer sb = StringBuffer();
    sb.writeln("Halo Dapur Pakndut, saya ingin memesan:\n");
    for (var i in _items) {
      if (i.menu != null) {
        sb.writeln("- ${i.quantity}x ${i.menu!.name} (Rp ${i.menu!.price.toStringAsFixed(0)})");
      }
    }
    sb.writeln("\n*Total: ${_fmt(_subtotal)}*");
    sb.writeln("Pemesan: $name");
    final message = sb.toString();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: const Color(0xFFE8F8EF), borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Text('💬', style: TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Konfirmasi Pesanan', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16, color: _textBlack)),
                  Text('via WhatsApp', style: GoogleFonts.nunito(fontSize: 12, color: _textGray)),
                ]),
              ]),
              const SizedBox(height: 16),

              // Order items
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F0E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._items.where((i) => i.menu != null).map((i) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(child: Text(
                          '${i.quantity}× ${i.menu!.name}',
                          style: GoogleFonts.nunito(fontSize: 13, color: _textBlack, fontWeight: FontWeight.w600),
                        )),
                        Text(
                          _fmt(i.menu!.price * i.quantity),
                          style: GoogleFonts.nunito(fontSize: 13, color: _orange, fontWeight: FontWeight.w700),
                        ),
                      ]),
                    )),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(color: Color(0xFFE0D8CE), height: 1),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Total', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14, color: _textBlack)),
                      Text(_fmt(_subtotal), style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14, color: _red)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // WA info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8EF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.message, color: Color(0xFF25D366), size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    'Pesan akan dikirim ke +62 857-3080-3962',
                    style: GoogleFonts.nunito(fontSize: 12, color: const Color(0xFF1A7A3A), fontWeight: FontWeight.w600),
                  )),
                ]),
              ),
              const SizedBox(height: 18),

              // Buttons
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Batal', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14, color: _textGray)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: Text('Ya, Kirim!', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14)),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final url = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");
                      try {
                        final order = OrderModel(
                          buyerUid: user?.uid ?? '', buyerName: name, totalPrice: _subtotal,
                          status: 'Pending', timestamp: DateTime.now(),
                          items: OrderModel.cartItemsToMapList(_items),
                        );
                        await FirebaseFirestore.instance.collection('orders').add(order.toMap());
                      } catch (_) {}
                      await _db.clearCart(_uid);
                      if (mounted) setState(() => _items.clear());
                      try {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } catch (_) {
                        await launchUrl(url, mode: LaunchMode.platformDefault);
                      }
                      if (mounted) Navigator.pop(context);
                    },
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(double n) => 'Rp. ${n.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\b)'), (m) => '${m[1]}.')}';

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
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text('Keranjang Belanja',
                      style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                ]),
              )),
            ]),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _orange))
                : _items.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('🛒', style: TextStyle(fontSize: 60)),
                        const SizedBox(height: 12),
                        Text('Keranjang kosong', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 18, color: _textBlack)),
                        const SizedBox(height: 4),
                        Text('Yuk, tambahkan menu favoritmu!', style: GoogleFonts.nunito(fontSize: 13, color: _textGray)),
                      ]))
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        children: [
                          ..._items.map((item) {
                            final menu = item.menu;
                            if (menu == null) return const SizedBox.shrink();
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white, borderRadius: BorderRadius.circular(18),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
                              ),
                              padding: const EdgeInsets.all(14),
                              child: Row(children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: SizedBox(width: 88, height: 88,
                                    child: menu.imageUrl.isNotEmpty
                                        ? Image.network(menu.imageUrl, fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) => _foodEmoji())
                                        : _foodEmoji(),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(menu.name,
                                        style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 15, color: _textBlack)),
                                    const SizedBox(height: 4),
                                    Text(_fmt(menu.price),
                                        style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: _orange, fontSize: 16)),
                                    const SizedBox(height: 10),
                                    Row(children: [
                                      _qtyBtn(Icons.remove, () => _update(item, -1)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                        child: Text('${item.quantity}',
                                            style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16)),
                                      ),
                                      _qtyBtn(Icons.add, () => _update(item, 1)),
                                    ]),
                                  ],
                                )),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.black38, size: 22),
                                  onPressed: () => _update(item, -item.quantity),
                                ),
                              ]),
                            );
                          }),

                          // Summary
                          Container(
                            margin: const EdgeInsets.only(top: 4, bottom: 16),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white, borderRadius: BorderRadius.circular(18),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                            ),
                            child: Column(children: [
                              Text('Ringkasan Pesanan',
                                  style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 15, color: _textBlack)),
                              const SizedBox(height: 14),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text('Subtotal (${_items.fold(0, (s, i) => s + i.quantity)} Item)',
                                    style: GoogleFonts.nunito(fontSize: 13, color: _textGray)),
                                Text(_fmt(_subtotal), style: GoogleFonts.nunito(fontSize: 13, color: _textGray)),
                              ]),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text('Biaya Admin', style: GoogleFonts.nunito(fontSize: 13, color: _textGray)),
                                  Text('Gratis', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: _green)),
                                ]),
                              ),
                              const Divider(color: Color(0xFFE8E8E8), height: 1),
                              const SizedBox(height: 12),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text('Total bayar', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 15, color: _textBlack)),
                                Text(_fmt(_subtotal), style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 15, color: _red)),
                              ]),
                            ]),
                          ),
                        ],
                      ),
          ),

          // ── Footer
          if (!_loading && _items.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Total Bayar', style: GoogleFonts.nunito(fontSize: 12, color: _textGray)),
                      Text(_fmt(_subtotal), style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 19, color: _red)),
                    ]),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                          elevation: 0,
                        ).copyWith(
                          backgroundColor: WidgetStateProperty.all(_green),
                          overlayColor: WidgetStateProperty.all(Colors.white12),
                        ),
                        icon: const Icon(Icons.message, size: 18),
                        label: Text('Checkout via Whatsapp',
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 13)),
                        onPressed: _checkout,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // ── Checkout footer is above, nav is below
          SharedBottomNav(
            activeIndex: 1,
            cartCount: _items.fold(0, (s, i) => s + i.quantity),
            onTap: (i) => navigateToTab(context, i),
          ),
        ],
      ),
    );
  }

  Widget _foodEmoji() => Container(
    color: const Color(0xFFFFF3E0),
    child: const Center(child: Text('🍱', style: TextStyle(fontSize: 36))),
  );

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: Colors.white, size: 18, weight: 900),
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
