import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color red = Color(0xFFC0321A);
  static const Color redDark = Color(0xFF8B1A0A);
  static const Color redLight = Color(0xFFF91605);
  static const Color orange = Color(0xFFF5A524);
  static const Color orangeDark = Color(0xFFE8920A);
  static const Color cream = Color(0xFFF7F0E6);
  static const Color white = Colors.white;

  // Text Colors
  static const Color textBlack = Color(0xFF1C1C1C);
  static const Color textGray = Color(0xFF888888);
  static const Color textMid = Color(0xFF555555);

  // Status Colors
  static const Color success = Color(0xFF2BB84A);
  static const Color error = Color(0xFFCC2A2A);

  // Gradient Red
  static const LinearGradient redGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [redLight, redDark],
  );

  // TextStyles
  static TextStyle heading(BuildContext context) {
    return GoogleFonts.nunito(
      fontSize: 24,
      fontWeight: FontWeight.w900,
      color: textBlack,
    );
  }

  static TextStyle subheading(BuildContext context) {
    return GoogleFonts.nunito(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: textBlack,
    );
  }

  static TextStyle body(BuildContext context) {
    return GoogleFonts.nunito(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: textMid,
    );
  }

  static TextStyle caption(BuildContext context) {
    return GoogleFonts.nunito(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: textGray,
    );
  }
}
