import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final Color? borderColor;
  final Color? backgroundColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.padding,
    this.margin,
    this.borderRadius,
    this.width,
    this.height,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultRadius = BorderRadius.circular(16);
    final currentRadius = borderRadius ?? defaultRadius;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: currentRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.surface,
              borderRadius: currentRadius,
              border: Border.all(
                color: borderColor ?? AppColors.glassBorder,
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
