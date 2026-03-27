import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../../core/models/progress_model.dart';
import '../../../../core/models/quiz_result_model.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? user?.email?.split('@').first ?? 'User';
    final progressList = ref.watch(allProgressProvider).value ?? [];
    final quizResults = ref.watch(userQuizResultsProvider).value ?? [];

    final totalLessons = progressList.fold<int>(0, (s, p) => s + p.totalLessons);
    final doneLessons = progressList.fold<int>(0, (s, p) => s + p.completedLessons);
    final xp = doneLessons * 100 + quizResults.where((r) => r.passed).length * 50;

    final badges = _computeBadges(progressList, quizResults);

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
          child: CustomScrollView(slivers: [
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new, size: 20)),
            const Spacer(),
            Text('My Achievements',
                style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            const SizedBox(width: 20),
          ]),
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 18)),
        // XP card
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: context.primaryLightColor,
                borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                      color: AppColors.accentOrange,
                      shape: BoxShape.circle),
                  child: const Icon(Icons.person,
                      color: Colors.white, size: 30)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                Text(displayName,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text('$doneLessons / $totalLessons Lessons Done',
                    style: Theme.of(context).textTheme.bodySmall),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: AppColors.accentYellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  const Icon(Icons.bolt,
                      size: 14, color: AppColors.accentYellow),
                  const SizedBox(width: 4),
                  Text('+$xp XP',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentYellow)),
                ]),
              ),
            ]),
          ),
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 22)),
        // Module progress bars
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Module Progress',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: 16)),
            const SizedBox(height: 16),
            if (progressList.isEmpty)
              Text('Start a module to track your progress.',
                  style: TextStyle(
                      fontSize: 13, color: context.textSecondaryColor))
            else
              Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: progressList
                      .map((p) => _Bar(
                            _moduleLabel(p.moduleId),
                            p.percent / 100,
                          ))
                      .toList()),
          ]),
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 22)),
        // Quiz results summary
        if (quizResults.isNotEmpty) ...[
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Quiz Results',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontSize: 16)),
              const SizedBox(height: 12),
              ...quizResults.take(4).map((r) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Icon(
                          r.passed
                              ? Icons.check_circle
                              : Icons.cancel_outlined,
                          color: r.passed
                              ? AppColors.primary
                              : AppColors.accentRed,
                          size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(
                              '${_moduleLabel(r.moduleId)} — ${r.quizId}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500))),
                      Text('${r.score}/${r.total}',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: r.passed
                                  ? AppColors.primary
                                  : AppColors.accentRed)),
                    ]),
                  )),
            ]),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 22)),
        ],
        // Badges
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Earned Badges',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontSize: 16)),
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
                (_, i) => _BadgeTile(b: badges[i]),
                childCount: badges.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Keep Learning')),
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ])),
    );
  }

  String _moduleLabel(String moduleId) {
    switch (moduleId) {
      case 'word':
        return 'MS Word';
      case 'excel':
        return 'MS Excel';
      case 'email':
        return 'Email';
      case 'safety':
        return 'Safety';
      default:
        return moduleId;
    }
  }

  List<_B> _computeBadges(
      List<ModuleProgress> progress, List<QuizResultModel> results) {
    bool completed(String id) =>
        progress.any((p) => p.moduleId == id && p.isCompleted);
    bool anyPerfect() => results.any((r) => r.score == r.total && r.total > 0);
    bool allDone() =>
        ['word', 'excel', 'email', 'safety'].every(completed);

    return [
      _B('Word Master', Icons.description_outlined, AppColors.accentBlue,
          completed('word')),
      _B('Excel Guru', Icons.grid_on, AppColors.primary, completed('excel')),
      _B('Email Pro', Icons.email_outlined, AppColors.accentOrange,
          completed('email')),
      _B('Safety Hero', Icons.shield_outlined, AppColors.accentPurple,
          completed('safety')),
      _B('Perfect Score', Icons.bolt, AppColors.accentYellow, anyPerfect()),
      _B('All Modules', Icons.workspace_premium, AppColors.accentRed,
          allDone()),
    ];
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double val;
  const _Bar(this.label, this.val);
  @override
  Widget build(BuildContext context) => Column(children: [
        Text('${(val * 100).toInt()}%',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
        const SizedBox(height: 6),
        Container(
            width: 48,
            height: 80,
            decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
                heightFactor: val.clamp(0.0, 1.0),
                child: Container(
                    decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8))))),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                fontSize: 10, color: context.textSecondaryColor)),
      ]);
}

class _BadgeTile extends StatelessWidget {
  final _B b;
  const _BadgeTile({required this.b});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: b.earned
              ? b.color.withValues(alpha: 0.1)
              : context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: b.earned
                  ? b.color.withValues(alpha: 0.3)
                  : context.borderColor),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          b.earned
              ? Icon(b.icon, color: b.color, size: 32)
              : const Icon(Icons.lock_outline,
                  color: AppColors.textHint, size: 28),
          const SizedBox(height: 8),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(b.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: b.earned ? b.color : AppColors.textHint))),
        ]),
      );
}

class _B {
  final String label;
  final IconData icon;
  final Color color;
  final bool earned;
  const _B(this.label, this.icon, this.color, this.earned);
}
