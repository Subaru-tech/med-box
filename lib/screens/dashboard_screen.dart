import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/helpers.dart';
import '../providers/auth_provider.dart';
import '../providers/device_provider.dart';
import '../providers/notice_provider.dart';
import '../widgets/status_badge.dart';
import '../widgets/ambient_background.dart';
import '../widgets/glass_container.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<NoticeProvider>().listenToUserNotices(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final deviceProvider = context.watch<DeviceProvider>();
    final noticeProvider = context.watch<NoticeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: AmbientBackground(
        child: RefreshIndicator(
          onRefresh: () async {
          // Refresh data logic
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                '${Helpers.getGreeting()},',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                authProvider.user?.name ?? 'User',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),

              // Device Status Summary
              GlassContainer(
                padding: const EdgeInsets.all(20),
                backgroundColor: AppColors.primary.withAlpha(26),
                borderColor: AppColors.primary,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Display Status',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${deviceProvider.onlineDevices.length} Devices Online',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(
                      isOnline: deviceProvider.onlineDevices.isNotEmpty,
                      size: 12,
                      showGlow: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _ActionCard(
                    title: 'Create\nNotice',
                    icon: Icons.add_to_photos_outlined,
                    color: AppColors.primary,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.createNotice),
                  ),
                  const SizedBox(width: 16),
                  _ActionCard(
                    title: 'Manage\nDevices',
                    icon: Icons.devices_outlined,
                    color: AppColors.accent,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.deviceManagement),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Recent notice
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Notice',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.noticeHistory),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (noticeProvider.notices.isEmpty)
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  child: const Column(
                    children: [
                      Icon(Icons.history, size: 40, color: AppColors.textHint),
                      SizedBox(height: 12),
                      Text(
                        'No notices yet',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              else
                _RecentNoticeCard(notice: noticeProvider.notices.first),
            ],
          ),
        ),
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createNotice),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(26), // 0.1 * 255
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentNoticeCard extends StatelessWidget {
  final dynamic notice;

  const _RecentNoticeCard({required this.notice});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                notice.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              StatusChip(
                label: notice.isSent ? 'Live' : 'Queued',
                color: notice.isSent ? AppColors.online : AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notice.message,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.devices, size: 14, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                notice.deviceName,
                style: const TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
              const Spacer(),
              const Icon(Icons.access_time, size: 14, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                Helpers.formatDateTime(notice.createdAt),
                style: const TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
