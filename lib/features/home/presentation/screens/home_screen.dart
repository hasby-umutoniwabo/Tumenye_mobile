import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/models/lesson_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../../core/providers/preferences_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final progressList = ref.watch(allProgressProvider).value ?? [];
    final modulesList = ref.watch(modulesProvider).value ?? [];
    final quizResults = ref.watch(userQuizResultsProvider).value ?? [];

    // Total lessons from ALL modules (not just ones with progress docs)
    final totalLessons = modulesList.isNotEmpty
        ? modulesList.fold<int>(0, (s, m) => s + m.totalLessons)
        : progressList.fold<int>(0, (s, p) => s + p.totalLessons);
    final doneLessons =
        progressList.fold<int>(0, (s, p) => s + p.completedLessons);
    final overallPct =
        totalLessons == 0 ? 0 : (doneLessons / totalLessons * 100).toInt();

    // Find module in progress (started but not complete)
    final inProgress = progressList
        .where((p) => p.completedLessons > 0 && !p.isCompleted)
        .toList()
      ..sort((a, b) => b.lastAccessed.compareTo(a.lastAccessed));
    final currentProgress = inProgress.isNotEmpty ? inProgress.first : null;

    // Determine next module and lesson index
    final completedIds =
        progressList.where((p) => p.isCompleted).map((p) => p.moduleId).toSet();
    final sortedModules = [...modulesList]
      ..sort((a, b) => a.order.compareTo(b.order));
    final String nextModuleId;
    final int nextLessonIndex;
    if (currentProgress != null) {
      nextModuleId = currentProgress.moduleId;
      nextLessonIndex = currentProgress.completedLessons;
    } else {
      final nextModule = sortedModules
          .where((m) => !completedIds.contains(m.id))
          .toList();
      nextModuleId = nextModule.isNotEmpty
          ? nextModule.first.id
          : (sortedModules.isNotEmpty ? sortedModules.first.id : 'word');
      nextLessonIndex = 0;
    }

    // Current module card values
    final String currentCardTitle;
    final double currentCardProgress;
    final bool currentCardIsNew;
    if (currentProgress != null) {
      final mod = sortedModules.where((m) => m.id == currentProgress.moduleId).toList();
      currentCardTitle = mod.isNotEmpty ? mod.first.title : currentProgress.moduleId.toUpperCase();
      currentCardProgress = currentProgress.percent;
      currentCardIsNew = false;
    } else {
      final nextMod = sortedModules.where((m) => m.id == nextModuleId).toList();
      currentCardTitle = nextMod.isNotEmpty ? nextMod.first.title : nextModuleId.toUpperCase();
      currentCardProgress = 0.0;
      currentCardIsNew = completedIds.length < sortedModules.length;
    }

    // Notification badge count — items newer than the last time user opened notifications
    final lastSeen = ref.watch(notifLastSeenProvider);
    final notifCount =
        quizResults.where((r) => r.attemptedAt.isAfter(lastSeen)).length +
        progressList.where((p) => p.isCompleted && p.lastAccessed.isAfter(lastSeen)).length;

    final displayName = user?.displayName?.split(' ').first ??
        user?.email?.split('@').first ??
        'Muraho';

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(
              child: _TopBar(name: displayName, streak: overallPct, notifCount: notifCount)),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
              child: _CurrentModuleCard(
                  title: currentCardTitle,
                  progressValue: currentCardProgress,
                  isNew: currentCardIsNew)),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(child: _DailyGoalCard()),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(child: _QuickAccess()),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(child: _LatestBadge()),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
              child: _NextTopic(moduleId: nextModuleId, completedLessons: nextLessonIndex)),
          const SliverToBoxAdapter(child: SizedBox(height: 36)),
        ]),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  final String name;
  final int streak;
  final int notifCount;
  const _TopBar({required this.name, required this.streak, required this.notifCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarUrl = ref.watch(currentUserStreamProvider).valueOrNull?.avatarUrl;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(children: [
        Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
                color: AppColors.accentOrange, shape: BoxShape.circle),
            child: ClipOval(
              child: avatarUrl != null
                  ? CachedNetworkImage(
                      imageUrl: avatarUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const Icon(
                          Icons.person, color: Colors.white, size: 24),
                    )
                  : const Icon(Icons.person, color: Colors.white, size: 24),
            )),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text('Muraho, $name! 👋',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              Text('Ready to learn?',
                  style: Theme.of(context).textTheme.bodySmall),
            ])),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: AppColors.accentYellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            const Icon(Icons.bolt, size: 14, color: AppColors.accentYellow),
            const SizedBox(width: 2),
            Text('$streak%',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentYellow)),
          ]),
        ),
        const SizedBox(width: 10),
        GestureDetector(
            onTap: () => context.push(AppRoutes.notifications),
            child: Badge(
              isLabelVisible: notifCount > 0,
              label: Text('$notifCount'),
              child: const Icon(Icons.notifications_outlined, size: 24),
            )),
      ]),
    );
  }
}

