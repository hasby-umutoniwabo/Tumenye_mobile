import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/models/lesson_model.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../../core/services/firestore_service.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  int _i = 0;
  bool _completing = false;

  void _next(List<LessonModel> lessons, String moduleId) async {
    final lesson = lessons[_i];
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (_i < lessons.length - 1) {
      // Mark current lesson complete then move on
      if (uid != null) {
        await FirestoreService().markLessonComplete(
            uid, lesson.id, moduleId, lessons.length,
            estimatedMinutes: lesson.estimatedMinutes);
      }
      setState(() => _i++);
    } else {
      // Last lesson — mark complete then go to quiz
      if (uid != null) {
        setState(() => _completing = true);
        await FirestoreService().markLessonComplete(
            uid, lesson.id, moduleId, lessons.length,
            estimatedMinutes: lesson.estimatedMinutes);
        setState(() => _completing = false);
      }
      if (mounted) context.push(AppRoutes.quiz, extra: lesson.id);
    }
  }

  void _back() {
    if (_i > 0) setState(() => _i--);
  }

  @override
  Widget build(BuildContext context) {
    final moduleId =
        GoRouterState.of(context).extra as String? ?? 'word';
    final lessonsAsync = ref.watch(lessonsProvider(moduleId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: lessonsAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (lessons) {
            if (lessons.isEmpty) {
              return const Center(child: Text('No lessons found.'));
            }
            final lesson = lessons[_i];
            final total = lessons.length;
            final step = _i + 1;

            return Column(children: [
              // ─── Header ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                child: Row(children: [
                  GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 22)),
                  const Spacer(),
                  Text(lesson.title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontSize: 16),
                      overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  const Icon(Icons.help_outline,
                      size: 22, color: AppColors.textHint),
                ]),
              ),
              // ─── Progress bar ────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                child:
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('Step $step of $total',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  const SizedBox(height: 5),
                  Row(
                      children: List.generate(
                          total,
                          (i) => Expanded(
                                child: Container(
                                    height: 4,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 1.5),
                                    decoration: BoxDecoration(
                                        color: i < step
                                            ? AppColors.primary
                                            : AppColors.border,
                                        borderRadius:
                                            BorderRadius.circular(2))),
                              ))),
                ]),
              ),
              const SizedBox(height: 16),
              // ─── Content ─────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 160,
                          decoration: BoxDecoration(
                              color: const Color(0xFFF5F0E8),
                              borderRadius:
                                  BorderRadius.circular(16)),
                          child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(_moduleIcon(moduleId),
                                    size: 64,
                                    color: AppColors.accentBlue),
                                const SizedBox(height: 10),
                                Container(
                                    width: 80,
                                    height: 4,
                                    decoration: BoxDecoration(
                                        color: AppColors.border,
                                        borderRadius:
                                            BorderRadius.circular(2))),
                                const SizedBox(height: 5),
                                Container(
                                    width: 56,
                                    height: 4,
                                    decoration: BoxDecoration(
                                        color: AppColors.border,
                                        borderRadius:
                                            BorderRadius.circular(2))),
                              ]),
                        ),
                        const SizedBox(height: 20),
                        Text(lesson.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall),
                        const SizedBox(height: 12),
                        Text(lesson.content,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    height: 1.65,
                                    color: AppColors.textPrimary)),
                        const SizedBox(height: 16),
                        if (lesson.translation.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius:
                                    BorderRadius.circular(12)),
                            child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.translate,
                                      size: 16,
                                      color: AppColors.primary),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                        const Text('Kinyarwanda:',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.w700,
                                                color:
                                                    AppColors.primary)),
                                        const SizedBox(height: 4),
                                        Text(lesson.translation,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    color: AppColors
                                                        .textPrimary,
                                                    height: 1.6)),
                                      ])),
                                ]),
                          ),
                        const SizedBox(height: 24),
                      ]),
                ),
              ),
              // ─── Navigation buttons ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 26),
                child: Row(children: [
                  if (_i > 0) ...[
                    Expanded(
                        flex: 2,
                        child: OutlinedButton.icon(
                          onPressed: _back,
                          icon: const Icon(Icons.arrow_back, size: 15),
                          label: const Text('Back'),
                          style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              side: const BorderSide(
                                  color: AppColors.border),
                              foregroundColor:
                                  AppColors.textSecondary,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12))),
                        )),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: _completing
                            ? null
                            : () => _next(lessons, moduleId),
                        icon: Text(_i == lessons.length - 1
                            ? 'Take Quiz'
                            : 'Next'),
                        label: _completing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white))
                            : const Icon(Icons.arrow_forward,
                                size: 15),
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 48)),
                      )),
                ]),
              ),
            ]);
          },
        ),
      ),
    );
  }

  IconData _moduleIcon(String moduleId) {
    switch (moduleId) {
      case 'word':
        return Icons.description;
      case 'excel':
        return Icons.grid_on;
      case 'email':
        return Icons.email;
      case 'safety':
        return Icons.shield;
      default:
        return Icons.book;
    }
  }
}
