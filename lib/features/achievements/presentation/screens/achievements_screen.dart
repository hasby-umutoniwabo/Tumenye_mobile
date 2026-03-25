import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static const _badges = [
    _B('Early Bird', Icons.wb_sunny_outlined, AppColors.accentYellow, true),
    _B('Word Master', Icons.description_outlined, AppColors.accentBlue, true),
    _B('7-Day Hero', Icons.local_fire_department, AppColors.accentRed, true),
    _B('Fast Learner', Icons.bolt, AppColors.accentOrange, true),
    _B('Excel Guru', Icons.grid_on, AppColors.primary, false),
    _B('30-Day Pro', Icons.workspace_premium, AppColors.accentPurple, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                color: AppColors.primaryLight,
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
                Text('Jean Bosco',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text('Literacy Level 12',
                    style: Theme.of(context).textTheme.bodySmall),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: AppColors.accentYellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: const Row(children: [
                  Icon(Icons.bolt, size: 14, color: AppColors.accentYellow),
                  SizedBox(width: 4),
                  Text('+1,250 XP',
                      style: TextStyle(
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Module Progress',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: 16)),
            const SizedBox(height: 16),
            const Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Bar('Kinyar.', 0.80),
                  _Bar('MS Word', 0.45),
                  _Bar('MS Excel', 0.20),
                  _Bar('Typing', 0.60),
                ]),
          ]),
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 22)),
        // Streak
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Learning Streak',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.local_fire_department,
                          color: AppColors.accentOrange, size: 26),
                      const SizedBox(width: 8),
                      Text('7 Days',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: AppColors.accentOrange)),
                      const Spacer(),
                      const Text('CURRENT STREAK',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textHint,
                              letterSpacing: 0.5)),
                    ]),
                    const SizedBox(height: 14),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                            7,
                            (i) => _Day(
                                ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                                (14 + i).toString(),
                                true))),
                  ]),
            ),
          ]),
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 22)),
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
                (_, i) => _BadgeTile(b: _badges[i]),
                childCount: _badges.length),
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
                color: AppColors.border,
                borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
                heightFactor: val,
                child: Container(
                    decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8))))),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textSecondary)),
      ]);
}

class _Day extends StatelessWidget {
  final String day, date;
  final bool active;
  const _Day(this.day, this.date, this.active);
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(day,
            style: TextStyle(
                fontSize: 10,
                color: active ? AppColors.primary : AppColors.textHint)),
        const SizedBox(height: 4),
        Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.border,
                shape: BoxShape.circle),
            child: Center(
                child: Text(date,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : AppColors.textHint)))),
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
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: b.earned
                  ? b.color.withValues(alpha: 0.3)
                  : AppColors.border),
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