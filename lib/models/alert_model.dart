import 'package:cloud_firestore/cloud_firestore.dart';

enum AlertType { sos, motion, temperature, offline }

class Alert {
  final String id;
  final AlertType type;
  final String deviceId;
  final String deviceName;
  final DateTime timestamp;
  final bool acknowledged;
  final DateTime? acknowledgedAt;
  final String? message;

  Alert({
    required this.id,
    required this.type,
    required this.deviceId,
    required this.deviceName,
    required this.timestamp,
    this.acknowledged = false,
    this.acknowledgedAt,
    this.message,
  });

  factory Alert.fromJson(Map<String, dynamic> json, String id) {
    return Alert(
      id: id,
      type: AlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AlertType.sos,
      ),
      deviceId: json['deviceId'] ?? '',
      deviceName: json['deviceName'] ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      acknowledged: json['acknowledged'] ?? false,
      acknowledgedAt: json['acknowledgedAt'] != null
          ? (json['acknowledgedAt'] as Timestamp).toDate()
          : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'timestamp': Timestamp.fromDate(timestamp),
      'acknowledged': acknowledged,
      'acknowledgedAt':
          acknowledgedAt != null ? Timestamp.fromDate(acknowledgedAt!) : null,
      'message': message,
    };
  }

  String get typeLabel {
    switch (type) {
      case AlertType.sos:
        return 'SOS Emergency';
      case AlertType.motion:
        return 'Motion Detected';
      case AlertType.temperature:
        return 'Temperature Alert';
      case AlertType.offline:
        return 'Device Offline';
    }
  }

  Alert copyWith({
    bool? acknowledged,
    DateTime? acknowledgedAt,
  }) {
    return Alert(
      id: id,
      type: type,
      deviceId: deviceId,
      deviceName: deviceName,
      timestamp: timestamp,
      acknowledged: acknowledged ?? this.acknowledged,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      message: message,
    );
  }
}
