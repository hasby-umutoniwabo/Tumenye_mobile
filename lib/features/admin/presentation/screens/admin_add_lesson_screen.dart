import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/lesson_model.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../../core/services/firestore_service.dart';

class AdminAddLessonScreen extends ConsumerStatefulWidget {
  /// Null = create mode, non-null = edit mode
  final LessonModel? lesson;

  /// Pre-selected module when coming from the Curriculum screen
  final String? initialModuleId;

  const AdminAddLessonScreen({super.key, this.lesson, this.initialModuleId});

  @override
  ConsumerState<AdminAddLessonScreen> createState() =>
      _AdminAddLessonScreenState();
}

class _AdminAddLessonScreenState extends ConsumerState<AdminAddLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _content;
  late final TextEditingController _translation;
  late final TextEditingController _order;
  late final TextEditingController _minutes;

  String? _selectedModuleId;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.lesson != null;

  @override
  void initState() {
    super.initState();
    final l = widget.lesson;
    _title = TextEditingController(text: l?.title ?? '');
    _content = TextEditingController(text: l?.content ?? '');
    _translation = TextEditingController(text: l?.translation ?? '');
    _order = TextEditingController(text: l != null ? '${l.order}' : '');
    _minutes =
        TextEditingController(text: l != null ? '${l.estimatedMinutes}' : '5');
    _selectedModuleId = l?.moduleId ?? widget.initialModuleId;
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _translation.dispose();
    _order.dispose();
    _minutes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedModuleId == null) {
      setState(() => _error = 'Please select a module.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final moduleId = _selectedModuleId!;
      final order = int.parse(_order.text.trim());
      final lessonId = _isEdit ? widget.lesson!.id : '${moduleId}_$order';

      final lesson = LessonModel(
        id: lessonId,
        moduleId: moduleId,
        title: _title.text.trim(),
        content: _content.text.trim(),
        translation: _translation.text.trim(),
        order: order,
        estimatedMinutes: int.tryParse(_minutes.text.trim()) ?? 5,
      );

      final service = FirestoreService();
      if (_isEdit) {
        await service.updateLesson(lesson);
      } else {
        await service.addLesson(lesson);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(_isEdit ? 'Lesson updated!' : 'Lesson created!'),
        backgroundColor: AppColors.primary,
      ));
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Failed to save lesson: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final modules = ref.watch(modulesProvider).value ?? [];

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isEdit ? 'Edit Lesson' : 'New Lesson'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        CircularProgressIndicator(strokeWidth: 2))
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
            // Module selector
            if (!_isEdit) ...[
              Text('MODULE',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: context.textSecondaryColor)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedModuleId,
                decoration: _inputDecoration('Select module'),
                items: modules
                    .map((m) => DropdownMenuItem(
                        value: m.id,
                        child: Text(m.title)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedModuleId = v),
                validator: (v) =>
                    v == null ? 'Please select a module' : null,
              ),
              const SizedBox(height: 18),
            ],

            // Title
            _label('LESSON TITLE'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _title,
              decoration: _inputDecoration('e.g. What is Microsoft Word?'),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Title is required'
                  : null,
            ),
            const SizedBox(height: 18),

            // Order + Minutes row
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('ORDER'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _order,
                      enabled: !_isEdit,
                      keyboardType: TextInputType.number,
                      decoration:
                          _inputDecoration('e.g. 4'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Required';
                        if (int.tryParse(v.trim()) == null)
                          return 'Must be a number';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('EST. MINUTES'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _minutes,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('e.g. 5'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Required';
                        if (int.tryParse(v.trim()) == null)
                          return 'Must be a number';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 18),

            // Content
            _label('LESSON CONTENT (English)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _content,
              maxLines: 8,
              decoration: _inputDecoration(
                  'Write the lesson content here…'),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Content is required'
                  : null,
            ),
            const SizedBox(height: 18),

            // Translation
            _label('KINYARWANDA TRANSLATION (optional)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _translation,
              maxLines: 6,
              decoration: _inputDecoration(
                  'Igitabo cya mbere… (optional)'),
            ),
            const SizedBox(height: 12),

            // Error
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.accentRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(_error!,
                    style: const TextStyle(
                        color: AppColors.accentRed, fontSize: 13)),
              ),
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
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
      );
}
