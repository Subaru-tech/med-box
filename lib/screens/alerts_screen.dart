import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/helpers.dart';
import '../models/alert_model.dart';
import '../providers/device_provider.dart';
import '../providers/alert_provider.dart';
import '../widgets/ambient_background.dart';
import '../widgets/glass_container.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alertProvider = context.watch<AlertProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.alerts),
        actions: [
          if (alertProvider.activeAlerts.isNotEmpty)
            TextButton(
              onPressed: () {
                for (final alert in alertProvider.activeAlerts) {
                  alertProvider.acknowledgeAlert(alert.id);
                }
              },
              child: const Text(
                'Acknowledge All',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: AmbientBackground(
        child: alertProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary)))
            : alertProvider.alerts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: alertProvider.alerts.length,
                    itemBuilder: (context, index) {
                      final alert = alertProvider.alerts[index];
                      return _AlertCard(
                        alert: alert,
                        onAcknowledge: () =>
                            alertProvider.acknowledgeAlert(alert.id),
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
          Icon(Icons.check_circle_outline,
              size: 64, color: AppColors.success.withAlpha(127)),
          const SizedBox(height: 16),
          const Text(
            AppStrings.noActiveAlerts,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'All clear — no alerts to report',
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback onAcknowledge;

  const _AlertCard({required this.alert, required this.onAcknowledge});

  @override
  Widget build(BuildContext context) {
    final isSos = alert.type == AlertType.sos;
    final borderColor =
        alert.acknowledged ? AppColors.border : AppColors.error.withAlpha(77);

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isSos ? AppColors.sosAlert : AppColors.warning)
                      .withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isSos ? Icons.emergency : Icons.warning_amber_rounded,
                  color: isSos ? AppColors.sosAlert : AppColors.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.typeLabel,
                      style: TextStyle(
                        color: alert.acknowledged
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${alert.deviceName} • ${Helpers.formatDateTime(alert.timestamp)}',
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (alert.acknowledged)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppColors.success.withAlpha(77)),
                  ),
                  child: const Text(
                    '✓ Seen',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          if (!alert.acknowledged) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAcknowledge,
                icon: const Icon(Icons.check, size: 18),
                label: const Text(AppStrings.acknowledge),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
