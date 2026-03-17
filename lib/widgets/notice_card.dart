import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/helpers.dart';
import '../models/notice_model.dart';
import 'status_badge.dart';

class NoticeCard extends StatelessWidget {
  final Notice notice;
  final VoidCallback? onResend;
  final VoidCallback? onDelete;

  const NoticeCard({
    super.key,
    required this.notice,
    this.onResend,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    notice.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusChip(
                  label: notice.isSent ? 'Sent' : 'Pending',
                  color: notice.isSent ? AppColors.online : AppColors.warning,
                  icon: notice.isSent ? Icons.check_circle_outline : Icons.access_time,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notice.message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.devices, size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(
                  notice.deviceName,
                  style: TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
                const Spacer(),
                Icon(Icons.calendar_today, size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(
                  Helpers.formatDateTime(notice.createdAt),
                  style: TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
              ],
            ),
            if (onResend != null || onDelete != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onResend != null)
                    TextButton.icon(
                      onPressed: onResend,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Resend'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    ),
                  if (onDelete != null)
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.error),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
