import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication_model.dart';

class MedicationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _medicationsRef;

  MedicationRepository() {
    _medicationsRef = _firestore.collection('medications');
  }

  /// Add a new medication
  Future<String> addMedication(Medication medication) async {
    final docRef = await _medicationsRef.add(medication.toJson());
    return docRef.id;
  }

  /// Get medications for a device (real-time)
  Stream<List<Medication>> getMedicationsForDevice(String deviceId) {
    return _medicationsRef
        .where('deviceId', isEqualTo: deviceId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medication.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Get medications by caregiver
  Stream<List<Medication>> getMedicationsByCaregiver(String caregiverId) {
    return _medicationsRef
        .where('caregiverId', isEqualTo: caregiverId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medication.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Update a dose as taken (called from ESP32 ack)
  Future<void> markDoseTaken(
      String medicationId, String slot, DateTime takenAt) async {
    await _medicationsRef.doc(medicationId).update({
      '${slot}Taken': true,
      '${slot}TakenAt': Timestamp.fromDate(takenAt),
    });
  }

  /// Reset daily doses (call at midnight)
  Future<void> resetDailyDoses(String medicationId) async {
    await _medicationsRef.doc(medicationId).update({
      'morningTaken': false,
      'morningTakenAt': null,
      'afternoonTaken': false,
      'afternoonTakenAt': null,
      'nightTaken': false,
      'nightTakenAt': null,
    });
  }

  /// Update medication info
  Future<void> updateMedication(
      String id, Map<String, dynamic> data) async {
    await _medicationsRef.doc(id).update(data);
  }

  /// Delete a medication
  Future<void> deleteMedication(String id) async {
    await _medicationsRef.doc(id).delete();
  }
}
