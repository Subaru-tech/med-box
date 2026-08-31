import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/helpers.dart';
import '../models/message_model.dart';

class MessageCard extends StatelessWidget {
  final Message message;
  final VoidCallback? onDelete;

  const MessageCard({super.key, required this.message, this.onDelete});

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
                    '💌 From: ${message.senderName}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (message.acknowledged
                            ? AppColors.success
                            : AppColors.warning)
                        .withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (message.acknowledged
                              ? AppColors.success
                              : AppColors.warning)
                          .withAlpha(77),
                    ),
                  ),
                  child: Text(
                    message.acknowledged ? '✓ Acknowledged' : '⏳ Pending',
                    style: TextStyle(
                      color: message.acknowledged
                          ? AppColors.success
                          : AppColors.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message.text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(
                  Helpers.formatDateTime(message.timestamp),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textHint),
                ),
                const Spacer(),
                if (onDelete != null)
                  TextButton.icon(
                    onPressed: onDelete,
                    icon:
                        const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.error),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
