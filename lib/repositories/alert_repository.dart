import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert_model.dart';

class AlertRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _alertsRef;

  AlertRepository() {
    _alertsRef = _firestore.collection('alerts');
  }

  /// Create a new alert (from ESP32 or app)
  Future<String> createAlert(Alert alert) async {
    final docRef = await _alertsRef.add(alert.toJson());
    return docRef.id;
  }

  /// Get alerts for a device (real-time)
  Stream<List<Alert>> getAlertsForDevice(String deviceId) {
    return _alertsRef
        .where('deviceId', isEqualTo: deviceId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Alert.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Get active (unacknowledged) alerts
  Stream<List<Alert>> getActiveAlerts(String deviceId) {
    return _alertsRef
        .where('deviceId', isEqualTo: deviceId)
        .where('acknowledged', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Alert.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Acknowledge an alert
  Future<void> acknowledgeAlert(String id) async {
    await _alertsRef.doc(id).update({
      'acknowledged': true,
      'acknowledgedAt': Timestamp.now(),
    });
  }

  /// Delete an alert
  Future<void> deleteAlert(String id) async {
    await _alertsRef.doc(id).delete();
  }
}
