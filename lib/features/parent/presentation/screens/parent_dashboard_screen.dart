import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/models/module_model.dart';
import '../../../../core/models/progress_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../shared/widgets/user_avatar.dart';
import 'parent_child_detail_screen.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final parentName = user?.displayName?.split(' ').first ??
        user?.email?.split('@').first ??
        'Parent';

    final childrenAsync = ref.watch(linkedChildrenProvider);
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Mwaramutse'
        : now.hour < 17
            ? 'Mwiriwe'
            : 'Muraho';

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                        color: AppColors.accentOrange, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        parentName[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$greeting, $parentName 👋',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700,
                                    color: context.textPrimaryColor)),
                        Text(_formatDate(now),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: context.textSecondaryColor)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.logout,
                        size: 22, color: context.textSecondaryColor),
                    tooltip: 'Sign out',
                    onPressed: () => _confirmSignOut(context, ref),
                  ),
                ]),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Summary banner (when children are linked) ────────────────
            childrenAsync.when(
              loading: () =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, __) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              data: (children) {
                if (children.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Consumer(builder: (_, ref, __) {
                      final allProgress = children
                          .expand((c) =>
                              ref
                                  .watch(childProgressProvider(c.uid))
                                  .value ??
                              const <ModuleProgress>[])
                          .toList();
                      final totalLessons = allProgress.fold<int>(
                          0, (s, p) => s + p.totalLessons);
                      final doneLessons = allProgress.fold<int>(
                          0, (s, p) => s + p.completedLessons);
                      final pct = totalLessons == 0
                          ? 0
                          : (doneLessons / totalLessons * 100).toInt();
                      final completedModules =
                          allProgress.where((p) => p.isCompleted).length;

                      return Row(children: [
                        _SummaryTile(
                          icon: Icons.people_outline,
                          value: '${children.length}',
                          label: children.length == 1
                              ? 'Child Linked'
                              : 'Children Linked',
                          color: AppColors.accentOrange,
                        ),
                        const SizedBox(width: 12),
                        _SummaryTile(
                          icon: Icons.trending_up,
                          value: '$pct%',
                          label: 'Avg Progress',
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        _SummaryTile(
                          icon: Icons.emoji_events_outlined,
                          value: '$completedModules',
                          label: completedModules == 1
                              ? 'Module Done'
                              : 'Modules Done',
                          color: AppColors.accentYellow,
                        ),
                      ]);
                    }),
                  ),
                );
              },
            ),

            // ── Section title ────────────────────────────────────────────
            childrenAsync.when(
              loading: () =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, __) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              data: (children) {
                if (children.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Text('Your Children',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: context.textPrimaryColor,
                                fontSize: 15)),
                  ),
                );
              },
            ),

            // ── Children list or empty state ─────────────────────────────
            childrenAsync.when(
              loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator())),
              error: (e, _) => SliverToBoxAdapter(
                  child: _ErrorCard('Failed to load children: $e')),
              data: (children) => children.isEmpty
                  ? const SliverToBoxAdapter(child: _LinkChildCard())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _ChildCard(child: children[i]),
                        childCount: children.length,
                      ),
                    ),
            ),

            // ── Add another child (when already has children) ────────────
            SliverToBoxAdapter(
              child: childrenAsync.value?.isNotEmpty == true
                  ? const Padding(
                      padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
                      child: _AddChildButton(),
                    )
                  : const SizedBox.shrink(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(authServiceProvider).signOut();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentRed),
              child: const Text('Sign Out')),
        ],
      ),
    );
  }
}

// ─── Summary tile ─────────────────────────────────────────────────────────────

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _SummaryTile(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.7))),
        ]),
      ),
    );
  }
}

// ─── Child card (dashboard view) ─────────────────────────────────────────────

