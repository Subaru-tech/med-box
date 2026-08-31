import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String deviceId;
  final DateTime timestamp;
  final bool acknowledged;
  final DateTime? acknowledgedAt;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.deviceId,
    required this.timestamp,
    this.acknowledged = false,
    this.acknowledgedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json, String id) {
    return Message(
      id: id,
      text: json['text'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      deviceId: json['deviceId'] ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      acknowledged: json['acknowledged'] ?? false,
      acknowledgedAt: json['acknowledgedAt'] != null
          ? (json['acknowledgedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'deviceId': deviceId,
      'timestamp': Timestamp.fromDate(timestamp),
      'acknowledged': acknowledged,
      'acknowledgedAt':
          acknowledgedAt != null ? Timestamp.fromDate(acknowledgedAt!) : null,
    };
  }

  Message copyWith({
    String? text,
    bool? acknowledged,
    DateTime? acknowledgedAt,
  }) {
    return Message(
      id: id,
      text: text ?? this.text,
      senderId: senderId,
      senderName: senderName,
      deviceId: deviceId,
      timestamp: timestamp,
      acknowledged: acknowledged ?? this.acknowledged,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
    );
  }
}
