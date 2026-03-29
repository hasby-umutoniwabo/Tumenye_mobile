import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  Timer? _pollingTimer;
  Timer? _resendTimer;
  int _countdown = 60;
  bool _checking = false;
  bool _resending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startPolling();
    _startResendTimer();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  // ── Auto-poll every 5 s ──────────────────────────────────────────────────

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkVerification(silent: true);
    });
  }

  Future<void> _checkVerification({bool silent = false}) async {
    if (!silent) setState(() => _checking = true);
    try {
      final verified =
          await ref.read(authServiceProvider).reloadAndCheckVerification();
      if (verified && mounted) {
        _pollingTimer?.cancel();
        _resendTimer?.cancel();
        _navigateToRoleHome();
      }
    } catch (_) {
      // Silently ignore polling errors
    } finally {
      if (!silent && mounted) setState(() => _checking = false);
    }
  }

  void _navigateToRoleHome() {
    final userAsync = ref.read(currentUserStreamProvider);
    final role = userAsync.valueOrNull?.role;
    if (role == 'admin') {
      context.go(AppRoutes.admin);
    } else if (role == 'parent') {
      context.go(AppRoutes.parent);
    } else {
      context.go(AppRoutes.home);
    }
  }

  // ── Resend countdown ─────────────────────────────────────────────────────

  void _startResendTimer() {
    setState(() => _countdown = 60);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _resendTimer?.cancel();
        }
      });
    });
  }

  Future<void> _resendEmail() async {
    if (_countdown > 0 || _resending) return;
    setState(() {
      _resending = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authServiceProvider).sendEmailVerification();
      if (!mounted) return;
      _startResendTimer();
    } catch (_) {
      if (mounted) {
        setState(
            () => _errorMessage = 'Could not resend email. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  // ── Sign out ─────────────────────────────────────────────────────────────

  Future<void> _signOut() async {
    _pollingTimer?.cancel();
    _resendTimer?.cancel();
    await ref.read(authServiceProvider).signOut();
    if (mounted) context.go(AppRoutes.welcome);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 56),

              // ── Icon ──────────────────────────────────────────────────
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: context.primaryLightColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.mark_email_unread_outlined,
                    size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 28),

              // ── Title + subtitle ──────────────────────────────────────
              Text('Verify Your Email',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              Text(
                'We sent a verification link to:',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: context.textSecondaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // ── Email pill ────────────────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.borderColor),
                ),
                child: Text(
                  email,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Click the link in the email to activate\nyour account.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: context.textSecondaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),

              // ── Auto-checking indicator ───────────────────────────────
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Checking automatically…',
                  style: TextStyle(
                      fontSize: 11, color: context.textSecondaryColor),
                ),
              ]),
              const SizedBox(height: 32),

              // ── Error banner ──────────────────────────────────────────
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
                const SizedBox(height: 16),
              ],

              // ── Manual check button ───────────────────────────────────
              ElevatedButton.icon(
                onPressed: _checking ? null : () => _checkVerification(),
                icon: _checking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.refresh, size: 18),
                label: Text(_checking ? 'Checking…' : 'I\'ve Verified My Email'),
              ),
              const SizedBox(height: 12),

              // ── Resend button ─────────────────────────────────────────
              OutlinedButton(
                onPressed: (_countdown == 0 && !_resending) ? _resendEmail : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: BorderSide(
                      color: _countdown == 0
                          ? AppColors.primary
                          : context.borderColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _resending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary))
                    : Text(
                        _countdown > 0
                            ? 'Resend in ${_countdown}s'
                            : 'Resend Verification Email',
                        style: TextStyle(
                            color: _countdown == 0
                                ? AppColors.primary
                                : context.textSecondaryColor),
                      ),
              ),
              const Spacer(),

              // ── Sign out escape hatch ─────────────────────────────────
              TextButton(
                onPressed: _signOut,
                child: Text(
                  'Use a different account',
                  style:
                      TextStyle(fontSize: 13, color: context.textSecondaryColor),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
