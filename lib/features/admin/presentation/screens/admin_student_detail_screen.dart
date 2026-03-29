import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../../core/models/module_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../shared/widgets/user_avatar.dart';

class AdminStudentDetailScreen extends ConsumerWidget {
  final String studentUid;
  final UserModel? student;
  const AdminStudentDetailScreen(
      {super.key, required this.studentUid, this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressList =
        ref.watch(childProgressProvider(studentUid)).value ?? [];
    final quizResults =
        ref.watch(childQuizResultsProvider(studentUid)).value ?? [];
    final modules = ref.watch(modulesProvider).value ?? [];

    final totalLessons =
        progressList.fold<int>(0, (s, p) => s + p.totalLessons);
    final doneLessons =
        progressList.fold<int>(0, (s, p) => s + p.completedLessons);
    final overallPct =
        totalLessons == 0 ? 0 : (doneLessons / totalLessons * 100).toInt();
    final passedQuizzes = quizResults.where((r) => r.passed).length;
    final completedModules =
        progressList.where((p) => p.isCompleted).length;

    final name = student?.name.isNotEmpty == true
        ? student!.name
        : student?.email ?? 'Student';
    final email = student?.email ?? '';

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          // ── Header ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, size: 20)),
                const Spacer(),
                Text('Student Profile',
                    style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                const SizedBox(width: 20),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Profile card ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  UserAvatar(
                    name: name,
                    avatarUrl: student?.avatarUrl,
                    size: 72,
                    fallbackColor: AppColors.accentBlue,
                  ),
                  const SizedBox(height: 12),
                  Text(name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall),
                  const SizedBox(height: 4),
                  Text(email,
                      style: TextStyle(
                          fontSize: 13, color: context.textSecondaryColor)),
                  const SizedBox(height: 16),
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatChip('$overallPct%', 'Overall', AppColors.primary),
                      _StatChip('$completedModules', 'Modules Done',
                          AppColors.accentBlue),
                      _StatChip('$passedQuizzes', 'Quizzes Passed',
                          AppColors.accentOrange),
                    ],
                  ),
                ]),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Module progress ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Module Progress',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontSize: 16)),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          if (progressList.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('No lessons started yet.',
                    style: TextStyle(color: context.textSecondaryColor)),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final p = progressList[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(14)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(children: [
                          Icon(_moduleIcon(p.moduleId, modules),
                              color: _moduleColor(p.moduleId, modules), size: 20),
                          const SizedBox(width: 8),
                          Text(_moduleTitle(p.moduleId, modules),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          const Spacer(),
                          if (p.isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20)),
                              child: const Text('Completed',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                            ),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: p.percent,
                                minHeight: 7,
                                backgroundColor: context.borderColor,
                                valueColor: AlwaysStoppedAnimation(
                                    _moduleColor(p.moduleId, modules)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('${(p.percent * 100).toInt()}%',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _moduleColor(p.moduleId, modules))),
                        ]),
                        const SizedBox(height: 4),
                        Text(
                            '${p.completedLessons} of ${p.totalLessons} lessons completed',
                            style: TextStyle(
                                fontSize: 11,
                                color: context.textSecondaryColor)),
                      ]),
                    );
                  },
                  childCount: progressList.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Quiz results ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Quiz Results',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontSize: 16)),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          if (quizResults.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('No quizzes attempted yet.',
                    style: TextStyle(color: context.textSecondaryColor)),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final r = quizResults[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
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
                            size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(r.quizId,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            Text(_moduleTitle(r.moduleId, modules),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: context.textSecondaryColor)),
                          ]),
                        ),
                        Text('${r.score}/${r.total}',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: r.passed
                                    ? AppColors.primary
                                    : AppColors.accentRed)),
                        const SizedBox(width: 6),
                        Text('${(r.percent * 100).toInt()}%',
                            style: TextStyle(
                                fontSize: 11,
                                color: context.textSecondaryColor)),
                      ]),
                    );
                  },
                  childCount: quizResults.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ]),
      ),
    );
  }

  String _moduleTitle(String id, List<ModuleModel> modules) {
    for (final m in modules) {
      if (m.id == id) return m.title;
    }
    return id;
  }

  IconData _moduleIcon(String id, List<ModuleModel> modules) {
    String? key;
    for (final m in modules) {
      if (m.id == id) {
        key = m.iconKey;
        break;
      }
    }
    const iconMap = {
      'word': Icons.description_outlined,
      'excel': Icons.grid_on_outlined,
      'email': Icons.email_outlined,
      'safety': Icons.shield_outlined,
    };
    return iconMap[key] ?? Icons.book_outlined;
  }

  Color _moduleColor(String id, List<ModuleModel> modules) {
    for (final m in modules) {
      if (m.id == id) return Color(m.colorValue);
    }
    return AppColors.primary;
  }
}

class _StatChip extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatChip(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: context.textSecondaryColor)),
      ]);
}
