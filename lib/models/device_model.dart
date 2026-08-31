import 'package:cloud_firestore/cloud_firestore.dart';

class Device {
  final String id;
  final String name;
  final String location;
  final bool isOnline;
  final DateTime lastSeen;
  final double? temperature;
  final double? humidity;
  final bool? motionDetected;
  final String? fcmToken;
  final String? ipAddress;

  Device({
    required this.id,
    required this.name,
    required this.location,
    this.isOnline = false,
    required this.lastSeen,
    this.temperature,
    this.humidity,
    this.motionDetected,
    this.fcmToken,
    this.ipAddress,
  });

  factory Device.fromJson(Map<String, dynamic> json, String id) {
    return Device(
      id: id,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      isOnline: json['isOnline'] ?? false,
      lastSeen: (json['lastSeen'] as Timestamp).toDate(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble(),
      motionDetected: json['motionDetected'],
      fcmToken: json['fcmToken'],
      ipAddress: json['ipAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'isOnline': isOnline,
      'lastSeen': Timestamp.fromDate(lastSeen),
      'temperature': temperature,
      'humidity': humidity,
      'motionDetected': motionDetected,
      'fcmToken': fcmToken,
      'ipAddress': ipAddress,
    };
  }

  Device copyWith({
    String? name,
    String? location,
    bool? isOnline,
    DateTime? lastSeen,
    double? temperature,
    double? humidity,
    bool? motionDetected,
    String? fcmToken,
    String? ipAddress,
  }) {
    return Device(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      motionDetected: motionDetected ?? this.motionDetected,
      fcmToken: fcmToken ?? this.fcmToken,
      ipAddress: ipAddress ?? this.ipAddress,
    );
  }
}
