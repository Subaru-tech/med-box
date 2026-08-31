import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String title;
  final String? notes;
  final DateTime date;
  final int hour;
  final int minute;
  final String deviceId;
  final String caregiverId;
  final DateTime createdAt;
  final bool acknowledged;

  Appointment({
    required this.id,
    required this.title,
    this.notes,
    required this.date,
    required this.hour,
    required this.minute,
    required this.deviceId,
    required this.caregiverId,
    required this.createdAt,
    this.acknowledged = false,
  });

  factory Appointment.fromJson(Map<String, dynamic> json, String id) {
    return Appointment(
      id: id,
      title: json['title'] ?? '',
      notes: json['notes'],
      date: (json['date'] as Timestamp).toDate(),
      hour: json['hour'] ?? 0,
      minute: json['minute'] ?? 0,
      deviceId: json['deviceId'] ?? '',
      caregiverId: json['caregiverId'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      acknowledged: json['acknowledged'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'notes': notes,
      'date': Timestamp.fromDate(date),
      'hour': hour,
      'minute': minute,
      'deviceId': deviceId,
      'caregiverId': caregiverId,
      'createdAt': Timestamp.fromDate(createdAt),
      'acknowledged': acknowledged,
    };
  }

  DateTime get dateTime =>
      DateTime(date.year, date.month, date.day, hour, minute);

  bool get isPast => dateTime.isBefore(DateTime.now());

  Appointment copyWith({
    String? title,
    String? notes,
    DateTime? date,
    int? hour,
    int? minute,
    bool? acknowledged,
  }) {
    return Appointment(
      id: id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      deviceId: deviceId,
      caregiverId: caregiverId,
      createdAt: createdAt,
      acknowledged: acknowledged ?? this.acknowledged,
    );
  }
}
