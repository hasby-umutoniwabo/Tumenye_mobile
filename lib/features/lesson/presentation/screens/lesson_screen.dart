import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';

const _pages = [
  _Page('What is Word?',
      'Microsoft Word is a digital tool used to write and format documents. You can use it to create letters, school reports, and stories.',
      'Microsoft Word ni porogaramu ikoreshwa mu kwandika inyandiko zitandukanye n\'amabaruwa.'),
  _Page('Opening Word',
      'To open Microsoft Word, click on the Start menu, then find "Word" in the list of applications. Double-click to open it.',
      'Kugirango ugure Word, kanda ku butumwa bwa "Start" hanyuma ubonere "Word" mu rutonde rw\'porogaramu.'),
  _Page('Typing Your First Document',
      'Once Word is open, click anywhere on the blank page and start typing. The blinking cursor shows where your text will appear.',
      'Nuko Word ifunguye, kanda ahantu hose ku ipaji itagira inyandiko hanyuma utangire kwandika.'),
];

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});
  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _i = 0, _step = 2;
  final int _total = 10;

  void _next() {
    if (_i < _pages.length - 1) setState(() { _i++; _step++; });
    else context.push(AppRoutes.quiz);
  }

  void _back() { if (_i > 0) setState(() { _i--; _step--; }); }

  @override
  Widget build(BuildContext context) {
    final p = _pages[_i];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Column(children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(children: [
            GestureDetector(onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 22)),
            const Spacer(),
            Text('Intro to Word', style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontSize: 17)),
            const Spacer(),
            const Icon(Icons.help_outline, size: 22, color: AppColors.textHint),
          ]),
        ),
        // Step progress
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Step $_step of $_total', style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(height: 5),
            Row(children: List.generate(_total, (i) => Expanded(
              child: Container(height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                    color: i < _step ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(2))),
            ))),
          ]),
        ),
        const SizedBox(height: 16),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Illustration
            Container(width: double.infinity, height: 160,
              decoration: BoxDecoration(color: const Color(0xFFF5F0E8),
                  borderRadius: BorderRadius.circular(16)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.description, size: 64, color: AppColors.accentBlue),
                const SizedBox(height: 10),
                Container(width: 80, height: 4,
                    decoration: BoxDecoration(color: AppColors.border,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 5),
                Container(width: 56, height: 4,
                    decoration: BoxDecoration(color: AppColors.border,
                        borderRadius: BorderRadius.circular(2))),
              ]),
            ),
            const SizedBox(height: 20),
            Text(p.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(p.body, style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(height: 1.65, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            // Kinyarwanda translation
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.translate, size: 16, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Kinyarwanda:', style: TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text(p.translation, style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppColors.textPrimary, height: 1.6)),
                ])),
              ]),
            ),
            const SizedBox(height: 24),
          ]),
        )),
        // Nav buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 26),
          child: Row(children: [
            if (_i > 0) ...[
              Expanded(flex: 2, child: OutlinedButton.icon(
                onPressed: _back,
                icon: const Icon(Icons.arrow_back, size: 15),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48),
                    side: const BorderSide(color: AppColors.border),
                    foregroundColor: AppColors.textSecondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              )),
              const SizedBox(width: 12),
            ],
            Expanded(flex: 3, child: ElevatedButton.icon(
              onPressed: _next,
              icon: Text(_i == _pages.length - 1 ? 'Take Quiz' : 'Next'),
              label: const Icon(Icons.arrow_forward, size: 15),
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48)),
            )),
          ]),
        ),
      ])),
    );
  }
}

class _Page {
  final String title, body, translation;
  const _Page(this.title, this.body, this.translation);
}