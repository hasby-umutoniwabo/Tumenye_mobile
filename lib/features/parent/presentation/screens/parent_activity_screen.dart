import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/module_model.dart';

class ParentActivityScreen extends ConsumerStatefulWidget {
  const ParentActivityScreen({super.key});

  @override
  ConsumerState<ParentActivityScreen> createState() =>
      _ParentActivityScreenState();
}

class _ParentActivityScreenState
    extends ConsumerState<ParentActivityScreen> {
  int _filter = 0; // 0=All, 1=Lessons, 2=Quizzes
  static const _filters = ['All', 'Lessons', 'Quizzes'];

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(linkedChildrenProvider);
    final modules = ref.watch(modulesProvider).value ?? [];

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(children: [
          // ── Header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(children: [
              Text('Activity Feed',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: context.textPrimaryColor)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.fiber_manual_record,
                      color: AppColors.primary, size: 8),
                  const SizedBox(width: 5),
                  Text('Live',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          // ── Filter chips ─────────────────────────────────────────────
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final on = i == _filter;
                return GestureDetector(
                  onTap: () => setState(() => _filter = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                        color:
                            on ? AppColors.primary : context.surfaceColor,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(_filters[i],
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: on
                                ? Colors.white
                                : context.textSecondaryColor)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // ── Content ──────────────────────────────────────────────────
          Expanded(
            child: childrenAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: TextStyle(
                          color: context.textSecondaryColor))),
              data: (children) {
                if (children.isEmpty) {
                  return _EmptyState(
                      message: 'No children linked yet.',
                      sub: 'Link a child account from the Home tab.');
                }
                return _ActivityList(
                  children: children,
                  modules: modules,
                  filter: _filter,
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Activity list (aggregates all children) ─────────────────────────────────

class _ActivityList extends ConsumerWidget {
  final List<UserModel> children;
  final List<ModuleModel> modules;
  final int filter;
  const _ActivityList(
      {required this.children,
      required this.modules,
      required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = <_ActivityItem>[];

    for (final child in children) {
      final quizResults =
          ref.watch(childQuizResultsProvider(child.uid)).value ?? [];
      final progressList =
          ref.watch(childProgressProvider(child.uid)).value ?? [];

      // Quiz events
      for (final r in quizResults) {
        final mod = modules.cast<ModuleModel?>().firstWhere(
              (m) => m?.id == r.moduleId,
              orElse: () => null,
            );
        items.add(_ActivityItem(
          childName: child.name.isNotEmpty ? child.name : child.email,
          childInitial: (child.name.isNotEmpty ? child.name : child.email)[0]
              .toUpperCase(),
          icon: r.passed ? Icons.check_circle_outline : Icons.replay_outlined,
          color: r.passed ? AppColors.primary : AppColors.accentOrange,
          title: r.passed ? 'Passed a quiz' : 'Attempted a quiz',
          body:
              '${mod?.title ?? r.moduleId} — scored ${r.score}/${r.total} (${(r.percent * 100).toInt()}%)',
          time: r.attemptedAt,
          type: 'quiz',
        ));
      }

      // Completed module events
      for (final p in progressList.where((p) => p.isCompleted)) {
        final mod = modules.cast<ModuleModel?>().firstWhere(
              (m) => m?.id == p.moduleId,
              orElse: () => null,
            );
        items.add(_ActivityItem(
          childName: child.name.isNotEmpty ? child.name : child.email,
          childInitial: (child.name.isNotEmpty ? child.name : child.email)[0]
              .toUpperCase(),
          icon: Icons.emoji_events_outlined,
          color: AppColors.accentYellow,
          title: 'Completed a module!',
          body: '${mod?.title ?? p.moduleId} — all lessons done 🎉',
          time: p.lastAccessed,
          type: 'lesson',
        ));
      }

      // In-progress module events (last accessed)
      for (final p in progressList.where((p) => !p.isCompleted && p.completedLessons > 0)) {
        final mod = modules.cast<ModuleModel?>().firstWhere(
              (m) => m?.id == p.moduleId,
              orElse: () => null,
            );
        items.add(_ActivityItem(
          childName: child.name.isNotEmpty ? child.name : child.email,
          childInitial: (child.name.isNotEmpty ? child.name : child.email)[0]
              .toUpperCase(),
          icon: Icons.play_circle_outline,
          color: mod != null ? Color(mod.colorValue) : AppColors.accentBlue,
          title: 'Studied a lesson',
          body:
              '${mod?.title ?? p.moduleId} — ${p.completedLessons}/${p.totalLessons} lessons done',
          time: p.lastAccessed,
          type: 'lesson',
        ));
      }
    }

    // Sort newest first
    items.sort((a, b) => b.time.compareTo(a.time));

    // Filter
    final filtered = filter == 0
        ? items
        : filter == 2
            ? items.where((i) => i.type == 'quiz').toList()
            : items.where((i) => i.type == 'lesson').toList();

    if (filtered.isEmpty) {
      return _EmptyState(
        message: 'No ${_filters[filter].toLowerCase()} activity yet',
        sub: 'Activity will appear here as your children learn.',
      );
    }

    // Group by date
    final grouped = <String, List<_ActivityItem>>{};
    for (final item in filtered) {
      final key = _dateKey(item.time);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 4),
              child: Text(entry.key,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.textSecondaryColor,
                      letterSpacing: 0.4)),
            ),
            ...entry.value.map((item) => _ActivityRow(item: item)),
            const SizedBox(height: 6),
          ],
        );
      }).toList(),
    );
  }

  String _dateKey(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  static const _filters = ['All', 'Lessons', 'Quizzes'];
}

// ─── Single activity row ──────────────────────────────────────────────────────

class _ActivityRow extends StatelessWidget {
  final _ActivityItem item;
  const _ActivityRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Child avatar
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: AppColors.accentOrange, shape: BoxShape.circle),
          child: Center(
            child: Text(item.childInitial,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 10),
        // Event icon
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(item.icon, color: item.color, size: 18),
        ),
        const SizedBox(width: 10),
        // Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(item.childName,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimaryColor)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(item.title,
                      style: TextStyle(
                          fontSize: 13,
                          color: context.textSecondaryColor)),
                ),
              ]),
              const SizedBox(height: 2),
              Text(item.body,
                  style: TextStyle(
                      fontSize: 12, color: context.textSecondaryColor)),
              const SizedBox(height: 3),
              Text(_timeAgo(item.time),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textHint)),
            ],
          ),
        ),
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

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message, sub;
  const _EmptyState({required this.message, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.bolt_outlined,
            size: 52, color: AppColors.textHint),
        const SizedBox(height: 12),
        Text(message,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.textSecondaryColor)),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(sub,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textHint)),
        ),
      ]),
    );
  }
}

// ─── Data model ──────────────────────────────────────────────────────────────

class _ActivityItem {
  final String childName, childInitial, title, body, type;
  final IconData icon;
  final Color color;
  final DateTime time;
  const _ActivityItem({
    required this.childName,
    required this.childInitial,
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
  });
}
