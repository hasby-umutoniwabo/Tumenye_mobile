import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/social_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _key = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false, _hidePass = true;

  @override
  void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                IconButton(
                    onPressed: () => context.go(AppRoutes.welcome),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                const SizedBox(height: 12),
                Center(child: Text('Email Login',
                    style: Theme.of(context).textTheme.headlineSmall)),
                const SizedBox(height: 28),
                Center(
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.school_outlined, size: 40, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 20),
                Center(child: Text('Hello! Muraho!',
                    style: Theme.of(context).textTheme.headlineMedium)),
                const SizedBox(height: 6),
                Center(child: Text('Ready to learn something new today?',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center)),
                const SizedBox(height: 32),
                AppTextField(
                  label: 'EMAIL ADDRESS', controller: _email,
                  hint: 'Enter your email', prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'PASSWORD', controller: _pass,
                  hint: 'Enter your password', prefixIcon: Icons.lock_outline,
                  obscureText: _hidePass,
                  suffixIcon: _hidePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  onSuffixTap: () => setState(() => _hidePass = !_hidePass),
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showForgot(context),
                    child: const Text('Forgot Password?',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Start Learning'),
                ),
                const SizedBox(height: 24),
                Row(children: [
                  const Expanded(child: Divider()),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text('or continue with',
                          style: Theme.of(context).textTheme.bodySmall)),
                  const Expanded(child: Divider()),
                ]),
                const SizedBox(height: 16),
                SocialLoginButton(
                    label: 'Continue with Google',
                    onPressed: () => context.go(AppRoutes.home)),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('New student? ', style: Theme.of(context).textTheme.bodyMedium),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.register),
                    child: const Text('Create an Account',
                        style: TextStyle(fontSize: 14,
                            fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ]),
                const SizedBox(height: 16),
                Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.lock_outline, size: 11, color: AppColors.textHint),
                  const SizedBox(width: 5),
                  Text('SAFE & PRIVATE LEARNING ENVIRONMENT',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(fontSize: 10, letterSpacing: 0.5)),
                ])),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgot(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 28,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 28),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Reset Password', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text("Enter your email and we'll send a reset link.",
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          TextField(controller: ctrl, keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Your email address')),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Reset link sent! Check your inbox.'),
                  backgroundColor: AppColors.primary));
            },
            child: const Text('Send Reset Link'),
          ),
        ]),
      ),
    );
  }
}