class _ChildCard extends ConsumerWidget {
  final UserModel child;
  const _ChildCard({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressList =
        ref.watch(childProgressProvider(child.uid)).value ?? [];
    final quizResults =
        ref.watch(childQuizResultsProvider(child.uid)).value ?? [];
    final modules = ref.watch(modulesProvider).value ?? [];

    // Overall progress — use all modules total lessons
    final totalLessons =
        progressList.fold<int>(0, (s, p) => s + p.totalLessons);
    final doneLessons =
        progressList.fold<int>(0, (s, p) => s + p.completedLessons);
    final overallPct =
        totalLessons == 0 ? 0 : (doneLessons / totalLessons * 100).toInt();
    final passedQuizzes = quizResults.where((r) => r.passed).length;

    // Most recently accessed module
    final recent = [...progressList]
      ..sort((a, b) => b.lastAccessed.compareTo(a.lastAccessed));
    final currentModule = recent.isNotEmpty ? recent.first : null;
    final currentModuleData = modules.cast<ModuleModel?>().firstWhere(
          (m) => m?.id == currentModule?.moduleId,
          orElse: () => null,
        );

    // Last active text
    final lastActive = currentModule != null
        ? _timeAgo(currentModule.lastAccessed)
        : null;

    // Recent quiz (for activity snippet)
    final recentQuiz = quizResults.isNotEmpty
        ? (List.of(quizResults)
          ..sort((a, b) => b.attemptedAt.compareTo(a.attemptedAt)))
            .first
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ParentChildDetailScreen(child: child),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.borderColor)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: avatar + name + progress badge ──────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  UserAvatar(
                    name: child.name.isNotEmpty ? child.name : child.email,
                    avatarUrl: child.avatarUrl,
                    size: 54,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            child.name.isNotEmpty
                                ? child.name
                                : child.email,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: context.textPrimaryColor)),
                        const SizedBox(height: 3),
                        Row(children: [
                          Icon(Icons.circle,
                              size: 7,
                              color: lastActive != null
                                  ? AppColors.primary
                                  : AppColors.textHint),
                          const SizedBox(width: 5),
                          Text(
                              lastActive != null
                                  ? 'Last active $lastActive'
                                  : 'No activity yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: context.textSecondaryColor)),
                        ]),
                      ],
                    ),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: _progressColor(overallPct)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('$overallPct%',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _progressColor(overallPct))),
                    ),
                    const SizedBox(height: 4),
                    Text('overall',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: context.textSecondaryColor)),
                  ]),
                ]),
              ),

              // ── Divider ──────────────────────────────────────────────
              Divider(height: 1, color: context.borderColor),

              // ── Stats row ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(children: [
                  _MiniStat(
                      icon: Icons.check_circle_outline,
                      value: '$doneLessons',
                      label: 'Lessons',
                      color: AppColors.primary),
                  _VertDivider(),
                  _MiniStat(
                      icon: Icons.quiz_outlined,
                      value: '$passedQuizzes',
                      label: 'Quizzes\nPassed',
                      color: AppColors.accentBlue),
                  _VertDivider(),
                  _MiniStat(
                      icon: Icons.emoji_events_outlined,
                      value:
                          '${progressList.where((p) => p.isCompleted).length}',
                      label: 'Modules\nDone',
                      color: AppColors.accentOrange),
                ]),
              ),

              // ── Current module progress ──────────────────────────────
              if (currentModule != null) ...[
                Divider(height: 1, color: context.borderColor),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            if (currentModuleData != null) ...[
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                    color: Color(currentModuleData.colorValue)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6)),
                                child: Icon(
                                    _iconFromKey(currentModuleData.iconKey),
                                    color:
                                        Color(currentModuleData.colorValue),
                                    size: 13),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              currentModuleData?.title ??
                                  currentModule.moduleId,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: context.textPrimaryColor),
                            ),
                          ]),
                          Text(
                              '${(currentModule.percent * 100).toInt()}% · ${currentModule.completedLessons}/${currentModule.totalLessons} lessons',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: context.textSecondaryColor)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: currentModule.percent,
                          minHeight: 6,
                          backgroundColor: context.borderColor,
                          valueColor: AlwaysStoppedAnimation(
                              currentModuleData != null
                                  ? Color(currentModuleData.colorValue)
                                  : AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ── Recent activity snippet ──────────────────────────────
              if (recentQuiz != null) ...[
                Divider(height: 1, color: context.borderColor),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Row(children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: (recentQuiz.passed
                                  ? AppColors.primary
                                  : AppColors.accentOrange)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(
                          recentQuiz.passed
                              ? Icons.check_circle_outline
                              : Icons.replay_outlined,
                          size: 16,
                          color: recentQuiz.passed
                              ? AppColors.primary
                              : AppColors.accentOrange),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                          recentQuiz.passed
                              ? 'Passed quiz with ${recentQuiz.score}/${recentQuiz.total}'
                              : 'Scored ${recentQuiz.score}/${recentQuiz.total} on quiz',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: context.textSecondaryColor)),
                    ),
                    Text(_timeAgo(recentQuiz.attemptedAt),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: context.textSecondaryColor)),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right,
                        size: 18, color: context.textSecondaryColor),
                  ]),
                ),
              ] else ...[
                Divider(height: 1, color: context.borderColor),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Row(children: [
                    const Icon(Icons.chevron_right,
                        size: 18, color: AppColors.textHint),
                    const SizedBox(width: 6),
                    Text('Tap to view full report',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: context.textSecondaryColor)),
                  ]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _progressColor(int pct) {
    if (pct >= 80) return AppColors.primary;
    if (pct >= 40) return AppColors.accentOrange;
    return AppColors.accentRed;
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'yesterday';
    return '${diff.inDays}d ago';
  }

  IconData _iconFromKey(String key) {
    const map = {
      'word': Icons.description_outlined,
      'excel': Icons.grid_on_outlined,
      'email': Icons.email_outlined,
      'safety': Icons.shield_outlined,
    };
    return map[key] ?? Icons.book_outlined;
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _MiniStat(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color)),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 10,
                color: context.textSecondaryColor)),
      ]),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 36, color: context.borderColor);
  }
}

