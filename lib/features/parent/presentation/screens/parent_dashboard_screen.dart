import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../../core/models/module_model.dart';
import '../../../../core/models/progress_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/firestore_service.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                        color: AppColors.accentOrange, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        parentName[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Muraho, $parentName',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary)),
                        Text('Parent Dashboard',
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
                ]),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),

            // ── Summary chips (when children are linked) ─────────────────
            childrenAsync.when(
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              data: (children) {
                if (children.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(children: [
                      _SummaryChip(
                        label: '${children.length}',
                        sub: children.length == 1 ? 'Child' : 'Children',
                        color: AppColors.accentOrange,
                      ),
                      const SizedBox(width: 12),
                      Consumer(builder: (_, ref, __) {
                        final allProgress = children
                            .expand((c) =>
                                ref.watch(childProgressProvider(c.uid)).value ??
                                const <ModuleProgress>[])
                            .toList();
                        final total = allProgress.fold<int>(
                            0, (s, p) => s + p.totalLessons);
                        final done = allProgress.fold<int>(
                            0, (s, p) => s + p.completedLessons);
                        final pct =
                            total == 0 ? 0 : (done / total * 100).toInt();
                        return Expanded(
                          child: _SummaryChip(
                            label: '$pct%',
                            sub: 'Avg Progress',
                            color: AppColors.primary,
                          ),
                        );
                      }),
                    ]),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),

            // ── Children list or empty state ────────────────────────────
            childrenAsync.when(
              loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator())),
              error: (e, _) => SliverToBoxAdapter(
                  child: _ErrorCard('Failed to load children: $e')),
              data: (children) => children.isEmpty
                  ? const SliverToBoxAdapter(child: _LinkChildCard())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _ChildSection(child: children[i]),
                        childCount: children.length,
                      ),
                    ),
            ),

            // ── Add another child (when already has children) ───────────
            SliverToBoxAdapter(
              child: childrenAsync.value?.isNotEmpty == true
                  ? const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
}

// ─── Summary chip ─────────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final String label, sub;
  final Color color;
  const _SummaryChip(
      {required this.label, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        Text(sub,
            style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ]),
    );
  }
}

// ─── Link Child Card (empty state) ───────────────────────────────────────────

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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: AppColors.accentOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.child_care,
                    color: AppColors.accentOrange, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No children linked yet',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text("Enter your child's account email to connect",
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 16),
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
            const SizedBox(height: 12),
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
                style:
                    ElevatedButton.styleFrom(minimumSize: const Size(0, 48)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Another Child Button ────────────────────────────────────────────────

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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16)),
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

// ─── Child Section ───────────────────────────────────────────────────────────

class _ChildSection extends ConsumerWidget {
  final UserModel child;
  const _ChildSection({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressList =
        ref.watch(childProgressProvider(child.uid)).value ?? [];
    final quizResults =
        ref.watch(childQuizResultsProvider(child.uid)).value ?? [];
    final modules = ref.watch(modulesProvider).value ?? [];

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Child header card ──────────────────────────────────────────
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ParentChildDetailScreen(child: child),
            ),
          ),
          child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                  color: AppColors.accentOrange, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  (child.name.isNotEmpty ? child.name : child.email)[0]
                      .toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(child.name.isNotEmpty ? child.name : child.email,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Text(
                      '$overallPct% overall · $passedQuizzes quiz${passedQuizzes == 1 ? '' : 'zes'} passed',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('$overallPct%',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ]),
          ),
        ),

        // ── Current module progress ────────────────────────────────────
        if (currentModule != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      if (currentModuleData != null) ...[
                        Icon(_iconFromKey(currentModuleData.iconKey),
                            color: Color(currentModuleData.colorValue),
                            size: 16),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        'Currently: ${currentModuleData?.title ?? currentModule.moduleId}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ]),
                    Text('${currentModule.percent.toInt()}%',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  child: LinearProgressIndicator(
                    value: currentModule.percent / 100,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(
                        currentModuleData != null
                            ? Color(currentModuleData.colorValue)
                            : AppColors.primary),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                    '${currentModule.completedLessons}/${currentModule.totalLessons} lessons completed',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],

        // ── All modules breakdown ──────────────────────────────────────
        if (progressList.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('All Modules',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...progressList.map((p) {
                  final mod = modules.cast<ModuleModel?>().firstWhere(
                        (m) => m?.id == p.moduleId,
                        orElse: () => null,
                      );
                  final color = mod != null
                      ? Color(mod.colorValue)
                      : AppColors.accentOrange;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      // Module icon
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(7)),
                        child: Icon(_iconFromKey(mod?.iconKey ?? ''),
                            color: color, size: 15),
                      ),
                      const SizedBox(width: 10),
                      // Module name
                      SizedBox(
                        width: 72,
                        child: Text(mod?.title ?? p.moduleId,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      // Progress bar
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: p.percent / 100,
                            minHeight: 6,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Percentage
                      SizedBox(
                        width: 34,
                        child: Text('${p.percent.toInt()}%',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: color),
                            textAlign: TextAlign.right),
                      ),
                      // Completed badge
                      if (p.isCompleted) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.check_circle,
                            color: AppColors.primary, size: 14),
                      ],
                    ]),
                  );
                }),
              ],
            ),
          ),
        ],

        // ── No progress yet ────────────────────────────────────────────
        if (progressList.isEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Icon(Icons.hourglass_empty,
                  color: AppColors.textHint, size: 20),
              const SizedBox(width: 12),
              Text("${child.name.isNotEmpty ? child.name : 'Your child'} hasn't started any lessons yet.",
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ]),
          ),
        ],
      ]),
    );
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
