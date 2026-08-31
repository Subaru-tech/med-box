import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/helpers.dart';
import '../core/utils/validators.dart';
import '../models/appointment_model.dart';
import '../providers/device_provider.dart';
import '../providers/appointment_provider.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/custom_textfield.dart';
import '../widgets/ambient_background.dart';
import '../widgets/glass_container.dart';
import '../widgets/icon_badge.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  Widget build(BuildContext context) {
    final appointmentProvider = context.watch<AppointmentProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appointments)),
      body: AmbientBackground(
        child: appointmentProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary)))
            : appointmentProvider.appointments.isEmpty
                ? _buildEmptyState(context)
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (appointmentProvider.upcomingAppointments.isNotEmpty) ...[
                        const Text(
                          'Upcoming',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...appointmentProvider.upcomingAppointments.map(
                          (apt) => _AppointmentCard(appointment: apt),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (appointmentProvider.pastAppointments.isNotEmpty) ...[
                        const Text(
                          'Past',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...appointmentProvider.pastAppointments.map(
                          (apt) => _AppointmentCard(
                              appointment: apt, isPast: true),
                        ),
                      ],
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAppointmentSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note,
              size: 64, color: AppColors.textHint.withAlpha(127)),
          const SizedBox(height: 16),
          const Text(
            AppStrings.noAppointments,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: CustomButton(
              text: AppStrings.addAppointment,
              onPressed: () => _showAddAppointmentSheet(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAppointmentSheet(BuildContext context) {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return GlassContainer(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              top: 24,
              left: 24,
              right: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Appointment',
                    style: AppTheme.display(fontSize: 21, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: AppStrings.appointmentTitle,
                    hint: 'e.g. Cardiology appointment',
                    controller: titleController,
                    validator: Validators.validateAppointmentTitle,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Notes (optional)',
                    hint: 'Additional details...',
                    controller: notesController,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: ctx,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setSheetState(() => selectedDate = date);
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  Helpers.formatDate(selectedDate),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: ctx,
                              initialTime: selectedTime,
                            );
                            if (time != null) {
                              setSheetState(() => selectedTime = time);
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.access_time,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  selectedTime.format(ctx),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  GradientButton(
                    text: AppStrings.addAppointment,
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty) return;

                      final device = context.read<DeviceProvider>();
                      final aptProvider =
                          context.read<AppointmentProvider>();

                      await aptProvider.addAppointment(
                        title: titleController.text.trim(),
                        notes: notesController.text.trim().isEmpty
                            ? null
                            : notesController.text.trim(),
                        date: selectedDate,
                        hour: selectedTime.hour,
                        minute: selectedTime.minute,
                        deviceId: device.selectedDeviceId ?? '',
                        caregiverId: 'caregiver',
                        ipAddress: device.selectedDevice?.ipAddress,
                      );

                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    icon: Icons.add,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool isPast;

  const _AppointmentCard({required this.appointment, this.isPast = false});

  @override
  Widget build(BuildContext context) {
    final color = isPast ? AppColors.textHint : AppColors.appointment;

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderColor: isPast ? null : color.withAlpha(51),
      child: Row(
        children: [
          IconBadge(icon: Icons.event, color: color, size: 48, iconSize: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.title,
                  style: TextStyle(
                    color: isPast
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(
                      '${Helpers.formatDateShort(appointment.date)} • ${Helpers.formatTimeOfDay(appointment.hour, appointment.minute)}',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (appointment.notes != null &&
                    appointment.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    appointment.notes!,
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (!isPast && !appointment.acknowledged)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withAlpha(77)),
              ),
              child: const Text(
                'Pending',
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