// ─── Link Child Card (empty state) ────────────────────────────────────────────

class _LinkChildCard extends ConsumerStatefulWidget {
  const _LinkChildCard();

  @override
  ConsumerState<_LinkChildCard> createState() => _LinkChildCardState();
}

class _LinkChildCardState extends ConsumerState<_LinkChildCard> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _link() async {
    final email = _ctrl.text.trim();
    if (email.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final err = await FirestoreService().linkChildByEmail(uid, email);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = err;
    });
    if (err == null) _ctrl.clear();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.borderColor)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    color: AppColors.accentOrange.withValues(alpha: 0.12),
                    shape: BoxShape.circle),
                child: const Icon(Icons.child_care,
                    color: AppColors.accentOrange, size: 32),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text('Link Your Child\'s Account',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.textPrimaryColor)),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                  "Enter your child's Tumenye account email to start monitoring their learning progress.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: context.textSecondaryColor)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Child's email address",
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                errorText: _error,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _link,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.link, size: 18),
                label: Text(_loading ? 'Linking…' : 'Link Child Account'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 50)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Another Child Button ─────────────────────────────────────────────────

class _AddChildButton extends ConsumerStatefulWidget {
  const _AddChildButton();
  @override
  ConsumerState<_AddChildButton> createState() => _AddChildButtonState();
}

class _AddChildButtonState extends ConsumerState<_AddChildButton> {
  bool _expanded = false;
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _link() async {
    final email = _ctrl.text.trim();
    if (email.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final err = await FirestoreService().linkChildByEmail(uid, email);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = err;
      if (err == null) _expanded = false;
    });
    if (err == null) _ctrl.clear();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_expanded) {
      return TextButton.icon(
        onPressed: () => setState(() => _expanded = true),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Link another child'),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor)),
      child: Column(children: [
        TextField(
          controller: _ctrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: "Child's email address",
            prefixIcon: const Icon(Icons.email_outlined, size: 20),
            errorText: _error,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _loading ? null : _link,
              style:
                  ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
              child: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Link'),
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
              onPressed: () => setState(() => _expanded = false),
              child: const Text('Cancel')),
        ]),
      ]),
    );
  }
}

// ─── Error card ───────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard(this.message);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(message,
            style: const TextStyle(color: AppColors.accentRed)),
      );
}
