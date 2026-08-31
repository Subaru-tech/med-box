import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _appointmentsRef;

  AppointmentRepository() {
    _appointmentsRef = _firestore.collection('appointments');
  }

  /// Add a new appointment
  Future<String> addAppointment(Appointment appointment) async {
    final docRef = await _appointmentsRef.add(appointment.toJson());
    return docRef.id;
  }

  /// Get upcoming appointments for a device (real-time)
  Stream<List<Appointment>> getUpcomingAppointments(String deviceId) {
    return _appointmentsRef
        .where('deviceId', isEqualTo: deviceId)
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 1))))
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Get all appointments by caregiver
  Stream<List<Appointment>> getAppointmentsByCaregiver(String caregiverId) {
    return _appointmentsRef
        .where('caregiverId', isEqualTo: caregiverId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Mark appointment as acknowledged
  Future<void> acknowledgeAppointment(String id) async {
    await _appointmentsRef.doc(id).update({
      'acknowledged': true,
    });
  }

  /// Update appointment
  Future<void> updateAppointment(
      String id, Map<String, dynamic> data) async {
    await _appointmentsRef.doc(id).update(data);
  }

  /// Delete appointment
  Future<void> deleteAppointment(String id) async {
    await _appointmentsRef.doc(id).delete();
  }
}
