import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../../core/models/activity_model.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final adminName =
        user?.displayName?.split(' ').first ?? user?.email?.split('@').first ?? 'Admin';

    final studentCount = ref.watch(studentCountProvider).value ?? 0;
    final lessonCount = ref.watch(lessonCountProvider).value ?? 0;
    final activityAsync = ref.watch(recentActivityProvider);
    final modules = ref.watch(modulesProvider).value ?? [];

    return SafeArea(
      child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                          color: AppColors.accentPurple,
                          shape: BoxShape.circle),
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Muraho, $adminName',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: AppColors.textSecondary)),
                          Text('Admin Dashboard',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, size: 22),
                      tooltip: 'Sign out',
                      onPressed: () => FirebaseAuth.instance.signOut(),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            // ── Stats ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                        child: _Stat('Total Students', '$studentCount',
                            null, AppColors.accentBlue)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _Stat('Active Lessons', '$lessonCount',
                            null, AppColors.primary)),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            // ── Module Overview ──────────────────────────────────────────
            if (modules.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Learning Modules',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontSize: 16)),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: modules.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                        itemBuilder: (_, i) {
                          final mod = modules[i];
                          final color = Color(mod.colorValue);
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(_moduleIcon(mod.iconKey),
                                    color: color, size: 28),
                                const Spacer(),
                                Text(mod.title,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                Text('${mod.totalLessons} lessons',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            // ── Recent Activity ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Recent Activity',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontSize: 16)),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            activityAsync.when(
              loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator())),
              error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Error loading activity: $e'),
              )),
              data: (activities) => activities.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('No recent activity yet.',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ))
                  : SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _ActivityRow(activity: activities[i]),
                          childCount: activities.length,
                        ),
                      ),
                    ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      );
  }

  IconData _moduleIcon(String key) {
    switch (key) {
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
}

class _ActivityRow extends StatelessWidget {
  final ActivityModel activity;
  const _ActivityRow({required this.activity});

  @override
  Widget build(BuildContext context) {
    final isQuiz = activity.type == 'quiz_passed';
    final icon = isQuiz ? Icons.check_circle_outline : Icons.emoji_events;
    final color = isQuiz ? AppColors.primary : AppColors.accentYellow;
    final label = isQuiz
        ? '${activity.userName} passed ${activity.moduleId} quiz'
            '${activity.score != null ? ' (${activity.score}/${activity.total})' : ''}'
        : '${activity.userName} completed ${activity.moduleId} module';
    final timeAgo = _timeAgo(activity.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text(timeAgo,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays}d ago';
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final String? change;
  final Color color;
  const _Stat(this.label, this.value, this.change, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.white70)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              if (change != null) ...[
                const SizedBox(width: 6),
                Text(change!,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white70)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
