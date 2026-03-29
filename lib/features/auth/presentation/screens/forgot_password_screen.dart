import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _key = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_key.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authServiceProvider).sendPasswordReset(_email.text);
      if (mounted) setState(() => _sent = true);
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = AuthService.friendlyError(e));
    } catch (_) {
      setState(
          () => _errorMessage = 'Could not send reset email. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── Back button ───────────────────────────────────────
                IconButton(
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go(AppRoutes.login),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 24),

                // ── Icon ──────────────────────────────────────────────
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: context.primaryLightColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.lock_reset_outlined,
                        size: 48, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Title + subtitle ──────────────────────────────────
                Center(
                  child: Text('Reset Password',
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "Enter your email and we'll send\na password reset link.",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: context.textSecondaryColor),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 36),

                // ── Success state ─────────────────────────────────────
                if (_sent) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.primaryLightColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.check_circle_outline,
                          color: AppColors.primary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Reset link sent to ${_email.text.trim()}.\nCheck your inbox.',
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('Back to Login'),
                  ),
                ] else ...[
                  // ── Email field ───────────────────────────────────────
                  AppTextField(
                    label: 'EMAIL ADDRESS',
                    controller: _email,
                    hint: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) { return 'Email is required'; }
                      if (!v.contains('@') || !v.contains('.')) { return 'Enter a valid email address'; }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Error banner ──────────────────────────────────────
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(children: [
                        Icon(Icons.error_outline,
                            size: 16, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(_errorMessage!,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.red.shade700))),
                      ]),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Submit button ─────────────────────────────────────
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Send Reset Link'),
                  ),
                ],
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
