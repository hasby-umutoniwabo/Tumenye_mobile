import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/quiz_model.dart';
import '../../../../core/services/firestore_service.dart';

class AdminAddQuizScreen extends ConsumerStatefulWidget {
  /// The lesson this quiz belongs to
  final String lessonId;

  /// Non-null = edit mode
  final QuizModel? quiz;

  const AdminAddQuizScreen({
    super.key,
    required this.lessonId,
    this.quiz,
  });

  @override
  ConsumerState<AdminAddQuizScreen> createState() =>
      _AdminAddQuizScreenState();
}

class _AdminAddQuizScreenState extends ConsumerState<AdminAddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _passingScore;

  bool _saving = false;
  String? _error;

  /// Mutable list of questions being built
  late final List<_QuestionDraft> _questions;

  bool get _isEdit => widget.quiz != null;

  @override
  void initState() {
    super.initState();
    final q = widget.quiz;
    _title = TextEditingController(text: q?.title ?? 'Quick Quiz');
    _passingScore =
        TextEditingController(text: '${q?.passingScore ?? 70}');
    _questions = q == null
        ? [_QuestionDraft()]
        : q.questions
            .map((e) => _QuestionDraft.fromModel(e))
            .toList();
  }

  @override
  void dispose() {
    _title.dispose();
    _passingScore.dispose();
    for (final d in _questions) {
      d.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_questions.isEmpty) {
      setState(() => _error = 'Add at least one question.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final questions = _questions
          .asMap()
          .entries
          .map((e) => QuestionModel(
                text: e.value.text.text.trim(),
                options: e.value.options
                    .map((c) => c.text.trim())
                    .toList(),
                correctIndex: e.value.correctIndex,
                explanation: e.value.explanation.text.trim(),
                order: e.key,
              ))
          .toList();

      final quiz = QuizModel(
        id: widget.lessonId,
        lessonId: widget.lessonId,
        title: _title.text.trim(),
        passingScore: int.tryParse(_passingScore.text.trim()) ?? 70,
        questions: questions,
      );

      await FirestoreService().saveQuiz(quiz);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? 'Quiz updated!' : 'Quiz created!'),
        backgroundColor: AppColors.primary,
      ));
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Failed to save quiz: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isEdit ? 'Edit Quiz' : 'New Quiz'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Quiz meta ──────────────────────────────────────────────
            _label('QUIZ TITLE'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _title,
              decoration: _inputDecoration('e.g. Word Processing Quiz'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 14),
            _label('PASSING SCORE (%)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passingScore,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('e.g. 70'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                final n = int.tryParse(v.trim());
                if (n == null || n < 1 || n > 100) {
                  return 'Enter a number between 1 and 100';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // ── Questions ──────────────────────────────────────────────
            Row(children: [
              Text('QUESTIONS',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: context.textSecondaryColor)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _questions.add(_QuestionDraft())),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              ),
            ]),
            const SizedBox(height: 12),

            ..._questions.asMap().entries.map((entry) {
              final i = entry.key;
              final draft = entry.value;
              return _QuestionEditor(
                index: i,
                draft: draft,
                onRemove: _questions.length > 1
                    ? () => setState(() => _questions.removeAt(i))
                    : null,
                onChanged: () => setState(() {}),
              );
            }),

            // ── Error ──────────────────────────────────────────────────
            if (_error != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.accentRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(_error!,
                    style: const TextStyle(
                        color: AppColors.accentRed, fontSize: 13)),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: context.textSecondaryColor));

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );
}

// ── Question draft state ───────────────────────────────────────────────────

class _QuestionDraft {
  final TextEditingController text;
  final TextEditingController explanation;
  final List<TextEditingController> options;
  int correctIndex;

  _QuestionDraft()
      : text = TextEditingController(),
        explanation = TextEditingController(),
        options = List.generate(4, (_) => TextEditingController()),
        correctIndex = 0;

  _QuestionDraft.fromModel(QuestionModel m)
      : text = TextEditingController(text: m.text),
        explanation = TextEditingController(text: m.explanation),
        options = m.options.isEmpty
            ? List.generate(4, (_) => TextEditingController())
            : m.options.map((o) => TextEditingController(text: o)).toList(),
        correctIndex = m.correctIndex;

  void dispose() {
    text.dispose();
    explanation.dispose();
    for (final c in options) {
      c.dispose();
    }
  }
}

// ── Per-question editor widget ─────────────────────────────────────────────

class _QuestionEditor extends StatelessWidget {
  final int index;
  final _QuestionDraft draft;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  const _QuestionEditor({
    required this.index,
    required this.draft,
    required this.onRemove,
    required this.onChanged,
  });

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Text('Q${index + 1}',
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.primary)),
          const Spacer(),
          if (onRemove != null)
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.remove_circle_outline,
                  color: AppColors.accentRed, size: 18),
            ),
        ]),
        const SizedBox(height: 10),

        // Question text
        TextFormField(
          controller: draft.text,
          decoration: _dec('Question text'),
          maxLines: 2,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Question text required' : null,
        ),
        const SizedBox(height: 10),

        // Options
        ...draft.options.asMap().entries.map((e) {
          final i = e.key;
          final ctrl = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              GestureDetector(
                onTap: () {
                  draft.correctIndex = i;
                  onChanged();
                },
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: draft.correctIndex == i
                        ? AppColors.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: draft.correctIndex == i
                          ? AppColors.primary
                          : context.borderColor,
                      width: 2,
                    ),
                  ),
                  child: draft.correctIndex == i
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: ctrl,
                  decoration: _dec('Option ${String.fromCharCode(65 + i)}'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Option required'
                      : null,
                ),
              ),
            ]),
          );
        }),

        // Explanation
        const SizedBox(height: 2),
        TextFormField(
          controller: draft.explanation,
          decoration: _dec('Explanation (shown after answer)'),
        ),
      ]),
    );
  }
}
