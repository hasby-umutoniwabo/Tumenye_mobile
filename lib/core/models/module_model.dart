import 'package:cloud_firestore/cloud_firestore.dart';

class ModuleModel {
  final String id;
  final String title;
  final String description;
  final String iconKey;
  final int order;
  final int totalLessons;
  final String difficulty;
  final int colorValue;
  final bool isOfflineAvailable;

  const ModuleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.order,
    required this.totalLessons,
    required this.difficulty,
    required this.colorValue,
    this.isOfflineAvailable = true,
  });

  factory ModuleModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ModuleModel(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      iconKey: d['iconKey'] ?? 'book',
      order: d['order'] ?? 0,
      totalLessons: d['totalLessons'] ?? 0,
      difficulty: d['difficulty'] ?? 'beginner',
      colorValue: d['colorValue'] ?? 0xFF4A90E2,
      isOfflineAvailable: d['isOfflineAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'iconKey': iconKey,
        'order': order,
        'totalLessons': totalLessons,
        'difficulty': difficulty,
        'colorValue': colorValue,
        'isOfflineAvailable': isOfflineAvailable,
      };
}
