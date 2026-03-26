import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/models/module_model.dart';
import '../../../../core/models/progress_model.dart';
import '../../../../core/providers/firestore_providers.dart';

class ModulesScreen extends ConsumerWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(modulesProvider);
    final progressList = ref.watch(allProgressProvider).value ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: _Header(progressList: progressList)),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select a Module',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text('Tap on a card below to start your lesson.',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          modulesAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(
                  child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator())),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('Failed to load modules: $e')),
            ),
            data: (modules) => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final mod = modules[i];
                    final progress = progressList
                        .where((p) => p.moduleId == mod.id)
                        .firstOrNull;
                    return _ModuleCard(module: mod, progress: progress);
                  },
                  childCount: modules.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.88),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 36)),
        ]),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final List<ModuleProgress> progressList;
  const _Header({required this.progressList});

  double get _overallProgress {
    if (progressList.isEmpty) return 0.0;
    final total = progressList.fold<int>(0, (s, p) => s + p.totalLessons);
    final done = progressList.fold<int>(0, (s, p) => s + p.completedLessons);
    return total == 0 ? 0.0 : done / total;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (_overallProgress * 100).toInt();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(
              onTap: () => context.go(AppRoutes.home),
              child: const Icon(Icons.arrow_back_ios_new, size: 20)),
          const Spacer(),
          Text('Learning Modules',
              style: Theme.of(context).textTheme.headlineSmall),
          const Spacer(),
          const SizedBox(width: 20),
        ]),
        const SizedBox(height: 20),
        Text('Mwaramutse! 🌟',
            style: Theme.of(context).textTheme.headlineMedium),
        Text('Your learning journey',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
              child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
                value: _overallProgress,
                minHeight: 10,
                backgroundColor: AppColors.border,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.primary)),
          )),
          const SizedBox(width: 12),
          Text('$pct%',
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary)),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8)),
          child: const Text('🔥  KEEP UP THE GREAT WORK',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.4)),
        ),
      ]),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final ModuleModel module;
  final ModuleProgress? progress;
  const _ModuleCard({required this.module, this.progress});

  IconData _icon() {
    switch (module.iconKey) {
      case 'word':
        return Icons.description_outlined;
      case 'excel':
        return Icons.grid_on_outlined;
      case 'email':
        return Icons.email_outlined;
      case 'safety':
        return Icons.shield_outlined;
      default:
        return Icons.book_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(module.colorValue);
    final completed = progress?.completedLessons ?? 0;
    final total = module.totalLessons;
    final progressVal = total == 0 ? 0.0 : completed / total;
    final subtitle = '$completed/$total Lessons';

    return GestureDetector(
      onTap: () => context.push(AppRoutes.lesson, extra: module.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(_icon(), color: color, size: 22)),
                if (progressVal >= 1.0)
                  Container(
                      width: 22,
                      height: 22,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                      child: const Icon(Icons.check,
                          size: 13, color: Colors.white)),
              ]),
          const Spacer(),
          Text(module.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          Text(subtitle,
              style:
                  TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
                value: progressVal,
                minHeight: 4,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color)),
          ),
        ]),
      ),
    );
  }
}
