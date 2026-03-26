import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/module_model.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../../core/services/firestore_service.dart';

class AdminAddModuleScreen extends ConsumerStatefulWidget {
  final ModuleModel? module; // null = create, non-null = edit
  const AdminAddModuleScreen({super.key, this.module});

  @override
  ConsumerState<AdminAddModuleScreen> createState() =>
      _AdminAddModuleScreenState();
}

class _AdminAddModuleScreenState extends ConsumerState<AdminAddModuleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;

  String _iconKey = 'book';
  int _colorValue = 0xFF4A90E2;
  String _difficulty = 'beginner';
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.module != null;

  @override
  void initState() {
    super.initState();
    final m = widget.module;
    _title = TextEditingController(text: m?.title ?? '');
    _description = TextEditingController(text: m?.description ?? '');
    if (m != null) {
      _iconKey = m.iconKey;
      _colorValue = m.colorValue;
      _difficulty = m.difficulty;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final modules = ref.read(modulesProvider).value ?? [];
      final nextOrder = _isEdit
          ? widget.module!.order
          : (modules.isEmpty
              ? 1
              : modules.map((m) => m.order).reduce((a, b) => a > b ? a : b) +
                  1);

      final module = ModuleModel(
        id: _isEdit ? widget.module!.id : '',
        title: _title.text.trim(),
        description: _description.text.trim(),
        iconKey: _iconKey,
        colorValue: _colorValue,
        difficulty: _difficulty,
        order: nextOrder,
        totalLessons: _isEdit ? widget.module!.totalLessons : 0,
      );

      await FirestoreService().saveModule(module);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? 'Module updated!' : 'Module created!'),
        backgroundColor: AppColors.primary,
      ));
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Failed to save module: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isEdit ? 'Edit Module' : 'New Module'),
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
            // ── Preview card ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: Color(_colorValue).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(_iconData(_iconKey),
                      color: Color(_colorValue), size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                        _title.text.isEmpty ? 'Module Title' : _title.text,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                            color:
                                Color(_colorValue).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(_difficulty,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(_colorValue))),
                      ),
                    ]),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            // ── Title ─────────────────────────────────────────────────
            _label('MODULE TITLE'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _title,
              onChanged: (_) => setState(() {}),
              decoration: _dec('e.g. Internet Safety'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),

            // ── Description ───────────────────────────────────────────
            _label('DESCRIPTION'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _description,
              maxLines: 3,
              decoration: _dec('Briefly describe what students will learn'),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Description is required'
                  : null,
            ),
            const SizedBox(height: 20),

            // ── Difficulty ────────────────────────────────────────────
            _label('DIFFICULTY'),
            const SizedBox(height: 8),
            Row(
              children: ['beginner', 'intermediate', 'advanced'].map((d) {
                final selected = d == _difficulty;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _difficulty = d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border)),
                      child: Center(
                        child: Text(
                            '${d[0].toUpperCase()}${d.substring(1)}',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textSecondary)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Icon picker ───────────────────────────────────────────
            _label('ICON'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _iconOptions.entries.map((e) {
                final selected = e.key == _iconKey;
                return GestureDetector(
                  onTap: () => setState(() => _iconKey = e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                        color: selected
                            ? Color(_colorValue).withValues(alpha: 0.15)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: selected
                                ? Color(_colorValue)
                                : AppColors.border,
                            width: selected ? 2 : 1)),
                    child: Icon(e.value,
                        color: selected
                            ? Color(_colorValue)
                            : AppColors.textHint,
                        size: 24),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Color picker ──────────────────────────────────────────
            _label('COLOR'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _colorOptions.map((c) {
                final selected = c == _colorValue;
                return GestureDetector(
                  onTap: () => setState(() => _colorValue = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: selected
                                ? Colors.black38
                                : Colors.transparent,
                            width: 3)),
                    child: selected
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),

            // ── Error ─────────────────────────────────────────────────
            if (_error != null) ...[
              const SizedBox(height: 16),
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
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: AppColors.textSecondary));

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );

  static const _iconOptions = {
    'word': Icons.description_outlined,
    'excel': Icons.grid_on_outlined,
    'email': Icons.email_outlined,
    'safety': Icons.shield_outlined,
    'book': Icons.menu_book_outlined,
    'code': Icons.code,
    'internet': Icons.language_outlined,
    'math': Icons.calculate_outlined,
    'science': Icons.science_outlined,
    'art': Icons.palette_outlined,
  };

  static const _colorOptions = [
    0xFF4A90E2, // blue
    0xFF3DDC84, // green
    0xFFFF8C42, // orange
    0xFF7B61FF, // purple
    0xFFE91E63, // pink
    0xFF00BCD4, // cyan
    0xFFFF5722, // deep orange
    0xFF607D8B, // blue grey
    0xFF8BC34A, // light green
    0xFFFFB300, // amber
  ];

  IconData _iconData(String key) =>
      _iconOptions[key] ?? Icons.book_outlined;
}
