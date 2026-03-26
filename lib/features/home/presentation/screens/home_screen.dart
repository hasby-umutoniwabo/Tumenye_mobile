import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/models/progress_model.dart';
import '../../../../core/providers/firestore_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final progressList = ref.watch(allProgressProvider).value ?? [];

    final totalLessons =
        progressList.fold<int>(0, (s, p) => s + p.totalLessons);
    final doneLessons =
        progressList.fold<int>(0, (s, p) => s + p.completedLessons);
    final overallPct =
        totalLessons == 0 ? 0 : (doneLessons / totalLessons * 100).toInt();

    // Find module in progress (started but not complete)
    final inProgress = progressList
        .where((p) => p.completedLessons > 0 && !p.isCompleted)
        .toList()
      ..sort((a, b) =>
          b.lastAccessed.compareTo(a.lastAccessed));
    final currentProgress = inProgress.isNotEmpty ? inProgress.first : null;

    final displayName = user?.displayName?.split(' ').first ??
        user?.email?.split('@').first ??
        'Muraho';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(
              child: _TopBar(name: displayName, streak: overallPct)),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
              child: _CurrentModuleCard(progress: currentProgress)),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(child: _DailyGoalCard()),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(child: _QuickAccess()),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(child: _LatestBadge()),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(child: _NextTopic()),
          const SliverToBoxAdapter(child: SizedBox(height: 36)),
        ]),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String name;
  final int streak;
  const _TopBar({required this.name, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(children: [
        Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
                color: AppColors.accentOrange, shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.white, size: 24)),
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
            child: const Icon(Icons.notifications_outlined, size: 24)),
      ]),
    );
  }
}

class _CurrentModuleCard extends StatelessWidget {
  final ModuleProgress? progress;
  const _CurrentModuleCard({this.progress});

  @override
  Widget build(BuildContext context) {
    final pct = progress == null ? 0 : progress!.percent.toInt();
    final progressVal = progress?.percent ?? 0.0;
    final moduleLabel = progress?.moduleId.toUpperCase() ?? 'MODULES';

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
                  value: progressVal / 100,
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

class _DailyGoalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(
                  value: 20 / 30,
                  strokeWidth: 5,
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.2),
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.primary)),
              const Text('20/30',
                  style: TextStyle(
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
                      const Text('Almost there! 🎉',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)),
                    ]),
                const SizedBox(height: 3),
                Text('30 minutes of reading',
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
          _QBtn(Icons.sports_esports_outlined, 'Games',
              AppColors.accentPurple, () {}),
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
              color: AppColors.surface,
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

class _NextTopic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.lesson),
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
                  const Text('Introduction to Consonants',
                      style: TextStyle(
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