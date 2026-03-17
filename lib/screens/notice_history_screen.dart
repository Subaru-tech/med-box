import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../providers/notice_provider.dart';
import '../widgets/notice_card.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/ambient_background.dart';

class NoticeHistoryScreen extends StatelessWidget {
  const NoticeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final noticeProvider = context.watch<NoticeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.history),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => noticeProvider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search notices...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                fillColor: AppColors.background,
              ),
            ),
          ),
        ),
      ),
      body: AmbientBackground(
        child: noticeProvider.isLoading
            ? const LoadingIndicator()
            : noticeProvider.notices.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: noticeProvider.notices.length,
                    itemBuilder: (context, index) {
                      final notice = noticeProvider.notices[index];
                      return NoticeCard(
                        notice: notice,
                        onDelete: () => _confirmDelete(context, noticeProvider, notice.id),
                        onResend: () => noticeProvider.resendNotice(notice.id),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 64, color: AppColors.textHint.withAlpha(127)),
          const SizedBox(height: 16),
          const Text(
            'No notices found',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, NoticeProvider provider, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notice'),
        content: const Text('Are you sure you want to delete this notice? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteNotice(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
