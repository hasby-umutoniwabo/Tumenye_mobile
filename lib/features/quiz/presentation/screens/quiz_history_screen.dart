import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../../core/models/quiz_result_model.dart';

class QuizHistoryScreen extends ConsumerWidget {
  const QuizHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(userQuizResultsProvider);

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        elevation: 0,
        title: Text(
          'Quiz History',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: context.textPrimaryColor),
        ),
        iconTheme: IconThemeData(color: context.textPrimaryColor),
      ),
      body: resultsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Could not load history',
              style: TextStyle(color: context.textSecondaryColor)),
        ),
        data: (results) {
          if (results.isEmpty) {
            return _EmptyState();
          }
          final sorted = [...results]
            ..sort((a, b) => b.attemptedAt.compareTo(a.attemptedAt));
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _ResultCard(result: sorted[i]),
          );
        },
      ),
    );
  }
}

String _month(int m) => const [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ][m];

class _ResultCard extends StatelessWidget {
  final QuizResultModel result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final pct = (result.percent * 100).toInt();
    final passed = result.passed;
    final color = passed ? AppColors.primary : AppColors.accentRed;
    final d = result.attemptedAt;
    final dateStr =
        '${d.day} ${_month(d.month)} ${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$pct%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              result.moduleId.isEmpty ? 'Quiz' : result.moduleId.toUpperCase(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.textPrimaryColor,
                    fontSize: 14,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              '${result.score} / ${result.total} correct  •  $dateStr',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
            ),
          ]),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            passed ? 'PASS' : 'FAIL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.quiz_outlined, size: 64, color: context.textSecondaryColor),
        const SizedBox(height: 16),
        Text(
          'No quizzes taken yet',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: context.textPrimaryColor,
                fontSize: 18,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete a lesson quiz to see your results here.',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: context.textSecondaryColor),
        ),
      ]),
    );
  }
}
