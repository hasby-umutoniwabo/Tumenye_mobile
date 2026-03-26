import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/module_model.dart';
import '../models/lesson_model.dart';
import '../models/quiz_model.dart';
import '../models/progress_model.dart';
import '../models/quiz_result_model.dart';
import '../models/activity_model.dart';
import '../models/user_model.dart';

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

// ─── Modules ──────────────────────────────────────────────────────────────────

final modulesProvider = StreamProvider<List<ModuleModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getModules();
});

// ─── Lessons ──────────────────────────────────────────────────────────────────

final lessonsProvider =
    StreamProvider.family<List<LessonModel>, String>((ref, moduleId) {
  return ref.watch(firestoreServiceProvider).streamLessonsForModule(moduleId);
});

// ─── Quiz ─────────────────────────────────────────────────────────────────────

final quizProvider =
    FutureProvider.family<QuizModel?, String>((ref, lessonId) {
  return ref.watch(firestoreServiceProvider).getQuizForLesson(lessonId);
});

// ─── Progress ─────────────────────────────────────────────────────────────────

final allProgressProvider =
    StreamProvider<List<ModuleProgress>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).getUserProgress(uid);
});

final moduleProgressProvider =
    StreamProvider.family<ModuleProgress?, String>((ref, moduleId) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return ref
      .watch(firestoreServiceProvider)
      .getModuleProgress(uid, moduleId);
});

// ─── Admin ────────────────────────────────────────────────────────────────────

final allStudentsProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getAllStudents();
});

final studentCountProvider = StreamProvider<int>((ref) {
  return ref.watch(firestoreServiceProvider).watchStudentCount();
});

final lessonCountProvider = FutureProvider<int>((ref) {
  return ref.watch(firestoreServiceProvider).getLessonCount();
});

final recentActivityProvider = StreamProvider<List<ActivityModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getRecentActivity();
});

// ─── Quiz Results ─────────────────────────────────────────────────────────────

final userQuizResultsProvider = StreamProvider<List<QuizResultModel>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).getUserQuizResults(uid);
});

// ─── Parent–Child ─────────────────────────────────────────────────────────────

final linkedChildrenProvider = StreamProvider<List<UserModel>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).getLinkedChildren(uid);
});

final childProgressProvider =
    StreamProvider.family<List<ModuleProgress>, String>((ref, childId) {
  return ref.watch(firestoreServiceProvider).getUserProgress(childId);
});

final childQuizResultsProvider =
    StreamProvider.family<List<QuizResultModel>, String>((ref, childId) {
  return ref.watch(firestoreServiceProvider).getUserQuizResults(childId);
});

final childScreenTimeProvider =
    StreamProvider.family<Map<String, int>, String>((ref, childId) {
  return ref.watch(firestoreServiceProvider).getWeeklyScreenTime(childId);
});

final childCompletedLessonsProvider =
    FutureProvider.family<List<String>, String>((ref, childId) {
  return ref.watch(firestoreServiceProvider).getCompletedLessonIds(childId);
});
