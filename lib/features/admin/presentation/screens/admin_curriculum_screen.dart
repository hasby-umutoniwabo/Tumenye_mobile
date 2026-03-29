import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../../core/models/module_model.dart';
import '../../../../core/models/lesson_model.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/firestore_service.dart';
import 'admin_add_module_screen.dart';

class AdminCurriculumScreen extends ConsumerStatefulWidget {
  const AdminCurriculumScreen({super.key});
  @override
  ConsumerState<AdminCurriculumScreen> createState() =>
      _AdminCurriculumScreenState();
}

class _AdminCurriculumScreenState
    extends ConsumerState<AdminCurriculumScreen> {
  final Set<String> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final modulesAsync = ref.watch(modulesProvider);
    final lessonCount = ref.watch(lessonCountProvider).value ?? 0;

    return SafeArea(
      child: Stack(children: [
      CustomScrollView(slivers: [
        // ── Header ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(children: [
              const Icon(Icons.menu_book,
                  color: AppColors.primary, size: 24),
              const SizedBox(width: 10),
              Text('Curriculum',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: context.primaryLightColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Text('$lessonCount lessons total',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
              ),
            ]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 18)),

        // ── Modules list ──────────────────────────────────────────────
        modulesAsync.when(
          loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator())),
          error: (e, _) => SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Error: $e',
                style: const TextStyle(color: AppColors.accentRed)),
          )),
          data: (modules) => SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _ModuleCard(
                  module: modules[i],
                  expanded: _expanded.contains(modules[i].id),
                  onToggle: () => setState(() {
                    if (_expanded.contains(modules[i].id)) {
                      _expanded.remove(modules[i].id);
                    } else {
                      _expanded.add(modules[i].id);
                    }
                  }),
                ),
                childCount: modules.length,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ]),
      // ── FAB: Add Module ────────────────────────────────────────────
      Positioned(
        bottom: 16,
        right: 16,
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AdminAddModuleScreen()),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Add Module'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
    ]),
    );
  }
}

class _ModuleCard extends ConsumerWidget {
  final ModuleModel module;
  final bool expanded;
  final VoidCallback onToggle;

  const _ModuleCard({
    required this.module,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(module.colorValue);
    final lessonsAsync = ref.watch(lessonsProvider(module.id));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        // Module header — tap to expand
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(_moduleIcon(module.iconKey), color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(module.title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(module.difficulty,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: color)),
                    ),
                    const SizedBox(width: 8),
                    Text('${module.totalLessons} lessons',
                        style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondaryColor)),
                  ]),
                ]),
              ),
              // Add lesson button
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.primary, size: 20),
                tooltip: 'Add lesson',
                onPressed: () => context.push(
                  AppRoutes.adminAddLesson,
                  extra: {'moduleId': module.id},
                ),
              ),
              // Edit / Delete module
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    size: 18, color: AppColors.textHint),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_outlined, size: 16),
                      SizedBox(width: 8),
                      Text('Edit module'),
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline,
                          size: 16, color: AppColors.accentRed),
                      SizedBox(width: 8),
                      Text('Delete module',
                          style: TextStyle(color: AppColors.accentRed)),
                    ]),
                  ),
                ],
                onSelected: (action) async {
                  if (action == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AdminAddModuleScreen(module: module),
                      ),
                    );
                  } else if (action == 'delete') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogCtx) => AlertDialog(
                        title: const Text('Delete module?'),
                        content: Text(
                            '"${module.title}" and all its lessons will be permanently removed.'),
                        actions: [
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogCtx, false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogCtx, true),
                              style: TextButton.styleFrom(
                                  foregroundColor: AppColors.accentRed),
                              child: const Text('Delete')),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await FirestoreService().deleteModule(module.id);
                    }
                  }
                },
              ),
              Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textHint),
            ]),
          ),
        ),

        // Expanded: lessons list
        if (expanded) ...[
          const Divider(height: 1, indent: 16, endIndent: 16),
          lessonsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Error loading lessons: $e',
                  style: const TextStyle(color: AppColors.accentRed)),
            ),
            data: (lessons) => lessons.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('No lessons yet. Tap + to add one.',
                        style: TextStyle(
                            color: context.textSecondaryColor, fontSize: 13)),
                  )
                : Column(
                    children: lessons
                        .map((lesson) => _LessonRow(
                              lesson: lesson,
                              moduleColor: color,
                            ))
                        .toList(),
                  ),
          ),
        ],
      ]),
    );
  }

  IconData _moduleIcon(String key) {
    const map = {
      'word': Icons.description_outlined,
      'excel': Icons.grid_on_outlined,
      'email': Icons.email_outlined,
      'safety': Icons.shield_outlined,
    };
    return map[key] ?? Icons.book_outlined;
  }
}

class _LessonRow extends ConsumerWidget {
  final LessonModel lesson;
  final Color moduleColor;

  const _LessonRow({required this.lesson, required this.moduleColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pre-fetch the existing quiz so edit mode works
    final existingQuiz = ref.watch(quizProvider(lesson.id)).valueOrNull;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        // Order badge
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
              color: moduleColor.withValues(alpha: 0.1),
              shape: BoxShape.circle),
          child: Center(
            child: Text('${lesson.order}',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: moduleColor)),
          ),
        ),
        const SizedBox(width: 12),
        // Title + duration
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(lesson.title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            Text('~${lesson.estimatedMinutes} min',
                style: TextStyle(
                    fontSize: 11, color: context.textSecondaryColor)),
          ]),
        ),
        // Translation indicator
        if (lesson.translation.isNotEmpty)
          Tooltip(
            message: 'Has Kinyarwanda translation',
            child: Icon(Icons.translate,
                size: 16,
                color: AppColors.primary.withValues(alpha: 0.6)),
          ),
        const SizedBox(width: 4),
        // Quiz button — green if quiz exists, grey if not
        Tooltip(
          message: existingQuiz != null ? 'Edit quiz' : 'Add quiz',
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => context.push(AppRoutes.adminAddQuiz,
                extra: {'lessonId': lesson.id, 'quiz': existingQuiz}),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: existingQuiz != null
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : context.borderColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.quiz_outlined,
                    size: 14,
                    color: existingQuiz != null
                        ? AppColors.primary
                        : AppColors.textHint),
                const SizedBox(width: 3),
                Text(existingQuiz != null ? 'Quiz' : '+ Quiz',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: existingQuiz != null
                            ? AppColors.primary
                            : AppColors.textHint)),
              ]),
            ),
          ),
        ),
        // Edit / Delete popup
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert,
              size: 18, color: AppColors.textHint),
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                Icon(Icons.edit_outlined, size: 16),
                SizedBox(width: 8),
                Text('Edit lesson'),
              ]),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete_outline,
                    size: 16, color: AppColors.accentRed),
                SizedBox(width: 8),
                Text('Delete lesson',
                    style: TextStyle(color: AppColors.accentRed)),
              ]),
            ),
          ],
          onSelected: (action) async {
            switch (action) {
              case 'edit':
                context.push(AppRoutes.adminAddLesson,
                    extra: {'lesson': lesson});
                break;
              case 'delete':
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    title: const Text('Delete lesson?'),
                    content: Text(
                        '"${lesson.title}" will be permanently removed.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(dialogCtx, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(dialogCtx, true),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.accentRed),
                          child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await FirestoreService()
                      .deleteLesson(lesson.id, lesson.moduleId);
                }
                break;
            }
          },
        ),
      ]),
    );
  }
}
