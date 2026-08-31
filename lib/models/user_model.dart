import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String role; // 'caregiver' or 'elderly'
  final String? elderlyPersonName;
  final String? linkedDeviceId;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    this.role = 'caregiver',
    this.elderlyPersonName,
    this.linkedDeviceId,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String uid) {
    return UserModel(
      uid: uid,
      name: json['name'] ?? '',
      role: json['role'] ?? 'caregiver',
      elderlyPersonName: json['elderlyPersonName'],
      linkedDeviceId: json['linkedDeviceId'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'elderlyPersonName': elderlyPersonName,
      'linkedDeviceId': linkedDeviceId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? role,
    String? elderlyPersonName,
    String? linkedDeviceId,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      role: role ?? this.role,
      elderlyPersonName: elderlyPersonName ?? this.elderlyPersonName,
      linkedDeviceId: linkedDeviceId ?? this.linkedDeviceId,
      createdAt: createdAt,
    );
  }
}
