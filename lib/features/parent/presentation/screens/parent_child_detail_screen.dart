import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/module_model.dart';
import '../../../../core/models/progress_model.dart';
import '../../../../core/models/quiz_result_model.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../../shared/widgets/user_avatar.dart';

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
    final overallProgress = totalLessons == 0 ? 0.0 : doneLessons / totalLessons;

    final screenTimeMap = screenTimeAsync.valueOrNull ?? {};
    final completedIds = completedLessonsAsync.valueOrNull ?? [];

    final passedQuizzes = quizResults.where((r) => r.passed).length;
    final completedModules = progressList.where((p) => p.isCompleted).length;

    // Most recent activity
    final recentActivity = [...progressList]
      ..sort((a, b) => b.lastAccessed.compareTo(a.lastAccessed));
    final lastSeen = recentActivity.isNotEmpty
        ? recentActivity.first.lastAccessed
        : null;

    return Scaffold(
      backgroundColor: context.bgColor,
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
                    child: Icon(Icons.arrow_back_ios_new,
                        size: 20, color: context.textPrimaryColor),
                  ),
                  const Spacer(),
                  Text(child.name.isNotEmpty ? child.name : child.email,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: context.textPrimaryColor)),
                  const Spacer(),
                  const SizedBox(width: 20),
                ]),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Hero card: avatar + stats ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: context.borderColor)),
                  child: Column(children: [
                    Row(children: [
                      UserAvatar(
                        name: child.name.isNotEmpty ? child.name : child.email,
                        avatarUrl: child.avatarUrl,
                        size: 68,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                child.name.isNotEmpty
                                    ? child.name
                                    : child.email,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: context.textPrimaryColor)),
                            const SizedBox(height: 2),
                            Text(child.email,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: context.textSecondaryColor)),
                            if (lastSeen != null) ...[
                              const SizedBox(height: 6),
                              Row(children: [
                                Icon(Icons.access_time,
                                    size: 12,
                                    color: context.textSecondaryColor),
                                const SizedBox(width: 4),
                                Text('Last active ${_timeAgo(lastSeen)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color:
                                                context.textSecondaryColor)),
                              ]),
                            ],
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    // Overall progress bar
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Overall Progress',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: context.textPrimaryColor)),
                          Text('$overallPct%',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary)),
                        ]),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: overallProgress,
                        minHeight: 10,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.12),
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Stats row
                    Row(children: [
                      _StatBox(
                          value: '$doneLessons',
                          label: 'Lessons\nCompleted',
                          color: AppColors.primary),
                      _StatDivider(),
                      _StatBox(
                          value: '$passedQuizzes',
                          label: 'Quizzes\nPassed',
                          color: AppColors.accentBlue),
                      _StatDivider(),
                      _StatBox(
                          value: '$completedModules',
                          label: 'Modules\nFinished',
                          color: AppColors.accentOrange),
                    ]),
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

            // ── Quiz History ────────────────────────────────────────────
            if (quizResults.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _QuizHistoryCard(
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

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'yesterday';
    return '${diff.inDays}d ago';
  }
}

// ─── Stat box ─────────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatBox(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(value,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color)),
        const SizedBox(height: 4),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 10,
                color: context.textSecondaryColor)),
      ]),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 40, color: context.borderColor);
  }
}

// ─── Screen Time Chart ────────────────────────────────────────────────────────

