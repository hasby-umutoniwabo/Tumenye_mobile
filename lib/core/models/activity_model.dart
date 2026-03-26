import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String id;
  final String type; // 'quiz_passed' | 'module_completed'
  final String userId;
  final String userName;
  final String moduleId;
  final int? score;
  final int? total;
  final DateTime createdAt;

  const ActivityModel({
    required this.id,
    required this.type,
    required this.userId,
    required this.userName,
    required this.moduleId,
    this.score,
    this.total,
    required this.createdAt,
  });

  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      id: doc.id,
      type: d['type'] as String? ?? '',
      userId: d['userId'] as String? ?? '',
      userName: d['userName'] as String? ?? 'Unknown',
      moduleId: d['moduleId'] as String? ?? '',
      score: (d['score'] as num?)?.toInt(),
      total: (d['total'] as num?)?.toInt(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'userId': userId,
        'userName': userName,
        'moduleId': moduleId,
        if (score != null) 'score': score,
        if (total != null) 'total': total,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
