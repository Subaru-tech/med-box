import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final bool isOnline;
  final double size;
  final bool showLabel;
  final bool showGlow;

  const StatusBadge({
    super.key,
    required this.isOnline,
    this.size = 10,
    this.showLabel = false,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? AppColors.online : AppColors.offline;
    final label = isOnline ? 'Online' : 'Offline';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: showGlow
                ? [
                    BoxShadow(
                      color: color.withAlpha(102), // 0.4 * 255
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26), // 0.1 * 255
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(77)), // 0.3 * 255
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
