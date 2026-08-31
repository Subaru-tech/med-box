import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../models/device_model.dart';
import '../providers/device_provider.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/custom_textfield.dart';
import '../widgets/device_tile.dart';
import '../widgets/ambient_background.dart';
import '../widgets/glass_container.dart';

class ElderDeviceScreen extends StatefulWidget {
  const ElderDeviceScreen({super.key});

  @override
  State<ElderDeviceScreen> createState() => _ElderDeviceScreenState();
}

class _ElderDeviceScreenState extends State<ElderDeviceScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _idController = TextEditingController();
  final _ipController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _idController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  void _showAddDeviceSheet() {
    _nameController.clear();
    _locationController.clear();
    _idController.clear();
    _ipController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
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
                'Register ElderLink Device',
                style: AppTheme.display(fontSize: 21, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect your ElderLink Home Device',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Device Name',
                hint: 'e.g. Mom\'s Room',
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Location',
                hint: 'e.g. Living Room',
                controller: _locationController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Device ID',
                hint: 'ESP32_XXXXXX',
                controller: _idController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'IP Address',
                hint: '192.168.1.XX',
                controller: _ipController,
              ),
              const SizedBox(height: 32),
              GradientButton(
                text: AppStrings.registerDevice,
                onPressed: () {
                  if (_idController.text.isNotEmpty &&
                      _nameController.text.isNotEmpty) {
                    final device = Device(
                      id: _idController.text,
                      name: _nameController.text,
                      location: _locationController.text,
                      lastSeen: DateTime.now(),
                      ipAddress:
                          _ipController.text.isNotEmpty ? _ipController.text : null,
                    );
                    context.read<DeviceProvider>().registerDevice(device);
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('ElderLink Device')),
      body: AmbientBackground(
        child: deviceProvider.devices.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: deviceProvider.devices.length,
                itemBuilder: (context, index) {
                  final device = deviceProvider.devices[index];
                  return DeviceTile(
                    device: device,
                    onDelete: () => deviceProvider.removeDevice(device.id),
                    onEdit: () {},
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeviceSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other,
              size: 64, color: AppColors.textHint.withAlpha(127)),
          const SizedBox(height: 16),
          const Text(
            AppStrings.noDevices,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Register your ElderLink Home Device',
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: CustomButton(
              text: AppStrings.addFirstDevice,
              onPressed: _showAddDeviceSheet,
            ),
          ),
        ],
      ),
    );
  }
}
