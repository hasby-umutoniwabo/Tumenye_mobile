import 'package:cloud_firestore/cloud_firestore.dart';

class ModuleProgress {
  final String moduleId;
  final int completedLessons;
  final int totalLessons;
  final bool isCompleted;
  final DateTime lastAccessed;

  const ModuleProgress({
    required this.moduleId,
    required this.completedLessons,
    required this.totalLessons,
    required this.isCompleted,
    required this.lastAccessed,
  });

  double get percent =>
      totalLessons == 0 ? 0.0 : completedLessons / totalLessons;

  factory ModuleProgress.fromFirestore(String moduleId, DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ModuleProgress(
      moduleId: moduleId,
      completedLessons: d['completedLessons'] ?? 0,
      totalLessons: d['totalLessons'] ?? 0,
      isCompleted: d['isCompleted'] ?? false,
      lastAccessed:
          (d['lastAccessed'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'completedLessons': completedLessons,
        'totalLessons': totalLessons,
        'isCompleted': isCompleted,
        'lastAccessed': Timestamp.fromDate(lastAccessed),
      };
}
