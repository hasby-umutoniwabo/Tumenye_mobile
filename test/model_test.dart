import 'package:flutter_test/flutter_test.dart';
import 'package:tumenye/core/models/user_model.dart';
import 'package:tumenye/core/models/lesson_model.dart';
import 'package:tumenye/core/models/quiz_model.dart';
import 'package:tumenye/core/models/progress_model.dart';
import 'package:tumenye/core/models/quiz_result_model.dart';
import 'package:tumenye/core/models/activity_model.dart';

void main() {
  // ─── UserModel ───────────────────────────────────────────────────────────────

  group('UserModel', () {
    final now = DateTime(2025, 1, 1);

    final user = UserModel(
      uid: 'uid-123',
      email: 'test@school.rw',
      name: 'Amina',
      role: 'student',
      language: 'rw',
      createdAt: DateTime(2025, 1, 1),
      lastLoginAt: DateTime(2025, 1, 1),
    );

    test('toMap includes all required keys', () {
      final map = user.toMap();
      expect(map.containsKey('email'), true);
      expect(map.containsKey('name'), true);
      expect(map.containsKey('role'), true);
      expect(map.containsKey('language'), true);
      expect(map.containsKey('createdAt'), true);
      expect(map.containsKey('lastLoginAt'), true);
    });

    test('toMap values match constructor values', () {
      final map = user.toMap();
      expect(map['email'], 'test@school.rw');
      expect(map['name'], 'Amina');
      expect(map['role'], 'student');
      expect(map['language'], 'rw');
    });

    test('avatarUrl is null by default', () {
      expect(user.avatarUrl, isNull);
    });

    test('copyWith preserves uid and email', () {
      final updated = user.copyWith(name: 'Marie', role: 'parent');
      expect(updated.uid, user.uid);
      expect(updated.email, user.email);
      expect(updated.name, 'Marie');
      expect(updated.role, 'parent');
    });

    test('copyWith without args produces identical values', () {
      final copy = user.copyWith();
      expect(copy.uid, user.uid);
      expect(copy.name, user.name);
      expect(copy.role, user.role);
    });

    test('default language is en when not specified', () {
      final u = UserModel(
        uid: 'u1',
        email: 'a@b.com',
        name: 'A',
        role: 'admin',
        createdAt: now,
        lastLoginAt: now,
      );
      expect(u.language, 'en');
    });
  });

  // ─── LessonModel ─────────────────────────────────────────────────────────────

  group('LessonModel', () {
    const lesson = LessonModel(
      id: 'word_1',
      moduleId: 'word',
      title: 'What is Word?',
      content: 'Microsoft Word is ...',
      translation: 'Microsoft Word ni ...',
      order: 1,
    );

    test('toMap includes all required keys', () {
      final map = lesson.toMap();
      expect(map.containsKey('moduleId'), true);
      expect(map.containsKey('title'), true);
      expect(map.containsKey('content'), true);
      expect(map.containsKey('translation'), true);
      expect(map.containsKey('order'), true);
      expect(map.containsKey('estimatedMinutes'), true);
    });

    test('toMap does NOT include id (stored as document key)', () {
      final map = lesson.toMap();
      expect(map.containsKey('id'), false);
    });

    test('toMap values match constructor values', () {
      final map = lesson.toMap();
      expect(map['moduleId'], 'word');
      expect(map['title'], 'What is Word?');
      expect(map['order'], 1);
    });

    test('estimatedMinutes defaults to 5', () {
      expect(lesson.estimatedMinutes, 5);
    });

    test('custom estimatedMinutes is stored correctly', () {
      const l = LessonModel(
        id: 'x',
        moduleId: 'x',
        title: 'x',
        content: 'x',
        translation: 'x',
        order: 1,
        estimatedMinutes: 10,
      );
      expect(l.toMap()['estimatedMinutes'], 10);
    });
  });

  // ─── QuestionModel ───────────────────────────────────────────────────────────

  group('QuestionModel', () {
    const q = QuestionModel(
      text: 'What is Word?',
      options: ['Games', 'Documents', 'Photos', 'Email'],
      correctIndex: 1,
      explanation: 'Word is for documents.',
      order: 1,
    );

    test('toMap round-trips through fromMap', () {
      final map = q.toMap();
      final restored = QuestionModel.fromMap(map);
      expect(restored.text, q.text);
      expect(restored.options, q.options);
      expect(restored.correctIndex, q.correctIndex);
      expect(restored.explanation, q.explanation);
      expect(restored.order, q.order);
    });

    test('fromMap falls back gracefully on missing fields', () {
      final q2 = QuestionModel.fromMap({});
      expect(q2.text, '');
      expect(q2.options, isEmpty);
      expect(q2.correctIndex, 0);
      expect(q2.explanation, '');
      expect(q2.order, 0);
    });

    test('toMap does not drop any keys', () {
      final map = q.toMap();
      expect(map.containsKey('text'), true);
      expect(map.containsKey('options'), true);
      expect(map.containsKey('correctIndex'), true);
      expect(map.containsKey('explanation'), true);
      expect(map.containsKey('order'), true);
    });
  });

  // ─── QuizModel ───────────────────────────────────────────────────────────────

  group('QuizModel', () {
    const quiz = QuizModel(
      id: 'word_1',
      lessonId: 'word_1',
      title: 'Word Quiz',
      passingScore: 70,
      questions: [
        QuestionModel(
          text: 'Q1?',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          explanation: 'A is correct.',
          order: 1,
        ),
      ],
    );

    test('toMap includes all keys', () {
      final map = quiz.toMap();
      expect(map.containsKey('lessonId'), true);
      expect(map.containsKey('title'), true);
      expect(map.containsKey('passingScore'), true);
      expect(map.containsKey('questions'), true);
    });

    test('toMap serializes questions list', () {
      final map = quiz.toMap();
      final questions = map['questions'] as List;
      expect(questions.length, 1);
      expect((questions.first as Map)['text'], 'Q1?');
    });

    test('toMap does NOT include id — stored as document key', () {
      final map = quiz.toMap();
      expect(map.containsKey('id'), false);
    });

    test('passingScore is 70', () {
      expect(quiz.passingScore, 70);
    });

    test('questions list is preserved', () {
      expect(quiz.questions.length, 1);
      expect(quiz.questions.first.correctIndex, 0);
    });
  });

  // ─── ModuleProgress ──────────────────────────────────────────────────────────

  group('ModuleProgress', () {
    final accessed = DateTime(2025, 6, 15);

    final progress = ModuleProgress(
      moduleId: 'word',
      completedLessons: 2,
      totalLessons: 3,
      isCompleted: false,
      lastAccessed: accessed,
    );

    test('percent calculates correctly', () {
      expect(progress.percent, closeTo(2 / 3, 0.001));
    });

    test('percent is 0 when totalLessons is 0', () {
      final p = ModuleProgress(
        moduleId: 'x',
        completedLessons: 0,
        totalLessons: 0,
        isCompleted: false,
        lastAccessed: accessed,
      );
      expect(p.percent, 0.0);
    });

    test('percent is 1.0 when fully complete', () {
      final p = ModuleProgress(
        moduleId: 'word',
        completedLessons: 3,
        totalLessons: 3,
        isCompleted: true,
        lastAccessed: accessed,
      );
      expect(p.percent, closeTo(1.0, 0.001));
    });

    test('percent never exceeds 1.0', () {
      expect(progress.percent, lessThanOrEqualTo(1.0));
    });

    test('toMap includes all keys', () {
      final map = progress.toMap();
      expect(map.containsKey('completedLessons'), true);
      expect(map.containsKey('totalLessons'), true);
      expect(map.containsKey('isCompleted'), true);
      expect(map.containsKey('lastAccessed'), true);
    });

    test('toMap stores isCompleted as false', () {
      expect(progress.toMap()['isCompleted'], false);
    });
  });

  // ─── QuizResultModel ─────────────────────────────────────────────────────────

  group('QuizResultModel', () {
    final attempted = DateTime(2025, 3, 10);

    final result = QuizResultModel(
      quizId: 'word_1',
      moduleId: 'word',
      score: 2,
      total: 3,
      passed: true,
      attemptedAt: attempted,
    );

    test('percent calculates correctly', () {
      expect(result.percent, closeTo(2 / 3, 0.001));
    });

    test('percent is 0 when total is 0', () {
      final r = QuizResultModel(
        quizId: 'x',
        moduleId: 'x',
        score: 0,
        total: 0,
        passed: false,
        attemptedAt: attempted,
      );
      expect(r.percent, 0.0);
    });

    test('percent is 1.0 on perfect score', () {
      final r = QuizResultModel(
        quizId: 'word_1',
        moduleId: 'word',
        score: 3,
        total: 3,
        passed: true,
        attemptedAt: attempted,
      );
      expect(r.percent, closeTo(1.0, 0.001));
    });

    test('passed flag is stored correctly', () {
      expect(result.passed, true);
    });

    test('failed result has passed = false', () {
      final failed = QuizResultModel(
        quizId: 'excel_1',
        moduleId: 'excel',
        score: 1,
        total: 3,
        passed: false,
        attemptedAt: attempted,
      );
      expect(failed.passed, false);
    });
  });

  // ─── ActivityModel ───────────────────────────────────────────────────────────

  group('ActivityModel', () {
    final now = DateTime(2025, 5, 20);

    final activity = ActivityModel(
      id: 'act1',
      type: 'quiz_passed',
      userId: 'u1',
      userName: 'Jean',
      moduleId: 'word',
      score: 3,
      total: 3,
      createdAt: DateTime(2025, 5, 20),
    );

    test('toMap includes required keys', () {
      final map = activity.toMap();
      expect(map.containsKey('type'), true);
      expect(map.containsKey('userId'), true);
      expect(map.containsKey('userName'), true);
      expect(map.containsKey('moduleId'), true);
      expect(map.containsKey('createdAt'), true);
    });

    test('toMap includes score when present', () {
      final map = activity.toMap();
      expect(map.containsKey('score'), true);
      expect(map['score'], 3);
    });

    test('toMap omits score when null', () {
      final a = ActivityModel(
        id: 'act2',
        type: 'module_completed',
        userId: 'u2',
        userName: 'Marie',
        moduleId: 'excel',
        createdAt: DateTime(2025, 5, 20),
      );
      final map = a.toMap();
      expect(map.containsKey('score'), false);
      expect(map.containsKey('total'), false);
    });

    test('toMap omits id — stored as document key', () {
      final map = activity.toMap();
      expect(map.containsKey('id'), false);
    });

    test('type is correctly set', () {
      expect(activity.type, 'quiz_passed');
    });
  });
}
