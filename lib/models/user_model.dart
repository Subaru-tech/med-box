import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'admin' or 'viewer'
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.role = 'user',
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String uid) {
    return UserModel(
      uid: uid,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'user',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? role,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt,
    );
  }
}
