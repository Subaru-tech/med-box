import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../repositories/device_repository.dart';
import '../services/network_service.dart';

class DeviceProvider with ChangeNotifier {
  final DeviceRepository _repository = DeviceRepository();
  final NetworkService _networkService = NetworkService();
  List<Device> _devices = [];
  bool _isLoading = false;
  String? _selectedDeviceId;

  List<Device> get devices => _devices;
  List<Device> get onlineDevices => _devices.where((d) => d.isOnline).toList();
  bool get isLoading => _isLoading;
  String? get selectedDeviceId => _selectedDeviceId;

  DeviceProvider() {
    _init();
  }

  void _init() {
    _isLoading = true;
    _repository.getDevices().listen((data) {
      _devices = data;
      _isLoading = false;
      notifyListeners();
      
      // Check offline devices if they are actually online locally
      _checkLocalDevices();
    });
  }

  void _checkLocalDevices() async {
    for (var device in _devices) {
      if (device.ipAddress != null && device.ipAddress!.isNotEmpty) {
        final isActuallyOnline = await _networkService.pingDevice(device.ipAddress!);
        if (isActuallyOnline != device.isOnline) {
          await updateDeviceStatus(device.id, isActuallyOnline);
        }
      }
    }
  }

  void selectDevice(String? id) {
    _selectedDeviceId = id;
    notifyListeners();
  }

  Future<bool> registerDevice(Device device) async {
    try {
      await _repository.registerDevice(device);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateDeviceStatus(String id, bool isOnline) async {
    await _repository.updateDeviceStatus(id, isOnline);
  }

  Future<void> removeDevice(String id) async {
    await _repository.removeDevice(id);
  }

  Future<void> updateDevice(String id, String name, String location) async {
    await _repository.updateDeviceInfo(id, {
      'name': name,
      'location': location,
    });
  }

  /// Manually trigger a check for all local devices
  Future<void> refreshStatuses() async {
    _checkLocalDevices();
  }
}
