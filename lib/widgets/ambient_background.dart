import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AmbientBackground extends StatelessWidget {
  final Widget child;
  
  const AmbientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark black background
        Container(color: AppColors.background),
        // Top right blue glow
        Positioned(
          top: -120,
          right: -120,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withAlpha(28),
            ),
          ),
        ),
        // Bottom left teal glow
        Positioned(
          bottom: -120,
          left: -120,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withAlpha(20),
            ),
          ),
        ),
        // Heavy blur over the glow
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
            child: Container(color: Colors.transparent),
          ),
        ),
        // The foreground content
        Positioned.fill(child: child),
      ],
    );
  }
}
