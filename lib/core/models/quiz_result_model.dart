import 'package:cloud_firestore/cloud_firestore.dart';

class QuizResultModel {
  final String quizId;
  final String moduleId;
  final int score;
  final int total;
  final bool passed;
  final DateTime attemptedAt;

  const QuizResultModel({
    required this.quizId,
    required this.moduleId,
    required this.score,
    required this.total,
    required this.passed,
    required this.attemptedAt,
  });

  double get percent => total == 0 ? 0.0 : score / total;

  factory QuizResultModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return QuizResultModel(
      quizId: doc.id,
      moduleId: d['moduleId'] as String? ?? '',
      score: (d['score'] as num?)?.toInt() ?? 0,
      total: (d['total'] as num?)?.toInt() ?? 1,
      passed: d['passed'] as bool? ?? false,
      attemptedAt: (d['attemptedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
