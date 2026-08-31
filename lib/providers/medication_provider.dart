import 'package:flutter/material.dart';
import '../models/medication_model.dart';
import '../repositories/medication_repository.dart';
import '../services/network_service.dart';

class MedicationProvider with ChangeNotifier {
  final MedicationRepository _repository = MedicationRepository();
  final NetworkService _networkService = NetworkService();
  List<Medication> _medications = [];
  bool _isLoading = false;

  List<Medication> get medications => _medications;
  bool get isLoading => _isLoading;

  /// Listen to medications for a device
  void listenToMedications(String deviceId) {
    _isLoading = true;
    _repository.getMedicationsForDevice(deviceId).listen((data) {
      _medications = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Listen to medications by caregiver
  void listenToCaregiverMedications(String caregiverId) {
    _isLoading = true;
    _repository.getMedicationsByCaregiver(caregiverId).listen((data) {
      _medications = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Add a new medication
  Future<bool> addMedication({
    required String name,
    required String deviceId,
    required String caregiverId,
    required TimeOfDay morning,
    required TimeOfDay afternoon,
    required TimeOfDay night,
    String? ipAddress,
  }) async {
    try {
      final medication = Medication(
        id: '',
        name: name,
        deviceId: deviceId,
        caregiverId: caregiverId,
        morningEnabled: true,
        morningHour: morning.hour,
        morningMinute: morning.minute,
        afternoonEnabled: true,
        afternoonHour: afternoon.hour,
        afternoonMinute: afternoon.minute,
        nightEnabled: true,
        nightHour: night.hour,
        nightMinute: night.minute,
        createdAt: DateTime.now(),
      );

      await _repository.addMedication(medication);

      // Push reminders to device
      if (ipAddress != null && ipAddress.isNotEmpty) {
        await _networkService.sendMedicationReminder(
          ipAddress: ipAddress,
          medicineName: name,
          slot: 'morning',
          hour: morning.hour,
          minute: morning.minute,
        );
        await _networkService.sendMedicationReminder(
          ipAddress: ipAddress,
          medicineName: name,
          slot: 'afternoon',
          hour: afternoon.hour,
          minute: afternoon.minute,
        );
        await _networkService.sendMedicationReminder(
          ipAddress: ipAddress,
          medicineName: name,
          slot: 'night',
          hour: night.hour,
          minute: night.minute,
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a medication
  Future<void> deleteMedication(String id) async {
    await _repository.deleteMedication(id);
  }
}
