import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Glassmorphism & Neon Palette
  static const Color primary = Color(0xFF00E5FF); // Neon Cyan
  static const Color primaryLight = Color(0xFF80F2FF);
  static const Color background = Color(0xFF000000); // Pure Black
  static const Color surface = Color(0x1AFFFFFF); // 10% White for Glass
  static const Color border = Color(0x33FFFFFF); // 20% White for Glass border
  static const Color glassBorder = Color(0x4DFFFFFF); // 30% White
  static const Color glassGlow = Color(0x3300E5FF); // Cyan glow
  
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure White
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% White
  static const Color textHint = Color(0x80FFFFFF); // 50% White
  
  static const Color error = Color(0xFFFF3B30); // Neon Red/Orange
  static const Color success = Color(0xFF34C759); // Neon Green
  static const Color warning = Color(0xFFFFCC00); // Neon Yellow
  static const Color accent = Color(0xFFFF007F); // Neon Magenta
  
  static const Color online = Color(0xFF34C759); // Neon Green
  static const Color offline = Color(0x80FFFFFF); // 50% White

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
