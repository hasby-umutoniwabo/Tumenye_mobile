import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../../core/models/user_model.dart';

class AdminStudentsScreen extends ConsumerStatefulWidget {
  const AdminStudentsScreen({super.key});
  @override
  ConsumerState<AdminStudentsScreen> createState() =>
      _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends ConsumerState<AdminStudentsScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(allStudentsProvider);

    return SafeArea(
      child: Column(children: [
        // ── Header ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Row(children: [
            const Icon(Icons.people, color: AppColors.accentBlue, size: 24),
            const SizedBox(width: 10),
            Text('Students',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            studentsAsync.when(
              data: (s) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${s.length} total',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentBlue)),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        // ── Search bar ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by name or email…',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.borderColor)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.borderColor)),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (v) => setState(() => _search = v.toLowerCase()),
          ),
        ),
        const SizedBox(height: 12),
        // ── List ─────────────────────────────────────────────────────
        Expanded(
          child: studentsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
                child: Text('Error: $e',
                    style:
                        const TextStyle(color: AppColors.accentRed))),
            data: (students) {
              final filtered = students
                  .where((s) =>
                      s.name.toLowerCase().contains(_search) ||
                      s.email.toLowerCase().contains(_search))
                  .toList()
                ..sort((a, b) => a.name.compareTo(b.name));

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_search,
                          size: 52, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text(
                          _search.isEmpty
                              ? 'No students registered yet.'
                              : 'No students match "$_search".',
                          style: TextStyle(
                              color: context.textSecondaryColor)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 10),
                itemBuilder: (_, i) =>
                    _StudentCard(student: filtered[i]),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _StudentCard extends ConsumerWidget {
  final UserModel student;
  const _StudentCard({required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressList =
        ref.watch(childProgressProvider(student.uid)).value ?? [];
    final total =
        progressList.fold<int>(0, (s, p) => s + p.totalLessons);
    final done =
        progressList.fold<int>(0, (s, p) => s + p.completedLessons);
    final pct = total == 0 ? 0 : (done / total * 100).toInt();
    final completed =
        progressList.where((p) => p.isCompleted).length;

    return GestureDetector(
      onTap: () => context.push(
          '/admin/students/${student.uid}',
          extra: student),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          // Avatar
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
                color: AppColors.accentBlue, shape: BoxShape.circle),
            child: Center(
              child: Text(
                student.name.isNotEmpty
                    ? student.name[0].toUpperCase()
                    : student.email[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(
                  student.name.isNotEmpty ? student.name : student.email,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(student.email,
                  style: TextStyle(
                      fontSize: 12, color: context.textSecondaryColor)),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      minHeight: 5,
                      backgroundColor: context.borderColor,
                      valueColor: const AlwaysStoppedAnimation(
                          AppColors.accentBlue),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('$pct%',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentBlue)),
              ]),
            ]),
          ),
          const SizedBox(width: 10),
          // Modules done badge
          Column(children: [
            Text('$completed',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
            Text('modules',
                style: TextStyle(
                    fontSize: 10, color: context.textSecondaryColor)),
          ]),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right,
              color: AppColors.textHint, size: 20),
        ]),
      ),
    );
  }
}
