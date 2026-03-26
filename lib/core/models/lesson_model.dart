import 'package:cloud_firestore/cloud_firestore.dart';

class LessonModel {
  final String id;
  final String moduleId;
  final String title;
  final String content;
  final String translation; // Kinyarwanda translation
  final int order;
  final int estimatedMinutes;

  const LessonModel({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.content,
    required this.translation,
    required this.order,
    this.estimatedMinutes = 5,
  });

  factory LessonModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return LessonModel(
      id: doc.id,
      moduleId: d['moduleId'] ?? '',
      title: d['title'] ?? '',
      content: d['content'] ?? '',
      translation: d['translation'] ?? '',
      order: d['order'] ?? 0,
      estimatedMinutes: d['estimatedMinutes'] ?? 5,
    );
  }

  Map<String, dynamic> toMap() => {
        'moduleId': moduleId,
        'title': title,
        'content': content,
        'translation': translation,
        'order': order,
        'estimatedMinutes': estimatedMinutes,
      };
}