class _ScreenTimeCard extends StatelessWidget {
  final Map<String, int> screenTimeMap;
  const _ScreenTimeCard({required this.screenTimeMap});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      return _DayData(label: _dayLabel(d.weekday), minutes: screenTimeMap[key] ?? 0);
    });

    final maxMin = days.fold<int>(1, (m, d) => d.minutes > m ? d.minutes : m);
    final totalMins = days.fold<int>(0, (s, d) => s + d.minutes);
    final totalHrs = totalMins ~/ 60;
    final remMins = totalMins % 60;
    final todayMins = days.last.minutes;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Weekly Screen Time',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.textPrimaryColor)),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Text(
                totalMins == 0
                    ? 'No activity'
                    : totalHrs > 0
                        ? '${totalHrs}h ${remMins}m total'
                        : '${totalMins}m total',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ),
        ]),
        if (todayMins > 0) ...[
          const SizedBox(height: 6),
          Text('Today: ${todayMins}m',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: context.textSecondaryColor)),
        ],
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
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
                      if (d.minutes > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text('${d.minutes}m',
                              style: TextStyle(
                                  fontSize: 8,
                                  color: isToday
                                      ? AppColors.primary
                                      : context.textSecondaryColor,
                                  fontWeight: FontWeight.w600)),
                        ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: frac.clamp(0.04, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isToday
                                    ? AppColors.primary
                                    : AppColors.primary
                                        .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(d.label,
                          style: TextStyle(
                              fontSize: 10,
                              color: isToday
                                  ? AppColors.primary
                                  : context.textSecondaryColor,
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

// ─── Quiz History Card ────────────────────────────────────────────────────────

class _QuizHistoryCard extends StatelessWidget {
  final List<QuizResultModel> quizResults;
  final List<ModuleModel> modules;
  const _QuizHistoryCard(
      {required this.quizResults, required this.modules});

  @override
  Widget build(BuildContext context) {
    final sorted = [...quizResults]
      ..sort((a, b) => b.attemptedAt.compareTo(a.attemptedAt));
    final passed = quizResults.where((r) => r.passed).length;
    final avgPct = quizResults.isEmpty
        ? 0
        : (quizResults.fold<double>(
                    0, (s, r) => s + r.percent) /
                quizResults.length *
                100)
            .toInt();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Quiz Performance',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.textPrimaryColor)),
          Text('$passed/${quizResults.length} passed · avg $avgPct%',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: context.textSecondaryColor)),
        ]),
        const SizedBox(height: 14),
        ...sorted.take(5).map((r) {
          final mod = modules.cast<ModuleModel?>().firstWhere(
                (m) => m?.id == r.moduleId,
                orElse: () => null,
              );
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    color: (r.passed
                            ? AppColors.primary
                            : AppColors.accentRed)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(
                    r.passed
                        ? Icons.check_circle_outline
                        : Icons.replay_outlined,
                    color:
                        r.passed ? AppColors.primary : AppColors.accentRed,
                    size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(mod?.title ?? r.moduleId,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimaryColor)),
                  Text(
                      '${r.score}/${r.total} · ${(r.percent * 100).toInt()}% · ${_timeAgo(r.attemptedAt)}',
                      style: TextStyle(
                          fontSize: 11,
                          color: context.textSecondaryColor)),
                ]),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'yesterday';
    return '${diff.inDays}d ago';
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.borderColor)),
        child: Row(children: [
          const Icon(Icons.hourglass_empty,
              color: AppColors.textHint, size: 22),
          const SizedBox(width: 12),
          Text('No modules started yet.',
              style: TextStyle(
                  color: context.textSecondaryColor, fontSize: 13)),
        ]),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Module Progress',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.textPrimaryColor)),
            Text(
                '${progressList.where((p) => p.isCompleted).length}/${progressList.length} done',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: context.textSecondaryColor)),
          ]),
          const SizedBox(height: 14),
          ...progressList.map((p) {
            final mod = modules.cast<ModuleModel?>().firstWhere(
                  (m) => m?.id == p.moduleId,
                  orElse: () => null,
                );
            final color =
                mod != null ? Color(mod.colorValue) : AppColors.accentOrange;
            final lessonsAsync = ref.watch(lessonsProvider(p.moduleId));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(_iconFromKey(mod?.iconKey ?? ''),
                        color: color, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(mod?.title ?? p.moduleId,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimaryColor)),
                  ),
                  Text('${(p.percent * 100).toInt()}%',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color)),
                  if (p.isCompleted) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle,
                        color: AppColors.primary, size: 16),
                  ],
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: p.percent,
                    minHeight: 6,
                    backgroundColor:
                        color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                    '${p.completedLessons}/${p.totalLessons} lessons completed',
                    style: TextStyle(
                        fontSize: 11,
                        color: context.textSecondaryColor)),
                const SizedBox(height: 8),
                // Per-lesson status
                lessonsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (lessons) => Column(
                    children: lessons.map((lesson) {
                      final done = completedLessonIds.contains(lesson.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5, left: 42),
                        child: Row(children: [
                          Icon(
                              done
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: done
                                  ? AppColors.primary
                                  : AppColors.textHint,
                              size: 14),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(lesson.title,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: done
                                        ? context.textPrimaryColor
                                        : context.textSecondaryColor)),
                          ),
                          if (done)
                            Text('${lesson.estimatedMinutes}m',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: context.textSecondaryColor)),
                        ]),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: context.borderColor),
                const SizedBox(height: 14),
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
