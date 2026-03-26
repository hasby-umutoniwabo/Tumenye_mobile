import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/module_model.dart';
import '../../../../core/models/progress_model.dart';
import '../../../../core/models/quiz_result_model.dart';
import '../../../../core/providers/firestore_providers.dart';

class ParentChildDetailScreen extends ConsumerWidget {
  final UserModel child;
  const ParentChildDetailScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressList =
        ref.watch(childProgressProvider(child.uid)).value ?? [];
    final quizResults =
        ref.watch(childQuizResultsProvider(child.uid)).value ?? [];
    final screenTimeAsync = ref.watch(childScreenTimeProvider(child.uid));
    final completedLessonsAsync =
        ref.watch(childCompletedLessonsProvider(child.uid));
    final modules = ref.watch(modulesProvider).value ?? [];

    final totalLessons =
        progressList.fold<int>(0, (s, p) => s + p.totalLessons);
    final doneLessons =
        progressList.fold<int>(0, (s, p) => s + p.completedLessons);
    final overallPct =
        totalLessons == 0 ? 0 : (doneLessons / totalLessons * 100).toInt();

    final screenTimeMap = screenTimeAsync.valueOrNull ?? {};
    final completedIds = completedLessonsAsync.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const Spacer(),
                  Text(child.name.isNotEmpty ? child.name : child.email,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const Spacer(),
                  const SizedBox(width: 20),
                ]),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Avatar + overall stats ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                          color: AppColors.accentOrange,
                          shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          (child.name.isNotEmpty
                                  ? child.name
                                  : child.email)[0]
                              .toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              child.name.isNotEmpty ? child.name : child.email,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(child.email,
                              style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 10),
                          Row(children: [
                            _StatPill(
                                label: '$overallPct%',
                                sub: 'Progress',
                                color: AppColors.primary),
                            const SizedBox(width: 8),
                            _StatPill(
                                label: '$doneLessons',
                                sub: 'Lessons',
                                color: AppColors.accentBlue),
                            const SizedBox(width: 8),
                            _StatPill(
                                label: '${quizResults.where((r) => r.passed).length}',
                                sub: 'Quizzes',
                                color: AppColors.accentOrange),
                          ]),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Screen Time Chart ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _ScreenTimeCard(screenTimeMap: screenTimeMap),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Quiz Scores ────────────────────────────────────────────────
            if (quizResults.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _QuizScoresCard(
                      quizResults: quizResults, modules: modules),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],

            // ── Module Breakdown with lessons ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _ModuleBreakdownCard(
                  progressList: progressList,
                  modules: modules,
                  completedLessonIds: completedIds,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

// ─── Stat pill ────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String label, sub;
  final Color color;
  const _StatPill(
      {required this.label, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color)),
        Text(sub,
            style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.7))),
      ]),
    );
  }
}

// ─── Screen Time Chart ────────────────────────────────────────────────────────

class _ScreenTimeCard extends StatelessWidget {
  final Map<String, int> screenTimeMap;
  const _ScreenTimeCard({required this.screenTimeMap});