class _CurrentModuleCard extends StatelessWidget {
  final String title;
  final double progressValue;
  final bool isNew;
  const _CurrentModuleCard({
    required this.title,
    required this.progressValue,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progressValue * 100).toInt();
    final progressVal = progressValue;
    final moduleLabel = title.toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: AppColors.darkBg,
            borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('CURRENT MODULE',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTextSecondary,
                  letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Text(moduleLabel,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.white)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                  value: progressVal,
                  minHeight: 7,
                  backgroundColor: AppColors.darkBorder,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.primary)),
            )),
            const SizedBox(width: 12),
            Text('$pct%',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.modules),
              icon: const Text('Continue'),
              label: const Icon(Icons.arrow_forward, size: 16),
              style:
                  ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _DailyGoalCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalMinutes = ref.watch(dailyGoalProvider);
    final todayMins = ref.watch(todayScreenTimeProvider).value ?? 0;
    final done = todayMins.clamp(0, goalMinutes);
    final progress = done / goalMinutes;
    final remaining = goalMinutes - done;
    final statusText = done >= goalMinutes
        ? 'Goal reached! 🎉'
        : remaining <= 5
            ? 'Almost there! 🔥'
            : '$remaining min left';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: context.primaryLightColor,
            borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          done >= goalMinutes
              ? Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 26))
              : SizedBox(
                  width: 52,
                  height: 52,
                  child: Stack(alignment: Alignment.center, children: [
                    CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 5,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.2),
                        valueColor:
                            const AlwaysStoppedAnimation(AppColors.primary)),
                    Text('$done/$goalMinutes',
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ]),
                ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Daily Goal',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text(statusText,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)),
                    ]),
                const SizedBox(height: 3),
                Text('$goalMinutes minutes of learning',
                    style: Theme.of(context).textTheme.bodySmall),
              ])),
        ]),
      ),
    );
  }
}

class _QuickAccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Quick Access',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontSize: 16)),
        const SizedBox(height: 12),
        Row(children: [
          _QBtn(Icons.library_books_outlined, 'Library',
              AppColors.accentBlue, () => context.go(AppRoutes.modules)),
          const SizedBox(width: 12),
          _QBtn(Icons.emoji_events_outlined, 'Achievements',
              AppColors.accentOrange, () => context.push(AppRoutes.achievements)),
          const SizedBox(width: 12),
          _QBtn(Icons.history_outlined, 'Quiz History',
              AppColors.accentPurple, () => context.push(AppRoutes.quizHistory)),
        ]),
      ]),
    );
  }
}

class _QBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QBtn(this.icon, this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ]),
          ),
        ),
      );
}

class _LatestBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Latest Badge',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontSize: 16)),
          GestureDetector(
              onTap: () => context.push(AppRoutes.achievements),
              child: const Text('View all',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary))),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color:
                        AppColors.accentYellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.emoji_events,
                    color: AppColors.accentYellow, size: 26)),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Early Bird',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('Completed 3 lessons before 8 AM',
                      style: Theme.of(context).textTheme.bodySmall),
                ])),
          ]),
        ),
      ]),
    );
  }
}

class _NextTopic extends ConsumerWidget {
  final String moduleId;
  final int completedLessons;
  const _NextTopic({required this.moduleId, required this.completedLessons});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsProvider(moduleId));

    return lessonsAsync.when(
      loading: () => _card(context, null),
      error: (_, __) => _card(context, null),
      data: (lessons) {
        final sorted = [...lessons]..sort((a, b) => a.order.compareTo(b.order));
        final nextLesson = completedLessons < sorted.length
            ? sorted[completedLessons]
            : sorted.isNotEmpty
                ? sorted.last
                : null;
        return _card(context, nextLesson);
      },

    );
  }

  Widget _card(BuildContext context, LessonModel? lesson) {
    final title = lesson?.title ?? 'Start Learning';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.lesson, extra: moduleId),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('NEXT TOPIC',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.75),
                          letterSpacing: 1.2)),
                  const SizedBox(height: 5),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ])),
            Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle),
                child: const Icon(Icons.arrow_forward,
                    color: Colors.white, size: 18)),
          ]),
        ),
      ),
    );
  }
}
