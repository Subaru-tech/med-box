import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ElderLink Palette — corporate blue + teal, restrained glass surfaces
  static const Color primary = Color(0xFF2563EB);       // Corporate Blue
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color background = Color(0xFF0F172A);    // Slate Navy
  static const Color surface = Color(0x0FFFFFFF);       // 6% White for Glass
  static const Color border = Color(0x1FFFFFFF);        // 12% White for Glass border
  static const Color glassBorder = Color(0x33FFFFFF);   // 20% White
  static const Color glassGlow = Color(0x332563EB);     // Blue glow

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);  // 70% White
  static const Color textHint = Color(0x80FFFFFF);       // 50% White

  static const Color error = Color(0xFFDC2626);          // Alert Red
  static const Color success = Color(0xFF10B981);        // Emerald
  static const Color warning = Color(0xFFD97706);        // Amber
  static const Color accent = Color(0xFF0D9488);         // Teal accent

  static const Color online = Color(0xFF10B981);
  static const Color offline = Color(0x80FFFFFF);

  // Feature-specific colors
  static const Color medication = Color(0xFF2563EB);    // Blue
  static const Color message = Color(0xFF0D9488);       // Teal
  static const Color appointment = Color(0xFFD97706);   // Amber
  static const Color sosAlert = Color(0xFFDC2626);      // Red

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sosGradient = LinearGradient(
    colors: [error, Color(0xFF7F1D1D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
