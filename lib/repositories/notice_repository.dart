import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notice_model.dart';

class NoticeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _noticesRef;

  NoticeRepository() {
    _noticesRef = _firestore.collection('notices');
  }

  /// Create a new notice
  Future<String> createNotice(Notice notice) async {
    final docRef = await _noticesRef.add(notice.toJson());
    return docRef.id;
  }

  /// Get real-time notices for a specific device
  Stream<List<Notice>> getNoticesForDevice(String deviceId) {
    return _noticesRef
        .where('deviceId', isEqualTo: deviceId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Notice.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Get all notices created by a user
  Stream<List<Notice>> getNoticesByUser(String userId) {
    return _noticesRef
        .where('creatorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Notice.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Delete a notice
  Future<void> deleteNotice(String id) async {
    await _noticesRef.doc(id).delete();
  }

  /// Update notice status
  Future<void> updateNoticeStatus(String id, bool isSent) async {
    await _noticesRef.doc(id).update({'isSent': isSent});
  }

  /// Resend/Republish a notice (updates createdAt)
  Future<void> resendNotice(String id) async {
    await _noticesRef.doc(id).update({
      'createdAt': Timestamp.now(),
      'isSent': false,
    });
  }
}
