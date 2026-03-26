import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // student | parent | admin
  final String language; // en | rw | fr
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.language = 'en',
    this.avatarUrl,
    required this.createdAt,
    required this.lastLoginAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'student',
      language: data['language'] ?? 'en',
      avatarUrl: data['avatarUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'name': name,
        'role': role,
        'language': language,
        'avatarUrl': avatarUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      };

  UserModel copyWith({
    String? name,
    String? role,
    String? language,
    String? avatarUrl,
    DateTime? lastLoginAt,
  }) =>
      UserModel(
        uid: uid,
        email: email,
        name: name ?? this.name,
        role: role ?? this.role,
        language: language ?? this.language,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        createdAt: createdAt,
        lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      );
}
