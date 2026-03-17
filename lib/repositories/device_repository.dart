import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/device_model.dart';

class DeviceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _devicesRef;

  DeviceRepository() {
    _devicesRef = _firestore.collection('devices');
  }

  /// Get all registered devices
  Stream<List<Device>> getDevices() {
    return _devicesRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Device.fromJson(doc.data(), doc.id))
        .toList());
  }

  /// Register a new device
  Future<void> registerDevice(Device device) async {
    await _devicesRef.doc(device.id).set(device.toJson());
  }

  /// Update device status
  Future<void> updateDeviceStatus(String id, bool isOnline) async {
    await _devicesRef.doc(id).update({
      'isOnline': isOnline,
      'lastSeen': Timestamp.now(),
    });
  }

  /// Remove a device
  Future<void> removeDevice(String id) async {
    await _devicesRef.doc(id).delete();
  }

  /// Update device info
  Future<void> updateDeviceInfo(String id, Map<String, dynamic> data) async {
    await _devicesRef.doc(id).update(data);
  }
}
