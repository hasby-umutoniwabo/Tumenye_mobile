import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../../core/providers/preferences_providers.dart';
import '../../../../core/models/quiz_result_model.dart';
import '../../../../core/models/progress_model.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});
  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _filter = 0;
  static const _filters = ['All', 'Achievements', 'Reminders'];

  @override
  Widget build(BuildContext context) {
    final quizResults = ref.watch(userQuizResultsProvider).value ?? [];
    final progressList = ref.watch(allProgressProvider).value ?? [];
    final remindersEnabled = ref.watch(remindersProvider);
    final todayMins = ref.watch(todayScreenTimeProvider).value ?? 0;

    final items = _buildItems(quizResults, progressList, remindersEnabled, todayMins);
    final filtered = _filtered(items);

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
          child: Column(children: [
        // ── Header ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new, size: 20)),
            const Spacer(),
            Text('My Notifications',
                style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            const SizedBox(width: 20),
          ]),
        ),
        const SizedBox(height: 16),
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
                        color: on ? AppColors.primary : context.surfaceColor,
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
            )),
        const SizedBox(height: 14),
        // ── Notifications list ───────────────────────────────────────
        Expanded(
          child: filtered.isEmpty
              ? _EmptyState(filter: _filters[_filter])
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => _NotifRow(n: filtered[i]),
                ),
        ),
      ])),
    );
  }

  List<_NotifItem> _buildItems(List<QuizResultModel> results,
      List<ModuleProgress> progress, bool remindersEnabled, int todayMins) {
    final items = <_NotifItem>[];

    // Quiz results → achievement notifications
    for (final r in results) {
      if (r.passed) {
        items.add(_NotifItem(
          icon: Icons.check_circle_outline,
          color: AppColors.primary,
          title: 'Quiz Passed',
          body:
              'You passed the ${_moduleTitle(r.moduleId)} quiz with ${r.score}/${r.total}!',
          time: _timeAgo(r.attemptedAt),
          isNew: DateTime.now().difference(r.attemptedAt).inHours < 24,
          type: 'achievement',
        ));
      } else {
        items.add(_NotifItem(
          icon: Icons.replay_outlined,
          color: AppColors.accentOrange,
          title: 'Quiz Attempt',
          body:
              'You scored ${r.score}/${r.total} on ${_moduleTitle(r.moduleId)} quiz. Try again!',
          time: _timeAgo(r.attemptedAt),
          isNew: DateTime.now().difference(r.attemptedAt).inHours < 24,
          type: 'achievement',
        ));
      }
    }

    // Completed modules → achievement notifications
    for (final p in progress.where((p) => p.isCompleted)) {
      items.add(_NotifItem(
        icon: Icons.emoji_events,
        color: AppColors.accentYellow,
        title: 'Module Completed!',
        body:
            "You completed the ${_moduleTitle(p.moduleId)} module. Great work!",
        time: _timeAgo(p.lastAccessed),
        isNew: DateTime.now().difference(p.lastAccessed).inHours < 48,
        type: 'achievement',
      ));
    }

    // Reminders — only shown when the user has enabled them in settings
    if (remindersEnabled) {
      const goalMinutes = 30;
      final goalMet = todayMins >= goalMinutes;
      final reminderBody = goalMet
          ? "You've hit your daily goal! Keep the momentum going tomorrow."
          : todayMins > 0
              ? "You've done $todayMins min today — only ${goalMinutes - todayMins} more to reach your goal!"
              : "You haven't studied yet today. A short lesson makes a big difference!";

      items.addAll([
        _NotifItem(
          icon: Icons.alarm,
          color: AppColors.primary,
          title: 'Daily Reminder',
          body: reminderBody,
          time: 'Today',
          isNew: !goalMet,
          type: 'reminder',
        ),
        _NotifItem(
          icon: Icons.shield_outlined,
          color: AppColors.accentRed,
          title: 'Safety Tip',
          body: 'Never share your password with anyone, even friends!',
          time: 'This week',
          isNew: false,
          type: 'reminder',
        ),
      ]);
    }

    // Sort: newest unread first
    items.sort((a, b) {
      if (a.isNew && !b.isNew) return -1;
      if (!a.isNew && b.isNew) return 1;
      return 0;
    });

    return items;
  }

  List<_NotifItem> _filtered(List<_NotifItem> all) {
    if (_filter == 0) return all;
    if (_filter == 1) return all.where((n) => n.type == 'achievement').toList();
    return all.where((n) => n.type == 'reminder').toList();
  }

  String _moduleTitle(String id) {
    switch (id) {
      case 'word':
        return 'MS Word';
      case 'excel':
        return 'MS Excel';
      case 'email':
        return 'Email';
      case 'safety':
        return 'Internet Safety';
      default:
        return id;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}

class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.notifications_none,
            size: 56, color: AppColors.textHint),
        const SizedBox(height: 12),
        Text('No $filter notifications yet',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.textSecondaryColor)),
        const SizedBox(height: 6),
        const Text('Complete lessons and quizzes to earn achievements!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textHint)),
      ]),
    );
  }
}

class _NotifRow extends StatelessWidget {
  final _NotifItem n;
  const _NotifRow({required this.n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: n.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(n.icon, color: n.color, size: 22)),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(n.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.textPrimaryColor)),
                    Text(n.time,
                        style: Theme.of(context).textTheme.bodySmall),
                  ]),
              const SizedBox(height: 3),
              Text(n.body,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: context.textSecondaryColor)),
            ])),
        if (n.isNew)
          Container(
              margin: const EdgeInsets.only(left: 8, top: 5),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle)),
      ]),
    );
  }
}

class _NotifItem {
  final IconData icon;
  final Color color;
  final String title, body, time, type;
  final bool isNew;
  const _NotifItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    required this.isNew,
    required this.type,
  });
}
