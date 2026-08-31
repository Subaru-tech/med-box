import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../repositories/appointment_repository.dart';
import '../services/network_service.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentRepository _repository = AppointmentRepository();
  final NetworkService _networkService = NetworkService();
  List<Appointment> _appointments = [];
  bool _isLoading = false;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;

  List<Appointment> get upcomingAppointments =>
      _appointments.where((a) => !a.isPast).toList();

  List<Appointment> get pastAppointments =>
      _appointments.where((a) => a.isPast).toList();

  /// Listen to appointments by caregiver
  void listenToAppointments(String caregiverId) {
    _isLoading = true;
    _repository.getAppointmentsByCaregiver(caregiverId).listen((data) {
      _appointments = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Add a new appointment
  Future<bool> addAppointment({
    required String title,
    String? notes,
    required DateTime date,
    required int hour,
    required int minute,
    required String deviceId,
    required String caregiverId,
    String? ipAddress,
  }) async {
    try {
      final appointment = Appointment(
        id: '',
        title: title,
        notes: notes,
        date: date,
        hour: hour,
        minute: minute,
        deviceId: deviceId,
        caregiverId: caregiverId,
        createdAt: DateTime.now(),
      );

      await _repository.addAppointment(appointment);

      // Push to device if online
      if (ipAddress != null && ipAddress.isNotEmpty) {
        final dateTime = DateTime(date.year, date.month, date.day, hour, minute);
        await _networkService.sendAppointmentReminder(
          ipAddress: ipAddress,
          title: title,
          dateTime: dateTime,
          notes: notes,
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete an appointment
  Future<void> deleteAppointment(String id) async {
    await _repository.deleteAppointment(id);
  }
}