  @override
  Widget build(BuildContext context) {
    // Build last 7 days
    final today = DateTime.now();
    final days = List.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      return _DayData(
        label: _dayLabel(d.weekday),
        minutes: screenTimeMap[key] ?? 0,
      );
    });

    final maxMin = days.fold<int>(1, (m, d) => d.minutes > m ? d.minutes : m);
    final totalMins = days.fold<int>(0, (s, d) => s + d.minutes);
    final totalHrs = totalMins ~/ 60;
    final remMins = totalMins % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Screen Time',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          Text(
              totalMins == 0
                  ? 'No activity'
                  : totalHrs > 0
                      ? '${totalHrs}h ${remMins}m this week'
                      : '${totalMins}m this week',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: days.map((d) {
              final frac = d.minutes / maxMin;
              final isToday = d.label == _dayLabel(today.weekday);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: frac.clamp(0.04, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isToday
                                    ? AppColors.primary
                                    : AppColors.primary.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(d.label,
                          style: TextStyle(
                              fontSize: 10,
                              color: isToday
                                  ? AppColors.primary
                                  : AppColors.textHint,
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.normal)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }

  String _dayLabel(int weekday) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[(weekday - 1) % 7];
  }
}

class _DayData {
  final String label;
  final int minutes;
  const _DayData({required this.label, required this.minutes});
}

// ─── Quiz Scores Card ─────────────────────────────────────────────────────────

class _QuizScoresCard extends StatelessWidget {
  final List<QuizResultModel> quizResults;
  final List<ModuleModel> modules;
  const _QuizScoresCard(
      {required this.quizResults, required this.modules});

  @override
  Widget build(BuildContext context) {
    final sorted = [...quizResults]
      ..sort((a, b) => b.attemptedAt.compareTo(a.attemptedAt));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Quiz Scores',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...sorted.take(5).map((r) {
          final mod = modules.cast<ModuleModel?>().firstWhere(
                (m) => m?.id == r.moduleId,
                orElse: () => null,
              );
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: (r.passed ? AppColors.primary : AppColors.accentRed)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(
                    r.passed ? Icons.check_circle_outline : Icons.close,
                    color:
                        r.passed ? AppColors.primary : AppColors.accentRed,
                    size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(mod?.title ?? r.moduleId,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(
                      '${r.score}/${r.total} · ${(r.percent * 100).toInt()}%',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ]),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: r.passed
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.accentRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(r.passed ? 'Passed' : 'Failed',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: r.passed
                            ? AppColors.primary
                            : AppColors.accentRed)),
              ),
            ]),
          );
        }),
      ]),
    );
  }
}

// ─── Module Breakdown ─────────────────────────────────────────────────────────

class _ModuleBreakdownCard extends ConsumerWidget {
  final List<ModuleProgress> progressList;
  final List<ModuleModel> modules;
  final List<String> completedLessonIds;
  const _ModuleBreakdownCard({
    required this.progressList,
    required this.modules,
    required this.completedLessonIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (progressList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16)),
        child: const Row(children: [
          Icon(Icons.hourglass_empty, color: AppColors.textHint, size: 20),
          SizedBox(width: 12),
          Text('No modules started yet.',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ]),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Module Progress',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...progressList.map((p) {
            final mod = modules.cast<ModuleModel?>().firstWhere(
                  (m) => m?.id == p.moduleId,
                  orElse: () => null,
                );
            final color =
                mod != null ? Color(mod.colorValue) : AppColors.accentOrange;
            final lessonsAsync =
                ref.watch(lessonsProvider(p.moduleId));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(7)),
                    child: Icon(_iconFromKey(mod?.iconKey ?? ''),
                        color: color, size: 15),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(mod?.title ?? p.moduleId,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  Text('${p.percent.toInt()}%',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color)),
                  if (p.isCompleted) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle,
                        color: AppColors.primary, size: 14),
                  ],
                ]),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: p.percent / 100,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                const SizedBox(height: 8),
                // Per-lesson completion status
                lessonsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (lessons) => Column(
                    children: lessons.map((lesson) {
                      final done = completedLessonIds.contains(lesson.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4, left: 38),
                        child: Row(children: [
                          Icon(
                              done
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: done
                                  ? AppColors.primary
                                  : AppColors.textHint,
                              size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(lesson.title,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: done
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary)),
                          ),
                          if (done)
                            Text('${lesson.estimatedMinutes}m',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textHint)),
                        ]),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }

  IconData _iconFromKey(String key) {
    const map = {
      'word': Icons.description_outlined,
      'excel': Icons.grid_on_outlined,
      'email': Icons.email_outlined,
      'safety': Icons.shield_outlined,
    };
    return map[key] ?? Icons.book_outlined;
  }
}
