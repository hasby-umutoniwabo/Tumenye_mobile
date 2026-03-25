import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

const _questions = [
  _Q(
      'Ugomba gukora iki niba umutazi akubajije ijambo ryibanga (password) ryawe?',
      ['Kumubwira', 'Kuceceka', 'Kuyimwima no kubibwira umubyeyi'],
      2,
      'Ntabwo ugomba gusomagura amakuru yawe yibanga rabantu utazi.'),
  _Q(
      'What should you do before clicking a link in an unknown email?',
      ['Click it immediately', 'Verify the sender first', 'Forward it to a classmate'],
      1,
      'Always check the sender\'s address before clicking any links.'),
  _Q(
      'How often should you update your password?',
      ['Never — it\'s fine as is', 'Every few months', 'Only when you forget it'],
      1,
      'Changing passwords regularly keeps your accounts safer.'),
];

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _qi = 0, _score = 0;
  int? _sel;
  bool _answered = false;

  void _select(int i) {
    if (_answered) return;
    setState(() {
      _sel = i;
      _answered = true;
      if (i == _questions[_qi].correct) _score++;
    });
  }

  void _next() {
    if (_qi < _questions.length - 1) {
      setState(() {
        _qi++;
        _sel = null;
        _answered = false;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22)),
              contentPadding: const EdgeInsets.all(28),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.emoji_events,
                    size: 64, color: AppColors.accentYellow),
                const SizedBox(height: 16),
                Text('Quiz Complete! 🎉',
                    style:
                        Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('You scored $_score / ${_questions.length}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
                const SizedBox(height: 8),
                Text(
                    _score == _questions.length
                        ? 'Perfect! Urakoze! 🥇'
                        : 'Good effort! Keep going.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: const Text('Back to Lessons')),
              ]),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_qi];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          child: Column(children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(children: [
            GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 22)),
            const Spacer(),
            Text('Quick Quiz',
                style:
                    Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            Text('${_qi + 1}/${_questions.length}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                  value: (_qi + 1) / _questions.length,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.primary))),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(q.text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600, height: 1.55)),
        ),
        const SizedBox(height: 28),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
              children: List.generate(q.answers.length, (i) {
            final state = _answered
                ? i == q.correct
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
                bg = AppColors.primaryLight;
                border = AppColors.primary;
                tc = AppColors.primaryDark;
                break;
              case _S.correct:
                bg = AppColors.primaryLight;
                border = AppColors.primary;
                tc = AppColors.primaryDark;
                break;
              case _S.wrong:
                bg = AppColors.accentRed.withValues(alpha: 0.08);
                border = AppColors.accentRed;
                tc = AppColors.accentRed;
                break;
              default:
                bg = AppColors.surface;
                border = AppColors.border;
                tc = AppColors.textPrimary;
            }
            return GestureDetector(
              onTap: () => _select(i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 15),
                decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border)),
                child: Row(children: [
                  Expanded(
                      child: Text(q.answers[i],
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: tc))),
                  if (state == _S.correct)
                    const Icon(Icons.check_circle,
                        color: AppColors.primary, size: 18),
                  if (state == _S.wrong)
                    const Icon(Icons.cancel,
                        color: AppColors.accentRed, size: 18),
                ]),
              ),
            );
          })),
        )),
        if (_answered)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.primaryLight,
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
                                color: AppColors.textPrimary,
                                height: 1.5))),
              ]),
            ),
          ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: ElevatedButton(
              onPressed: _answered ? _next : null,
              child: Text(_qi < _questions.length - 1
                  ? 'Komeza / Continue'
                  : 'Finish Quiz')),
        ),
      ])),
    );
  }
}

enum _S { idle, selected, correct, wrong }

class _Q {
  final String text, explanation;
  final List<String> answers;
  final int correct;
  const _Q(this.text, this.answers, this.correct, this.explanation);
}