import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class MessageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _messagesRef;

  MessageRepository() {
    _messagesRef = _firestore.collection('messages');
  }

  /// Send a message
  Future<String> sendMessage(Message message) async {
    final docRef = await _messagesRef.add(message.toJson());
    return docRef.id;
  }

  /// Get messages for a device (real-time)
  Stream<List<Message>> getMessagesForDevice(String deviceId) {
    return _messagesRef
        .where('deviceId', isEqualTo: deviceId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Get messages sent by a caregiver
  Stream<List<Message>> getMessagesBySender(String senderId) {
    return _messagesRef
        .where('senderId', isEqualTo: senderId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Mark a message as acknowledged
  Future<void> acknowledgeMessage(String id) async {
    await _messagesRef.doc(id).update({
      'acknowledged': true,
      'acknowledgedAt': Timestamp.now(),
    });
  }

  /// Delete a message
  Future<void> deleteMessage(String id) async {
    await _messagesRef.doc(id).delete();
  }
}
