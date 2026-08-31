import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../providers/device_provider.dart';
import '../widgets/ambient_background.dart';
import '../widgets/glass_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: AmbientBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile Section
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withAlpha(51),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ElderLink Caregiver',
                          style: AppTheme.display(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Managing your loved one\'s care',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildSectionHeader('Caregiver'),
            _buildSectionGroup([
              _buildSettingTile(
                icon: Icons.person_outline,
                title: 'Caregiver Profile',
                subtitle: 'Manage your account',
                onTap: () => _showComingSoon(context, 'Caregiver Profile'),
              ),
              _buildSettingTile(
                icon: Icons.family_restroom,
                title: 'Elderly Person',
                subtitle: 'Link and manage your loved one',
                onTap: () => _showComingSoon(context, 'Elderly Person'),
                showDivider: false,
              ),
            ]),
            const SizedBox(height: 24),

            _buildSectionHeader('Device'),
            _buildSectionGroup([
              _buildSettingTile(
                icon: Icons.devices_other,
                title: 'ElderLink Device',
                subtitle:
                    '${deviceProvider.devices.length} device(s) registered',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.elderDevice),
              ),
              _buildSettingTile(
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                subtitle: 'Manage alert preferences',
                onTap: () => _showComingSoon(context, 'Notification settings'),
                showDivider: false,
              ),
            ]),
            const SizedBox(height: 24),

            _buildSectionHeader('About'),
            _buildSectionGroup([
              _buildSettingTile(
                icon: Icons.info_outline,
                title: 'About ElderLink',
                subtitle: 'Version 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),
              _buildSettingTile(
                icon: Icons.help_outline,
                title: 'Help Center',
                onTap: () => _showComingSoon(context, 'Help Center'),
                showDivider: false,
              ),
            ]),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'ElderLink v1.0.0',
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'A simple digital companion for elderly family members',
                style: TextStyle(color: AppColors.textHint, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature is coming soon')));
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.favorite_rounded,
                  color: AppColors.primary, size: 32),
              const SizedBox(height: 16),
              Text('About ElderLink',
                  style: AppTheme.display(fontSize: 19, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              const Text(
                'ElderLink connects family caregivers with an elderly '
                'loved one\'s Smart Medicine Box — medication schedules, '
                'messages, appointments and emergency alerts, all in one '
                'place.',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text('Version 1.0.0',
                  style: TextStyle(color: AppColors.textHint, fontSize: 12)),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textHint,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSectionGroup(List<Widget> tiles) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(children: tiles),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Icon(icon, color: AppColors.textSecondary),
          title: Text(
            title,
            style:
                const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: const TextStyle(
                      color: AppColors.textHint, fontSize: 13),
                )
              : null,
          trailing:
              const Icon(Icons.chevron_right, color: AppColors.textHint),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 52, endIndent: 12),
      ],
    );
  }
}
