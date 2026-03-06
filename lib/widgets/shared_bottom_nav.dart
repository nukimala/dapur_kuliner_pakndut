import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _orange = Color(0xFFF5A524);
const _red    = Color(0xFFC0321A);

/// Shared bottom navigation bar used across all main buyer screens.
/// [activeIndex]: 0=Beranda, 1=Keranjang, 2=Riwayat, 3=Profil
/// [cartCount]: badge count on cart tab
/// [onTap]: callback with tapped index
class SharedBottomNav extends StatelessWidget {
  final int activeIndex;
  final int cartCount;
  final Function(int) onTap;

  const SharedBottomNav({
    super.key,
    required this.activeIndex,
    required this.onTap,
    this.cartCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4))
        ],
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
              Icon(on ? activeIcon : inactiveIcon,
                  color: on ? _orange : Colors.grey.shade400, size: 24),
              if (badge > 0)
                Positioned(
                  top: -6, right: -8,
                  child: Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(color: _red, shape: BoxShape.circle),
                    child: Center(
                      child: Text('$badge',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: 3),
            Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: on ? _orange : Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }
}
