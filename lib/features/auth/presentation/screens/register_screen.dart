import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/social_login_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  final _childEmail = TextEditingController();
  bool _loading = false, _hidePass = true, _hideConfirm = true;
  String _role = 'student';
  String? _errorMessage;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    _childEmail.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_key.currentState!.validate()) return;
    setState(() { _loading = true; _errorMessage = null; });

    try {
      final auth = ref.read(authServiceProvider);
      // Map "teacher" UI role to "admin" in Firestore (matches ERD)
      final storedRole = _role == 'teacher' ? 'admin' : _role;
      final user = await auth.registerWithEmail(
        email: _email.text,
        password: _pass.text,
        name: _name.text,
        role: storedRole,
      );
      // Link child account if parent provided a child email
      if (storedRole == 'parent' && _childEmail.text.trim().isNotEmpty) {
        await FirestoreService().linkChildByEmail(
            user.uid, _childEmail.text.trim());
      }
      // Send verification email for email/password registrations
      await auth.sendEmailVerification();
      if (!mounted) return;
      // Go to verification gate — not role home
      context.go(AppRoutes.emailVerification);
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = AuthService.friendlyError(e));
    } catch (_) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleRegister() async {
    setState(() { _loading = true; _errorMessage = null; });

    try {
      final auth = ref.read(authServiceProvider);
      final user = await auth.signInWithGoogle();
      if (!mounted) return;
      if (user != null) _navigateByRole(user.role);
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = AuthService.friendlyError(e));
    } catch (_) {
      setState(() => _errorMessage = 'Google sign-up failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _navigateByRole(String role) {
    switch (role) {
      case 'parent':
        context.go(AppRoutes.parent);
        break;
      case 'admin':
      case 'teacher':
        context.go(AppRoutes.admin);
        break;
      default:
        context.go(AppRoutes.home);
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 16),
              IconButton(
                  onPressed: () => context.go(AppRoutes.welcome),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints()),
              const SizedBox(height: 12),
              Center(
                  child: Text('Create Account',
                      style: Theme.of(context).textTheme.headlineSmall)),
              const SizedBox(height: 6),
              Center(
                  child: Text('Join the Tumenye community today!',
                      style: Theme.of(context).textTheme.bodyMedium)),
              const SizedBox(height: 28),
              // Role selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: ['student', 'parent', 'teacher'].map((r) {
                    final on = r == _role;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _role = r),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              color: on
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8)),
                          child: Center(
                              child: Text(
                                  '${r[0].toUpperCase()}${r.substring(1)}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: on
                                          ? Colors.white
                                          : context.textSecondaryColor))),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              AppTextField(
                  label: 'FULL NAME',
                  controller: _name,
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null),
              const SizedBox(height: 16),
              AppTextField(
                  label: 'EMAIL ADDRESS',
                  controller: _email,
                  hint: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Email is required';
                    if (!v.contains('@') || !v.contains('.'))
                      return 'Enter a valid email address';
                    return null;
                  }),
              const SizedBox(height: 16),
              AppTextField(
                  label: 'PASSWORD',
                  controller: _pass,
                  hint: 'Create a strong password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _hidePass,
                  suffixIcon: _hidePass
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  onSuffixTap: () => setState(() => _hidePass = !_hidePass),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 8) { return 'Password must be at least 8 characters'; }
                    if (!v.contains(RegExp(r'[A-Z]'))) { return 'Must contain an uppercase letter'; }
                    if (!v.contains(RegExp(r'[a-z]'))) { return 'Must contain a lowercase letter'; }
                    if (!v.contains(RegExp(r'[0-9]'))) { return 'Must contain a number'; }
                    return null;
                  }),
              const SizedBox(height: 16),
              AppTextField(
                  label: 'CONFIRM PASSWORD',
                  controller: _confirm,
                  hint: 'Re-enter your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _hideConfirm,
                  suffixIcon: _hideConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  onSuffixTap: () =>
                      setState(() => _hideConfirm = !_hideConfirm),
                  textInputAction: _role == 'parent'
                      ? TextInputAction.next
                      : TextInputAction.done,
                  validator: (v) =>
                      v != _pass.text ? 'Passwords do not match' : null),
              if (_role == 'parent') ...[
                const SizedBox(height: 16),
                AppTextField(
                    label: "CHILD'S EMAIL (OPTIONAL)",
                    controller: _childEmail,
                    hint: "Enter your child's email address",
                    prefixIcon: Icons.child_care_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done),
              ],
              const SizedBox(height: 20),
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
              ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Create Account'),
              ),
              const SizedBox(height: 20),
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child:
                        Text('or', style: Theme.of(context).textTheme.bodySmall)),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 16),
              SocialLoginButton(
                  label: 'Sign up with Google', onPressed: _googleRegister),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Already have an account? ',
                    style: Theme.of(context).textTheme.bodyMedium),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.login),
                  child: const Text('Log In',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
              ]),
              const SizedBox(height: 36),
            ]),
          ),
        ),
      ),
    );
  }
}
