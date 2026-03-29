import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tumenye/core/models/user_model.dart';
import 'package:tumenye/core/models/module_model.dart';
import 'package:tumenye/core/models/lesson_model.dart';
import 'package:tumenye/core/models/quiz_model.dart';
import 'package:tumenye/core/models/progress_model.dart';
import 'package:tumenye/core/models/quiz_result_model.dart';
import 'package:tumenye/core/models/activity_model.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  // ─────────────────────────────────────────────
  // UserModel.fromFirestore
  // ─────────────────────────────────────────────
  group('UserModel.fromFirestore', () {
    test('parses all fields from Firestore document', () async {
      final now = DateTime(2024, 6, 1);
      await fakeFirestore.collection('users').doc('u1').set({
        'email': 'alice@example.com',
        'name': 'Alice',
        'role': 'student',
        'language': 'rw',
        'avatarUrl': 'https://cdn.example.com/avatar.jpg',
        'createdAt': Timestamp.fromDate(now),
        'lastLoginAt': Timestamp.fromDate(now),
      });
      final doc = await fakeFirestore.collection('users').doc('u1').get();
      final user = UserModel.fromFirestore(doc);

      expect(user.uid, 'u1');
      expect(user.email, 'alice@example.com');
      expect(user.name, 'Alice');
      expect(user.role, 'student');
      expect(user.language, 'rw');
      expect(user.avatarUrl, 'https://cdn.example.com/avatar.jpg');
    });

    test('uses defaults for missing fields', () async {
      await fakeFirestore.collection('users').doc('u2').set({});
      final doc = await fakeFirestore.collection('users').doc('u2').get();
      final user = UserModel.fromFirestore(doc);

      expect(user.email, '');
      expect(user.name, '');
      expect(user.role, 'student');
      expect(user.language, 'en');
      expect(user.avatarUrl, isNull);
    });

    test('toMap then fromFirestore roundtrips correctly', () async {
      final original = UserModel(
        uid: 'u3',
        email: 'bob@example.com',
        name: 'Bob',
        role: 'admin',
        language: 'fr',
        createdAt: DateTime(2024, 1, 1),
        lastLoginAt: DateTime(2024, 3, 1),
      );
      await fakeFirestore.collection('users').doc('u3').set(original.toMap());
      final doc = await fakeFirestore.collection('users').doc('u3').get();
      final restored = UserModel.fromFirestore(doc);

      expect(restored.uid, 'u3');
      expect(restored.email, 'bob@example.com');
      expect(restored.name, 'Bob');
      expect(restored.role, 'admin');
      expect(restored.language, 'fr');
    });
  });

  // ─────────────────────────────────────────────
  // ModuleModel.fromFirestore
  // ─────────────────────────────────────────────
  group('ModuleModel.fromFirestore', () {
    test('parses all fields correctly', () async {
      await fakeFirestore.collection('modules').doc('m1').set({
        'title': 'Word Processing',
        'description': 'Learn MS Word',
        'iconKey': 'word',
        'order': 1,
        'totalLessons': 10,
        'difficulty': 'beginner',
        'colorValue': 0xFF4A90E2,
        'isOfflineAvailable': true,
      });
      final doc = await fakeFirestore.collection('modules').doc('m1').get();
      final module = ModuleModel.fromFirestore(doc);

      expect(module.id, 'm1');
      expect(module.title, 'Word Processing');
      expect(module.description, 'Learn MS Word');
      expect(module.iconKey, 'word');
      expect(module.order, 1);
      expect(module.totalLessons, 10);
      expect(module.difficulty, 'beginner');
      expect(module.isOfflineAvailable, true);
    });

    test('uses defaults for missing fields', () async {
      await fakeFirestore.collection('modules').doc('m2').set({'title': 'Excel'});
      final doc = await fakeFirestore.collection('modules').doc('m2').get();
      final module = ModuleModel.fromFirestore(doc);

      expect(module.iconKey, 'book');
      expect(module.order, 0);
      expect(module.totalLessons, 0);
      expect(module.difficulty, 'beginner');
      expect(module.isOfflineAvailable, true);
    });

    test('toMap then fromFirestore roundtrips', () async {
      const original = ModuleModel(
        id: 'm3', title: 'Excel', description: 'Spreadsheets',
        iconKey: 'excel', order: 2, totalLessons: 8,
        difficulty: 'intermediate', colorValue: 0xFF3DDC84,
        isOfflineAvailable: false,
      );
      await fakeFirestore.collection('modules').doc('m3').set(original.toMap());
      final doc = await fakeFirestore.collection('modules').doc('m3').get();
      final restored = ModuleModel.fromFirestore(doc);

      expect(restored.title, 'Excel');
      expect(restored.difficulty, 'intermediate');
      expect(restored.isOfflineAvailable, false);
    });
  });

  // ─────────────────────────────────────────────
  // LessonModel.fromFirestore
  // ─────────────────────────────────────────────
  group('LessonModel.fromFirestore', () {
    test('parses all fields', () async {
      await fakeFirestore.collection('lessons').doc('l1').set({
        'moduleId': 'm1',
        'title': 'Introduction to Word',
        'content': 'Open Microsoft Word...',
        'translation': 'Fungura Microsoft Word...',
        'order': 1,
        'estimatedMinutes': 15,
      });
      final doc = await fakeFirestore.collection('lessons').doc('l1').get();
      final lesson = LessonModel.fromFirestore(doc);

      expect(lesson.id, 'l1');
      expect(lesson.moduleId, 'm1');
      expect(lesson.title, 'Introduction to Word');
      expect(lesson.content, 'Open Microsoft Word...');
      expect(lesson.translation, 'Fungura Microsoft Word...');
      expect(lesson.order, 1);
      expect(lesson.estimatedMinutes, 15);
    });

    test('uses defaults for missing fields', () async {
      await fakeFirestore.collection('lessons').doc('l2').set({'moduleId': 'm1'});
      final doc = await fakeFirestore.collection('lessons').doc('l2').get();
      final lesson = LessonModel.fromFirestore(doc);

      expect(lesson.title, '');
      expect(lesson.content, '');
      expect(lesson.estimatedMinutes, 5);
    });

    test('toMap then fromFirestore roundtrips', () async {
      const original = LessonModel(
        id: 'l3', moduleId: 'm2', title: 'Formulas',
        content: 'SUM function...', translation: 'Imibare...',
        order: 3, estimatedMinutes: 10,
      );
      await fakeFirestore.collection('lessons').doc('l3').set(original.toMap());
      final doc = await fakeFirestore.collection('lessons').doc('l3').get();
      final restored = LessonModel.fromFirestore(doc);

      expect(restored.title, 'Formulas');
      expect(restored.moduleId, 'm2');
      expect(restored.estimatedMinutes, 10);
    });
  });

  // ─────────────────────────────────────────────
  // QuizModel.fromFirestore
  // ─────────────────────────────────────────────
  group('QuizModel.fromFirestore', () {
    test('parses quiz with questions sorted by order', () async {
      await fakeFirestore.collection('quizzes').doc('q1').set({
        'lessonId': 'l1',
        'title': 'Word Quiz',
        'passingScore': 70,
        'questions': [
          {'text': 'Q2', 'options': ['A', 'B'], 'correctIndex': 0, 'explanation': '', 'order': 2},
          {'text': 'Q1', 'options': ['C', 'D'], 'correctIndex': 1, 'explanation': '', 'order': 1},
          {'text': 'Q3', 'options': ['E', 'F'], 'correctIndex': 0, 'explanation': '', 'order': 3},
        ],
      });
      final doc = await fakeFirestore.collection('quizzes').doc('q1').get();
      final quiz = QuizModel.fromFirestore(doc);

      expect(quiz.id, 'q1');
      expect(quiz.lessonId, 'l1');
      expect(quiz.title, 'Word Quiz');
      expect(quiz.passingScore, 70);
      expect(quiz.questions.length, 3);
      // Should be sorted by order
      expect(quiz.questions[0].text, 'Q1');
      expect(quiz.questions[1].text, 'Q2');
      expect(quiz.questions[2].text, 'Q3');
    });

    test('uses defaults for missing fields', () async {
      await fakeFirestore.collection('quizzes').doc('q2').set({});
      final doc = await fakeFirestore.collection('quizzes').doc('q2').get();
      final quiz = QuizModel.fromFirestore(doc);

      expect(quiz.lessonId, '');
      expect(quiz.title, 'Quick Quiz');
      expect(quiz.passingScore, 70);
      expect(quiz.questions, isEmpty);
    });

    test('toMap then fromFirestore roundtrips', () async {
      const original = QuizModel(
        id: 'q3', lessonId: 'l3', title: 'Excel Quiz',
        passingScore: 80,
        questions: [
          QuestionModel(text: 'What is SUM?', options: ['Add', 'Subtract'], correctIndex: 0, explanation: '', order: 1),
        ],
      );
      await fakeFirestore.collection('quizzes').doc('q3').set(original.toMap());
      final doc = await fakeFirestore.collection('quizzes').doc('q3').get();
      final restored = QuizModel.fromFirestore(doc);

      expect(restored.title, 'Excel Quiz');
      expect(restored.passingScore, 80);
      expect(restored.questions.length, 1);
      expect(restored.questions[0].text, 'What is SUM?');
    });
  });

  // ─────────────────────────────────────────────
  // ModuleProgress.fromFirestore
  // ─────────────────────────────────────────────
  group('ModuleProgress.fromFirestore', () {
    test('parses fields correctly', () async {
      final date = DateTime(2024, 3, 15);
      await fakeFirestore.collection('progress').doc('p1').set({
        'completedLessons': 5,
        'totalLessons': 10,
        'isCompleted': false,
        'lastAccessed': Timestamp.fromDate(date),
      });
      final doc = await fakeFirestore.collection('progress').doc('p1').get();
      final progress = ModuleProgress.fromFirestore('mod1', doc);

      expect(progress.moduleId, 'mod1');
      expect(progress.completedLessons, 5);
      expect(progress.totalLessons, 10);
      expect(progress.isCompleted, false);
      expect(progress.percent, closeTo(0.5, 0.001));
    });

    test('uses defaults for missing fields', () async {
      await fakeFirestore.collection('progress').doc('p2').set({});
      final doc = await fakeFirestore.collection('progress').doc('p2').get();
      final progress = ModuleProgress.fromFirestore('mod2', doc);

      expect(progress.completedLessons, 0);
      expect(progress.totalLessons, 0);
      expect(progress.isCompleted, false);
      expect(progress.percent, 0.0);
    });

    test('toMap then fromFirestore roundtrips', () async {
      final original = ModuleProgress(
        moduleId: 'mod3', completedLessons: 8, totalLessons: 10,
        isCompleted: false, lastAccessed: DateTime(2024, 5, 1),
      );
      await fakeFirestore.collection('progress').doc('p3').set(original.toMap());
      final doc = await fakeFirestore.collection('progress').doc('p3').get();
      final restored = ModuleProgress.fromFirestore('mod3', doc);

      expect(restored.completedLessons, 8);
      expect(restored.totalLessons, 10);
      expect(restored.isCompleted, false);
      expect(restored.percent, closeTo(0.8, 0.001));
    });
  });

  // ─────────────────────────────────────────────
  // QuizResultModel.fromFirestore
  // ─────────────────────────────────────────────
  group('QuizResultModel.fromFirestore', () {
    test('parses all fields correctly', () async {
      final date = DateTime(2024, 4, 1);
      await fakeFirestore.collection('results').doc('r1').set({
        'moduleId': 'm1',
        'score': 8,
        'total': 10,
        'passed': true,
        'attemptedAt': Timestamp.fromDate(date),
      });
      final doc = await fakeFirestore.collection('results').doc('r1').get();
      final result = QuizResultModel.fromFirestore(doc);

      expect(result.quizId, 'r1');
      expect(result.moduleId, 'm1');
      expect(result.score, 8);
      expect(result.total, 10);
      expect(result.passed, true);
      expect(result.percent, closeTo(0.8, 0.001));
    });

    test('uses defaults for missing fields', () async {
      await fakeFirestore.collection('results').doc('r2').set({});
      final doc = await fakeFirestore.collection('results').doc('r2').get();
      final result = QuizResultModel.fromFirestore(doc);

      expect(result.moduleId, '');
      expect(result.score, 0);
      expect(result.total, 1);
      expect(result.passed, false);
    });
  });

  // ─────────────────────────────────────────────
  // ActivityModel.fromFirestore
  // ─────────────────────────────────────────────
  group('ActivityModel.fromFirestore', () {
    test('parses quiz_passed activity with score', () async {
      final date = DateTime(2024, 2, 15);
      await fakeFirestore.collection('activity').doc('a1').set({
        'type': 'quiz_passed',
        'userId': 'u1',
        'userName': 'Alice',
        'moduleId': 'm1',
        'score': 9,
        'total': 10,
        'createdAt': Timestamp.fromDate(date),
      });
      final doc = await fakeFirestore.collection('activity').doc('a1').get();
      final activity = ActivityModel.fromFirestore(doc);

      expect(activity.id, 'a1');
      expect(activity.type, 'quiz_passed');
      expect(activity.userId, 'u1');
      expect(activity.userName, 'Alice');
      expect(activity.moduleId, 'm1');
      expect(activity.score, 9);
      expect(activity.total, 10);
    });

    test('parses module_completed activity without score', () async {
      await fakeFirestore.collection('activity').doc('a2').set({
        'type': 'module_completed',
        'userId': 'u2',
        'userName': 'Bob',
        'moduleId': 'm2',
        'createdAt': Timestamp.fromDate(DateTime(2024, 3, 1)),
      });
      final doc = await fakeFirestore.collection('activity').doc('a2').get();
      final activity = ActivityModel.fromFirestore(doc);

      expect(activity.type, 'module_completed');
      expect(activity.score, isNull);
      expect(activity.total, isNull);
    });

    test('uses defaults for missing fields', () async {
      await fakeFirestore.collection('activity').doc('a3').set({});
      final doc = await fakeFirestore.collection('activity').doc('a3').get();
      final activity = ActivityModel.fromFirestore(doc);

      expect(activity.type, '');
      expect(activity.userId, '');
      expect(activity.userName, 'Unknown');
      expect(activity.moduleId, '');
    });
  });
}
