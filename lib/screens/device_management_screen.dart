import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../models/device_model.dart';
import '../providers/device_provider.dart';
import '../services/network_service.dart';
import '../widgets/device_tile.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/custom_textfield.dart';
import '../widgets/ambient_background.dart';
import '../widgets/glass_container.dart';
class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _idController = TextEditingController();
  final _ipController = TextEditingController();
  final NetworkService _networkService = NetworkService();

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
              const Text(
                'Register New Board',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Board Name',
                hint: 'Main Hall Display',
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Location',
                hint: 'Floor 1, Entrance',
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
                text: 'Register Device',
                onPressed: () {
                  if (_idController.text.isNotEmpty && _nameController.text.isNotEmpty) {
                    final device = Device(
                      id: _idController.text,
                      name: _nameController.text,
                      location: _locationController.text,
                      lastSeen: DateTime.now(),
                      ipAddress: _ipController.text.isNotEmpty ? _ipController.text : null,
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

  void _showTimezoneDialog(Device device) {
    if (device.ipAddress == null || device.ipAddress!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device has no IP address configured')),
      );
      return;
    }

    String selectedTimezone = 'IST';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.public, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                const Text(AppStrings.setTimezone),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device: ${device.name}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedTimezone,
                      isExpanded: true,
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textPrimary),
                      items: _timezonePresets.map((tz) {
                        return DropdownMenuItem(
                          value: tz.name,
                          child: Text('${tz.name} (GMT${_formatOffset(tz.gmtOffsetSec)})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedTimezone = val);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final messenger = ScaffoldMessenger.of(context);
                  final tz = _timezonePresets.firstWhere((t) => t.name == selectedTimezone);
                  final success = await _networkService.setDeviceTimezone(
                    ipAddress: device.ipAddress!,
                    gmtOffsetSec: tz.gmtOffsetSec,
                    dstOffsetSec: tz.dstOffsetSec,
                    dstEnabled: tz.dstEnabled,
                    name: tz.name,
                  );
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? '${AppStrings.timezoneUpdated} Set to $selectedTimezone'
                            : AppStrings.genericError),
                      ),
                    );
                  }
                },
                child: const Text('Apply', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.devices)),
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
                    onEdit: () => _showTimezoneDialog(device),
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
          Icon(Icons.developer_board_off_outlined, 
              size: 64, 
              color: AppColors.textHint.withAlpha(127)),
          const SizedBox(height: 16),
          const Text(
            'No devices registered',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: CustomButton(
              text: 'Add First Device',
              onPressed: _showAddDeviceSheet,
            ),
          ),
        ],
      ),
    );
  }
}

// Timezone presets matching ESP32 firmware
class _TimezonePreset {
  final String name;
  final int gmtOffsetSec;
  final int dstOffsetSec;
  final bool dstEnabled;

  const _TimezonePreset(this.name, this.gmtOffsetSec, this.dstOffsetSec, this.dstEnabled);
}

const List<_TimezonePreset> _timezonePresets = [
  _TimezonePreset('IST', 19800, 0, false),       // India GMT+5:30
  _TimezonePreset('GMT', 0, 0, false),             // GMT+0
  _TimezonePreset('EST', -18000, 3600, true),      // US Eastern GMT-5
  _TimezonePreset('CET', 3600, 3600, true),        // Central Europe GMT+1
  _TimezonePreset('JST', 32400, 0, false),         // Japan GMT+9
  _TimezonePreset('AEST', 36000, 3600, true),      // Australia GMT+10
];

String _formatOffset(int seconds) {
  final hours = seconds ~/ 3600;
  final mins = (seconds.abs() % 3600) ~/ 60;
  if (mins > 0) {
    return '${hours >= 0 ? '+' : ''}$hours:${mins.toString().padLeft(2, '0')}';
  }
  return '${hours >= 0 ? '+' : ''}$hours';
}
