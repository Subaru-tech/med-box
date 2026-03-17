import 'package:cloud_firestore/cloud_firestore.dart';

class Notice {
  final String id;
  final String title;
  final String message;
  final String creatorId;
  final String deviceId;
  final String deviceName;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final bool isSent;
  Notice({
    required this.id,
    required this.title,
    required this.message,
    required this.creatorId,
    required this.deviceId,
    required this.deviceName,
    required this.createdAt,
    this.scheduledAt,
    this.isSent = false,
  });

  factory Notice.fromJson(Map<String, dynamic> json, String id) {
    return Notice(
      id: id,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      creatorId: json['creatorId'] ?? '',
      deviceId: json['deviceId'] ?? '',
      deviceName: json['deviceName'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      scheduledAt: json['scheduledAt'] != null 
          ? (json['scheduledAt'] as Timestamp).toDate() 
          : null,
      isSent: json['isSent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'creatorId': creatorId,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'createdAt': Timestamp.fromDate(createdAt),
      'scheduledAt': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
      'isSent': isSent,
    };
  }

  Notice copyWith({
    String? title,
    String? message,
    bool? isSent,
    DateTime? scheduledAt,
  }) {
    return Notice(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      creatorId: creatorId,
      deviceId: deviceId,
      deviceName: deviceName,
      createdAt: createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isSent: isSent ?? this.isSent,
    );
  }
}
