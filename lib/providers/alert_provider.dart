import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../repositories/alert_repository.dart';

class AlertProvider with ChangeNotifier {
  final AlertRepository _repository = AlertRepository();
  List<Alert> _alerts = [];
  bool _isLoading = false;

  List<Alert> get alerts => _alerts;
  bool get isLoading => _isLoading;

  List<Alert> get activeAlerts =>
      _alerts.where((a) => !a.acknowledged).toList();

  /// Listen to alerts for a device
  void listenToAlerts(String deviceId) {
    _isLoading = true;
    _repository.getAlertsForDevice(deviceId).listen((data) {
      _alerts = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Acknowledge an alert
  Future<void> acknowledgeAlert(String id) async {
    await _repository.acknowledgeAlert(id);
  }

  /// Delete an alert
  Future<void> deleteAlert(String id) async {
    await _repository.deleteAlert(id);
  }
}
