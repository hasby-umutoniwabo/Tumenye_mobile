import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/quiz_model.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/firestore_service.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});
  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _qi = 0, _score = 0;
  int? _sel;
  bool _answered = false;
  bool _saving = false;

  void _select(int i, QuestionModel q) {
    if (_answered) return;
    setState(() {
      _sel = i;
      _answered = true;
      if (i == q.correctIndex) _score++;
    });
  }

  Future<void> _next(List<QuestionModel> questions, String lessonId) async {
    if (_qi < questions.length - 1) {
      setState(() {
        _qi++;
        _sel = null;
        _answered = false;
      });
    } else {
      await _saveAndShowResult(questions, lessonId);
    }
  }

  Future<void> _saveAndShowResult(
      List<QuestionModel> questions, String lessonId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      setState(() => _saving = true);
      // moduleId is the prefix of lessonId (e.g. 'word' from 'word_1')
      final moduleId = lessonId.split('_').first;
      await FirestoreService().saveQuizResult(
        userId: uid,
        quizId: lessonId,
        moduleId: moduleId,
        score: _score,
        total: questions.length,
      );
      setState(() => _saving = false);
    }
    if (mounted) _showResult(questions.length);
  }

  void _showResult(int total) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22)),
              contentPadding: const EdgeInsets.all(28),
              content:
                  Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.emoji_events,
                    size: 64, color: AppColors.accentYellow),
                const SizedBox(height: 16),
                Text('Quiz Complete! 🎉',
                    style:
                        Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('You scored $_score / $total',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
                const SizedBox(height: 8),
                Text(
                    _score == total
                        ? 'Perfect! Urakoze! 🥇'
                        : _score >= (total * 0.7).ceil()
                            ? 'Passed! Keep it up! 🎯'
                            : 'Keep practicing. Komeza! 💪',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go(AppRoutes.modules);
                    },
                    child: const Text('Back to Modules')),
              ]),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final lessonId =
        GoRouterState.of(context).extra as String? ?? 'word_1';
    final quizAsync = ref.watch(quizProvider(lessonId));

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: quizAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (quiz) {
            if (quiz == null || quiz.questions.isEmpty) {
              return const Center(child: Text('No quiz available.'));
            }
            final questions = quiz.questions;
            // Guard: _qi can go out of bounds if the quiz data refreshes
            // (e.g. auth token renewal causes quizProvider to re-fetch)
            // mid-session with fewer questions than before.
            if (_qi >= questions.length) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() { _qi = 0; _sel = null; _answered = false; });
              });
              return const Center(child: CircularProgressIndicator());
            }
            final q = questions[_qi];

            return Column(children: [
              // ─── Header ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                child: Row(children: [
                  GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 22)),
                  const Spacer(),
                  Text('Quick Quiz',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall),
                  const Spacer(),
                  Text('${_qi + 1}/${questions.length}',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondaryColor)),
                ]),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                        value: (_qi + 1) / questions.length,
                        minHeight: 6,
                        backgroundColor: context.borderColor,
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.primary))),
              ),
              const SizedBox(height: 32),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24),
                child: Text(q.text,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.55)),
              ),
              const SizedBox(height: 28),
              // ─── Options ────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                      children:
                          List.generate(q.options.length, (i) {
                    final state = _answered
                        ? i == q.correctIndex
                            ? _S.correct
                            : i == _sel
                                ? _S.wrong
                                : _S.idle
                        : i == _sel
                            ? _S.selected
                            : _S.idle;
                    final Color bg, border, tc;
                    switch (state) {
                      case _S.selected:
                        bg = context.primaryLightColor;
                        border = AppColors.primary;
                        tc = AppColors.primaryDark;
                        break;
                      case _S.correct:
                        bg = context.primaryLightColor;
                        border = AppColors.primary;
                        tc = AppColors.primaryDark;
                        break;
                      case _S.wrong:
                        bg = AppColors.accentRed
                            .withValues(alpha: 0.08);
                        border = AppColors.accentRed;
                        tc = AppColors.accentRed;
                        break;
                      default:
                        bg = context.surfaceColor;
                        border = context.borderColor;
                        tc = context.textPrimaryColor;
                    }
                    return GestureDetector(
                      onTap: () => _select(i, q),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 15),
                        decoration: BoxDecoration(
                            color: bg,
                            borderRadius:
                                BorderRadius.circular(12),
                            border: Border.all(color: border)),
                        child: Row(children: [
                          Expanded(
                              child: Text(q.options[i],
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: tc))),
                          if (state == _S.correct)
                            const Icon(Icons.check_circle,
                                color: AppColors.primary,
                                size: 18),
                          if (state == _S.wrong)
                            const Icon(Icons.cancel,
                                color: AppColors.accentRed,
                                size: 18),
                        ]),
                      ),
                    );
                  })),
                ),
              ),
              // ─── Explanation ─────────────────────────────────────────
              if (_answered)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: context.primaryLightColor,
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      const Icon(Icons.lightbulb_outline,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(q.explanation,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: context.textPrimaryColor,
                                      height: 1.5))),
                    ]),
                  ),
                ),
              const SizedBox(height: 14),
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: ElevatedButton(
                    onPressed: (_answered && !_saving)
                        ? () => _next(questions, lessonId)
                        : null,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white))
                        : Text(_qi < questions.length - 1
                            ? 'Komeza / Continue'
                            : 'Finish Quiz')),
              ),
            ]);
          },
        ),
      ),
    );
  }
}

enum _S { idle, selected, correct, wrong }
