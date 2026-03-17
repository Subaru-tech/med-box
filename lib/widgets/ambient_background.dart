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
        // Top right cyan blob
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withAlpha(50),
            ),
          ),
        ),
        // Bottom left magenta blob
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withAlpha(50),
            ),
          ),
        ),
        // Heavy blur over the blobs
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(color: Colors.transparent),
          ),
        ),
        // The foreground content
        Positioned.fill(child: child),
      ],
    );
  }
}
