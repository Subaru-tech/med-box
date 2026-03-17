import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/helpers.dart';
import '../core/utils/validators.dart';
import '../models/notice_model.dart';
import '../providers/auth_provider.dart';
import '../providers/device_provider.dart';
import '../providers/notice_provider.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/custom_textfield.dart';
import '../widgets/ambient_background.dart';
import '../widgets/glass_container.dart';
class CreateNoticeScreen extends StatefulWidget {
  const CreateNoticeScreen({super.key});

  @override
  State<CreateNoticeScreen> createState() => _CreateNoticeScreenState();
}

class _CreateNoticeScreenState extends State<CreateNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  bool _isScheduled = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  DateTime? _getScheduledDateTime() {
    if (!_isScheduled || _scheduledDate == null) return null;
    final time = _scheduledTime ?? const TimeOfDay(hour: 0, minute: 0);
    return DateTime(
      _scheduledDate!.year,
      _scheduledDate!.month,
      _scheduledDate!.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _scheduledDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _scheduledTime = time);
    }
  }

  Future<void> _handlePost() async {
    if (!_formKey.currentState!.validate()) return;
    
    final deviceProvider = context.read<DeviceProvider>();
    if (deviceProvider.selectedDeviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a target device')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final selectedDevice = deviceProvider.devices.firstWhere(
      (d) => d.id == deviceProvider.selectedDeviceId,
    );

    final scheduledDateTime = _getScheduledDateTime();

    final notice = Notice(
      id: '', // Will be set by Firestore
      title: _titleController.text,
      message: _messageController.text,
      creatorId: authProvider.user!.uid,
      deviceId: selectedDevice.id,
      deviceName: selectedDevice.name,
      createdAt: DateTime.now(),
      scheduledAt: scheduledDateTime,
    );

    final success = await context.read<NoticeProvider>().createNotice(
      notice,
      targetDevice: selectedDevice,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(scheduledDateTime != null
                ? AppStrings.noticeScheduled
                : AppStrings.noticeSuccess),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.genericError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.createNotice)),
      body: AmbientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: AppStrings.noticeTitle,
                hint: 'Urgent: Meeting at 2 PM',
                controller: _titleController,
                validator: Validators.validateNoticeTitle,
                maxLength: 50,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: AppStrings.noticeMessage,
                hint: 'Enter your message here...',
                controller: _messageController,
                validator: Validators.validateNoticeMessage,
                maxLength: 200,
              ),
              const SizedBox(height: 32),

              // ===== DEVICE SELECTOR =====
              const Text(
                AppStrings.selectDevice,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: deviceProvider.devices.any((d) => d.id == deviceProvider.selectedDeviceId) 
                        ? deviceProvider.selectedDeviceId 
                        : null,
                    hint: const Text('Choose a board', style: TextStyle(color: AppColors.textHint)),
                    isExpanded: true,
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(color: AppColors.textPrimary),
                    items: deviceProvider.devices.map((device) {
                      return DropdownMenuItem(
                        value: device.id,
                        child: Row(
                          children: [
                            Icon(Icons.developer_board, 
                                size: 18, 
                                color: device.isOnline ? AppColors.online : AppColors.offline),
                            const SizedBox(width: 12),
                            Text(device.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => deviceProvider.selectDevice(val),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ===== SCHEDULE TOGGLE =====
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 20,
                              color: _isScheduled ? AppColors.primary : AppColors.textHint,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              AppStrings.scheduleNotice,
                              style: TextStyle(
                                color: _isScheduled ? AppColors.textPrimary : AppColors.textSecondary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _isScheduled,
                          activeTrackColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() {
                              _isScheduled = val;
                              if (!val) {
                                _scheduledDate = null;
                                _scheduledTime = null;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    if (_isScheduled) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _pickDate,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      _scheduledDate != null
                                          ? Helpers.formatDate(_scheduledDate!)
                                          : 'Pick Date',
                                      style: TextStyle(
                                        color: _scheduledDate != null
                                            ? AppColors.textPrimary
                                            : AppColors.textHint,
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
                              onTap: _pickTime,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      _scheduledTime != null
                                          ? _scheduledTime!.format(context)
                                          : 'Pick Time',
                                      style: TextStyle(
                                        color: _scheduledTime != null
                                            ? AppColors.textPrimary
                                            : AppColors.textHint,
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
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 40),

              GradientButton(
                text: _isScheduled ? AppStrings.scheduleNotice : AppStrings.postNotice,
                isLoading: _isLoading,
                onPressed: _handlePost,
                icon: _isScheduled ? Icons.schedule_send : Icons.send_rounded,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
