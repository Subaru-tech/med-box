import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/ambient_background.dart';
import '../widgets/glass_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

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
                  backgroundColor: AppColors.primary.withAlpha(51), // 0.2 * 255
                  child: Text(
                    authProvider.user?.name[0].toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.user?.name ?? 'User Name',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.user?.email ?? 'email@example.com',
                        style: const TextStyle(
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

          _buildSectionHeader('General'),
          _buildSettingTile(
            icon: Icons.notifications_none_outlined,
            title: 'Notifications',
            subtitle: 'Manage alert preferences',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.security_outlined,
            title: 'Security',
            subtitle: 'Password and authentication',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English (US)',
            onTap: () {},
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('Support'),
          _buildSettingTile(
            icon: Icons.help_outline,
            title: 'Help Center',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: 'About App',
            onTap: () {},
          ),
          const SizedBox(height: 32),

          CustomButton(
            text: 'Sign Out',
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            isOutlined: true,
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
          ),
        ],
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

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: AppColors.textHint, fontSize: 13),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
    );
  }
}
