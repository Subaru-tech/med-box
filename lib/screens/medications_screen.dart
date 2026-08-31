import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/helpers.dart';
import '../core/utils/validators.dart';
import '../models/medication_model.dart';
import '../providers/device_provider.dart';
import '../providers/medication_provider.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/custom_textfield.dart';
import '../widgets/ambient_background.dart';
import '../widgets/glass_container.dart';

class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medicationProvider = context.watch<MedicationProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.medicines)),
      body: AmbientBackground(
        child: medicationProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary)))
            : medicationProvider.medications.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: medicationProvider.medications.length,
                    itemBuilder: (context, index) {
                      final med = medicationProvider.medications[index];
                      return _MedicationCard(medication: med);
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMedicineSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_outlined,
              size: 64, color: AppColors.textHint.withAlpha(127)),
          const SizedBox(height: 16),
          const Text(
            AppStrings.noMedicines,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: CustomButton(
              text: AppStrings.addMedicine,
              onPressed: () => _showAddMedicineSheet(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMedicineSheet(BuildContext context) {
    final nameController = TextEditingController();
    TimeOfDay morning = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay afternoon = const TimeOfDay(hour: 13, minute: 0);
    TimeOfDay night = const TimeOfDay(hour: 21, minute: 0);

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
                  const Text(
                    'Add Medicine',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: AppStrings.medicineName,
                    hint: 'e.g. Amlodipine',
                    controller: nameController,
                    validator: Validators.validateMedicineName,
                  ),
                  const SizedBox(height: 20),

                  _TimeSlotRow(
                    label: '🌅 Morning',
                    time: morning,
                    onTimeChanged: (t) =>
                        setSheetState(() => morning = t),
                  ),
                  const SizedBox(height: 12),
                  _TimeSlotRow(
                    label: '☀️ Afternoon',
                    time: afternoon,
                    onTimeChanged: (t) =>
                        setSheetState(() => afternoon = t),
                  ),
                  const SizedBox(height: 12),
                  _TimeSlotRow(
                    label: '🌙 Night',
                    time: night,
                    onTimeChanged: (t) =>
                        setSheetState(() => night = t),
                  ),
                  const SizedBox(height: 24),

                  GradientButton(
                    text: AppStrings.addMedicine,
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty) return;

                      final device = context.read<DeviceProvider>();
                      final medProvider =
                          context.read<MedicationProvider>();

                      await medProvider.addMedication(
                        name: nameController.text.trim(),
                        deviceId: device.selectedDeviceId ?? '',
                        caregiverId: 'caregiver',
                        morning: morning,
                        afternoon: afternoon,
                        night: night,
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

class _TimeSlotRow extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const _TimeSlotRow({
    required this.label,
    required this.time,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: InkWell(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: time,
              );
              if (picked != null) onTimeChanged(picked);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
                    time.format(context),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final Medication medication;

  const _MedicationCard({required this.medication});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.medication.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.medication,
                  color: AppColors.medication,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  medication.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${medication.completedDoses}/${medication.totalDoses}',
                style: TextStyle(
                  color: medication.completedDoses == medication.totalDoses
                      ? AppColors.success
                      : AppColors.warning,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              if (medication.morningEnabled)
                _DoseChip(
                  label: '🌅 ${_formatTime(medication.morningHour, medication.morningMinute)}',
                  taken: medication.morningTaken,
                ),
              if (medication.afternoonEnabled) ...[
                const SizedBox(width: 8),
                _DoseChip(
                  label: '☀️ ${_formatTime(medication.afternoonHour, medication.afternoonMinute)}',
                  taken: medication.afternoonTaken,
                ),
              ],
              if (medication.nightEnabled) ...[
                const SizedBox(width: 8),
                _DoseChip(
                  label: '🌙 ${_formatTime(medication.nightHour, medication.nightMinute)}',
                  taken: medication.nightTaken,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(int? hour, int? minute) {
    if (hour == null || minute == null) return '--:--';
    return Helpers.formatTimeOfDay(hour, minute);
  }
}

class _DoseChip extends StatelessWidget {
  final String label;
  final bool taken;

  const _DoseChip({required this.label, required this.taken});

  @override
  Widget build(BuildContext context) {
    final color = taken ? AppColors.success : AppColors.textHint;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (taken) ...[
            const SizedBox(width: 4),
            const Icon(Icons.check, size: 14, color: AppColors.success),
          ],
        ],
      ),
    );
  }
}
