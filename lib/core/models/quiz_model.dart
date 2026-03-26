import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int order;

  const QuestionModel({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.order,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> d) => QuestionModel(
        text: d['text'] ?? '',
        options: List<String>.from(d['options'] ?? []),
        correctIndex: d['correctIndex'] ?? 0,
        explanation: d['explanation'] ?? '',
        order: d['order'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'text': text,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
        'order': order,
      };
}

class QuizModel {
  final String id; // same as lessonId
  final String lessonId;
  final String title;
  final int passingScore;
  final List<QuestionModel> questions;

  const QuizModel({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.passingScore,
    required this.questions,
  });

  factory QuizModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final rawQs = List<Map<String, dynamic>>.from(d['questions'] ?? []);
    final questions = rawQs.map(QuestionModel.fromMap).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return QuizModel(
      id: doc.id,
      lessonId: d['lessonId'] ?? '',
      title: d['title'] ?? 'Quick Quiz',
      passingScore: d['passingScore'] ?? 70,
      questions: questions,
    );
  }

  Map<String, dynamic> toMap() => {
        'lessonId': lessonId,
        'title': title,
        'passingScore': passingScore,
        'questions': questions.map((q) => q.toMap()).toList(),
      };
}
