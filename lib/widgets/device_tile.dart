import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/helpers.dart';
import '../models/device_model.dart';
import 'status_badge.dart';
import 'glass_container.dart';
class DeviceTile extends StatelessWidget {
  final Device device;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DeviceTile({
    super.key,
    required this.device,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: (device.isOnline ? AppColors.online : AppColors.offline).withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.developer_board,
            color: device.isOnline ? AppColors.online : AppColors.offline,
          ),
        ),
        title: Row(
          children: [
            Text(
              device.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(isOnline: device.isOnline, size: 8, showGlow: false),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  device.location,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Last seen: ${Helpers.formatDateTime(device.lastSeen)}',
              style: TextStyle(fontSize: 11, color: AppColors.textHint),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
          color: AppColors.surface,
          onSelected: (value) {
            if (value == 'edit' && onEdit != null) onEdit!();
            if (value == 'delete' && onDelete != null) onDelete!();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 12),
                  Text('Edit Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                  SizedBox(width: 12),
                  Text('Remove Device', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
