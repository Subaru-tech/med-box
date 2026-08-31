import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String id;
  final String name;
  final String deviceId;
  final String caregiverId;
  final bool morningEnabled;
  final int? morningHour;
  final int? morningMinute;
  final bool morningTaken;
  final DateTime? morningTakenAt;

  final bool afternoonEnabled;
  final int? afternoonHour;
  final int? afternoonMinute;
  final bool afternoonTaken;
  final DateTime? afternoonTakenAt;

  final bool nightEnabled;
  final int? nightHour;
  final int? nightMinute;
  final bool nightTaken;
  final DateTime? nightTakenAt;

  final DateTime createdAt;

  Medication({
    required this.id,
    required this.name,
    required this.deviceId,
    required this.caregiverId,
    this.morningEnabled = false,
    this.morningHour,
    this.morningMinute,
    this.morningTaken = false,
    this.morningTakenAt,
    this.afternoonEnabled = false,
    this.afternoonHour,
    this.afternoonMinute,
    this.afternoonTaken = false,
    this.afternoonTakenAt,
    this.nightEnabled = false,
    this.nightHour,
    this.nightMinute,
    this.nightTaken = false,
    this.nightTakenAt,
    required this.createdAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json, String id) {
    return Medication(
      id: id,
      name: json['name'] ?? '',
      deviceId: json['deviceId'] ?? '',
      caregiverId: json['caregiverId'] ?? '',
      morningEnabled: json['morningEnabled'] ?? false,
      morningHour: json['morningHour'],
      morningMinute: json['morningMinute'],
      morningTaken: json['morningTaken'] ?? false,
      morningTakenAt: json['morningTakenAt'] != null
          ? (json['morningTakenAt'] as Timestamp).toDate()
          : null,
      afternoonEnabled: json['afternoonEnabled'] ?? false,
      afternoonHour: json['afternoonHour'],
      afternoonMinute: json['afternoonMinute'],
      afternoonTaken: json['afternoonTaken'] ?? false,
      afternoonTakenAt: json['afternoonTakenAt'] != null
          ? (json['afternoonTakenAt'] as Timestamp).toDate()
          : null,
      nightEnabled: json['nightEnabled'] ?? false,
      nightHour: json['nightHour'],
      nightMinute: json['nightMinute'],
      nightTaken: json['nightTaken'] ?? false,
      nightTakenAt: json['nightTakenAt'] != null
          ? (json['nightTakenAt'] as Timestamp).toDate()
          : null,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'deviceId': deviceId,
      'caregiverId': caregiverId,
      'morningEnabled': morningEnabled,
      'morningHour': morningHour,
      'morningMinute': morningMinute,
      'morningTaken': morningTaken,
      'morningTakenAt':
          morningTakenAt != null ? Timestamp.fromDate(morningTakenAt!) : null,
      'afternoonEnabled': afternoonEnabled,
      'afternoonHour': afternoonHour,
      'afternoonMinute': afternoonMinute,
      'afternoonTaken': afternoonTaken,
      'afternoonTakenAt': afternoonTakenAt != null
          ? Timestamp.fromDate(afternoonTakenAt!)
          : null,
      'nightEnabled': nightEnabled,
      'nightHour': nightHour,
      'nightMinute': nightMinute,
      'nightTaken': nightTaken,
      'nightTakenAt':
          nightTakenAt != null ? Timestamp.fromDate(nightTakenAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  int get completedDoses {
    int count = 0;
    if (morningEnabled && morningTaken) count++;
    if (afternoonEnabled && afternoonTaken) count++;
    if (nightEnabled && nightTaken) count++;
    return count;
  }

  int get totalDoses {
    int count = 0;
    if (morningEnabled) count++;
    if (afternoonEnabled) count++;
    if (nightEnabled) count++;
    return count;
  }

  Medication copyWith({
    String? name,
    bool? morningEnabled,
    int? morningHour,
    int? morningMinute,
    bool? morningTaken,
    DateTime? morningTakenAt,
    bool? afternoonEnabled,
    int? afternoonHour,
    int? afternoonMinute,
    bool? afternoonTaken,
    DateTime? afternoonTakenAt,
    bool? nightEnabled,
    int? nightHour,
    int? nightMinute,
    bool? nightTaken,
    DateTime? nightTakenAt,
  }) {
    return Medication(
      id: id,
      name: name ?? this.name,
      deviceId: deviceId,
      caregiverId: caregiverId,
      morningEnabled: morningEnabled ?? this.morningEnabled,
      morningHour: morningHour ?? this.morningHour,
      morningMinute: morningMinute ?? this.morningMinute,
      morningTaken: morningTaken ?? this.morningTaken,
      morningTakenAt: morningTakenAt ?? this.morningTakenAt,
      afternoonEnabled: afternoonEnabled ?? this.afternoonEnabled,
      afternoonHour: afternoonHour ?? this.afternoonHour,
      afternoonMinute: afternoonMinute ?? this.afternoonMinute,
      afternoonTaken: afternoonTaken ?? this.afternoonTaken,
      afternoonTakenAt: afternoonTakenAt ?? this.afternoonTakenAt,
      nightEnabled: nightEnabled ?? this.nightEnabled,
      nightHour: nightHour ?? this.nightHour,
      nightMinute: nightMinute ?? this.nightMinute,
      nightTaken: nightTaken ?? this.nightTaken,
      nightTakenAt: nightTakenAt ?? this.nightTakenAt,
      createdAt: createdAt,
    );
  }
}
