import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/app_constants.dart';

class ModulesScreen extends StatelessWidget {
  const ModulesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: _Header()),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Select a Module', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('Tap on a card below to start your lesson.',
                    style: Theme.of(context).textTheme.bodyMedium),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                  (_, i) => _ModuleCard(module: sampleModules[i]),
                  childCount: sampleModules.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 12,
                  crossAxisSpacing: 12, childAspectRatio: 0.88),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Recent Activity',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16)),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(child: _RecentActivity()),
          const SliverToBoxAdapter(child: SizedBox(height: 36)),
        ]),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(onTap: () => context.go(AppRoutes.home),
              child: const Icon(Icons.arrow_back_ios_new, size: 20)),
          const Spacer(),
          Text('Learning Modules', style: Theme.of(context).textTheme.headlineSmall),
          const Spacer(),
          const SizedBox(width: 20),
        ]),
        const SizedBox(height: 20),
        Text('Mwaramutse! 🌟', style: Theme.of(context).textTheme.headlineMedium),
        Text('Your learning journey', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(value: 0.45, minHeight: 10,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(AppColors.primary)),
          )),
          const SizedBox(width: 12),
          const Text('45%', style: TextStyle(fontSize: 17,
              fontWeight: FontWeight.w800, color: AppColors.primary)),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8)),
          child: const Text('🔥  KEEP UP THE GREAT WORK',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: AppColors.primary, letterSpacing: 0.4)),
        ),
      ]),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final ModuleData module;
  const _ModuleCard({required this.module});

  IconData _icon() {
    switch (module.iconKey) {
      case 'word': return Icons.description_outlined;
      case 'excel': return Icons.grid_on_outlined;
      case 'email': return Icons.email_outlined;
      case 'safety': return Icons.shield_outlined;
      default: return Icons.book_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(module.colorValue);
    final locked = module.isLocked;
    return GestureDetector(
      onTap: () => locked
          ? ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Complete earlier modules to unlock!'),
              backgroundColor: AppColors.accentRed))
          : context.push(AppRoutes.lesson),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: locked ? AppColors.surface : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: locked ? AppColors.border : color.withOpacity(0.22))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(width: 46, height: 46,
              decoration: BoxDecoration(
                  color: locked ? AppColors.border : color.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(_icon(), color: locked ? AppColors.textHint : color, size: 22)),
            if (!locked && module.progress > 0)
              Container(width: 22, height: 22,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 13, color: Colors.white)),
            if (locked) const Icon(Icons.lock_outline, size: 17, color: AppColors.textHint),
          ]),
          const Spacer(),
          Text(module.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: locked ? AppColors.textHint : AppColors.textPrimary)),
          const SizedBox(height: 3),
          Text(module.subtitle, style: TextStyle(fontSize: 12,
              fontWeight: FontWeight.w600,
              color: locked ? AppColors.accentRed : color)),
          const SizedBox(height: 8),
          if (!locked) ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: module.progress, minHeight: 4,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation(color)),
          ),
        ]),
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      ('Keyboard Layouts', 'Microsoft Word • 80% Complete', 0.80, AppColors.accentBlue),
      ('Sum & Averages', 'Microsoft Excel • 20% Complete', 0.20, AppColors.primary),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: items.map((a) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface,
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Container(width: 38, height: 38,
            decoration: BoxDecoration(color: a.$4.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.play_circle_outline, color: a.$4, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.$1, style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text(a.$2, style: Theme.of(context).textTheme.bodySmall),
          ])),
          Text('${(a.$3 * 100).toInt()}%', style: TextStyle(fontSize: 13,
              fontWeight: FontWeight.w700, color: a.$4)),
        ]),
      )).toList()),
    );
  }
}