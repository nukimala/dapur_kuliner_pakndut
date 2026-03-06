import 'package:flutter/material.dart';
import 'screens/buyer_home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/profile_screen.dart';

/// Navigates to the tab at [index] from anywhere.
/// Clears the back stack back to root, then pushes the target screen.
void navigateToTab(BuildContext context, int index) {
  Widget screen;
  switch (index) {
    case 0: screen = const BuyerHomeScreen(); break;
    case 1: screen = const CartScreen(); break;
    case 2: screen = const OrderHistoryScreen(); break;
    case 3: screen = const ProfileScreen(); break;
    default: return;
  }
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => screen),
    (route) => false,
  );
}
