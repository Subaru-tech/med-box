import 'package:flutter/material.dart';

/// ElderLink's signature icon treatment — a soft gradient-filled squircle,
/// used everywhere a category or status icon needs a badge (in place of
/// the flat tinted circles Material apps default to).
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double? iconSize;
  final double radius;

  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
    this.iconSize,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withAlpha(48), color.withAlpha(16)],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: color.withAlpha(56), width: 1),
      ),
      child: Icon(icon, color: color, size: iconSize ?? size * 0.46),
    );
  }
}
