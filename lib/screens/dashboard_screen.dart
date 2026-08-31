import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/helpers.dart';
import '../providers/device_provider.dart';
import '../providers/medication_provider.dart';
import '../providers/message_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/alert_provider.dart';
import '../providers/shell_nav_provider.dart';
import '../widgets/status_badge.dart';
import '../widgets/ambient_background.dart';
import '../widgets/glass_container.dart';
import '../widgets/icon_badge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();
    final medicationProvider = context.watch<MedicationProvider>();
    final messageProvider = context.watch<MessageProvider>();
    final appointmentProvider = context.watch<AppointmentProvider>();
    final alertProvider = context.watch<AlertProvider>();

    final device = deviceProvider.selectedDevice;
    final greeting = Helpers.getGreeting();
    final emoji = Helpers.getGreetingEmoji();

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
            await deviceProvider.refreshStatuses();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(
                  '$emoji $greeting,',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome to ElderLink',
                  style: AppTheme.display(fontSize: 26, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),

                // Device Status Card
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: AppColors.primary.withAlpha(26),
                  borderColor: AppColors.primary,
                  child: Row(
                    children: [
                      const IconBadge(
                        icon: Icons.favorite_rounded,
                        color: AppColors.primary,
                        size: 48,
                        iconSize: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              device?.name ?? 'No Device',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              device != null
                                  ? '${device.location} • ${device.isOnline ? "Online" : "Offline"}'
                                  : 'Register a device to get started',
                              style: TextStyle(
                                color: Colors.white.withAlpha(179),
                                fontSize: 13,
                              ),
                            ),
                            if (device?.temperature != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.thermostat_outlined,
                                      size: 13,
                                      color: Colors.white.withAlpha(179)),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${device!.temperature!.toStringAsFixed(1)}°C',
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(179),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      StatusBadge(
                        isOnline: device?.isOnline ?? false,
                        size: 12,
                        showGlow: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

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
                      icon: Icons.medication_outlined,
                      title: 'Medicines',
                      color: AppColors.medication,
                      onTap: () =>
                          context.read<ShellNavProvider>().setIndex(1),
                    ),
                    const SizedBox(width: 12),
                    _ActionCard(
                      icon: Icons.chat_bubble_outline,
                      title: 'Messages',
                      color: AppColors.message,
                      onTap: () =>
                          context.read<ShellNavProvider>().setIndex(2),
                    ),
                    const SizedBox(width: 12),
                    _ActionCard(
                      icon: Icons.event_outlined,
                      title: 'Appointments',
                      color: AppColors.appointment,
                      onTap: () =>
                          context.read<ShellNavProvider>().setIndex(3),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Status Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatusCard(
                        icon: Icons.medication_outlined,
                        label: 'Medicines',
                        value:
                            '${medicationProvider.medications.length} scheduled',
                        color: AppColors.medication,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatusCard(
                        icon: Icons.chat_bubble_outline,
                        label: 'Messages',
                        value:
                            '${messageProvider.pendingMessages} pending',
                        color: AppColors.message,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatusCard(
                        icon: Icons.event_outlined,
                        label: 'Appointments',
                        value:
                            '${appointmentProvider.upcomingAppointments.length} upcoming',
                        color: AppColors.appointment,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatusCard(
                        icon: Icons.warning_amber_rounded,
                        label: 'Alerts',
                        value:
                            '${alertProvider.activeAlerts.length} active',
                        color: AppColors.sosAlert,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Active Alerts
                if (alertProvider.activeAlerts.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: AppColors.error, size: 18),
                          const SizedBox(width: 6),
                          const Text(
                            'Active Alerts',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () =>
                            context.read<ShellNavProvider>().setIndex(4),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...alertProvider.activeAlerts.take(3).map(
                        (alert) => GlassContainer(
                          padding: const EdgeInsets.all(16),
                          borderColor: AppColors.error.withAlpha(77),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: AppColors.error, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      alert.typeLabel,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '${alert.deviceName} • ${Helpers.formatDateTime(alert.timestamp)}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: 12),
                ],

                // Medicine Status
                if (medicationProvider.medications.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.medication_outlined,
                              color: AppColors.textPrimary, size: 18),
                          const SizedBox(width: 6),
                          const Text(
                            'Medicine Status',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () =>
                            context.read<ShellNavProvider>().setIndex(1),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...medicationProvider.medications.take(3).map(
                        (med) => GlassContainer(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const IconBadge(
                                icon: Icons.medication,
                                color: AppColors.medication,
                                size: 40,
                                iconSize: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      med.name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '${med.completedDoses}/${med.totalDoses} doses taken today',
                                      style: TextStyle(
                                        color: med.completedDoses ==
                                                med.totalDoses
                                            ? AppColors.success
                                            : AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (med.completedDoses == med.totalDoses)
                                const Icon(Icons.check_circle,
                                    color: AppColors.success, size: 20)
                              else
                                const Icon(Icons.hourglass_bottom,
                                    color: AppColors.warning, size: 20),
                            ],
                          ),
                        ),
                      ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
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
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Column(
            children: [
              IconBadge(icon: icon, color: color, size: 40, iconSize: 20),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatusCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderColor: color.withAlpha(51),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
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
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
