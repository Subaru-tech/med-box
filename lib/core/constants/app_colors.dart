import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ElderLink Palette — warm, trustworthy, care-oriented
  static const Color primary = Color(0xFF2D9CDB);      // Calming Blue
  static const Color primaryLight = Color(0xFF7CC4F0);
  static const Color background = Color(0xFF0F172A);    // Dark Navy
  static const Color surface = Color(0x1AFFFFFF);       // 10% White for Glass
  static const Color border = Color(0x33FFFFFF);        // 20% White for Glass border
  static const Color glassBorder = Color(0x4DFFFFFF);   // 30% White
  static const Color glassGlow = Color(0x332D9CDB);     // Blue glow

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);  // 70% White
  static const Color textHint = Color(0x80FFFFFF);       // 50% White

  static const Color error = Color(0xFFE74C3C);         // SOS Red
  static const Color success = Color(0xFF27AE60);       // Green
  static const Color warning = Color(0xFFF39C12);       // Amber
  static const Color accent = Color(0xFF9B59B6);        // Purple accent

  static const Color online = Color(0xFF27AE60);
  static const Color offline = Color(0x80FFFFFF);

  // Feature-specific colors
  static const Color medication = Color(0xFF2D9CDB);    // Blue
  static const Color message = Color(0xFF9B59B6);       // Purple
  static const Color appointment = Color(0xFFF39C12);   // Amber
  static const Color sosAlert = Color(0xFFE74C3C);      // Red

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF1A6FB5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sosGradient = LinearGradient(
    colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
