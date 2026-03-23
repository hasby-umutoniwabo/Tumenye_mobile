import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/social_login_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false, _hidePass = true, _hideConfirm = true;
  String _role = 'student';

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _pass.dispose(); _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 16),
              IconButton(
                  onPressed: () => context.go(AppRoutes.welcome),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              const SizedBox(height: 12),
              Center(child: Text('Create Account',
                  style: Theme.of(context).textTheme.headlineSmall)),
              const SizedBox(height: 6),
              Center(child: Text('Join the Tumenye community today!',
                  style: Theme.of(context).textTheme.bodyMedium)),
              const SizedBox(height: 28),
              // Role selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.surface,
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
                            color: on ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(8)),
                          child: Center(child: Text(
                            '${r[0].toUpperCase()}${r.substring(1)}',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                color: on ? Colors.white : AppColors.textSecondary))),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              AppTextField(label: 'FULL NAME', controller: _name, hint: 'Enter your full name',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null),
              const SizedBox(height: 16),
              AppTextField(label: 'EMAIL ADDRESS', controller: _email, hint: 'Enter your email',
                  prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email address';
                    return null;
                  }),
              const SizedBox(height: 16),
              AppTextField(label: 'PASSWORD', controller: _pass, hint: 'Create a strong password',
                  prefixIcon: Icons.lock_outline, obscureText: _hidePass,
                  suffixIcon: _hidePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  onSuffixTap: () => setState(() => _hidePass = !_hidePass),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Password must be at least 6 characters' : null),
              const SizedBox(height: 16),
              AppTextField(label: 'CONFIRM PASSWORD', controller: _confirm,
                  hint: 'Re-enter your password', prefixIcon: Icons.lock_outline,
                  obscureText: _hideConfirm,
                  suffixIcon: _hideConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  onSuffixTap: () => setState(() => _hideConfirm = !_hideConfirm),
                  textInputAction: TextInputAction.done,
                  validator: (v) => v != _pass.text ? 'Passwords do not match' : null),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create Account'),
              ),
              const SizedBox(height: 20),
              Row(children: [
                const Expanded(child: Divider()),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text('or', style: Theme.of(context).textTheme.bodySmall)),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 16),
              SocialLoginButton(label: 'Sign up with Google',
                  onPressed: () => context.go(AppRoutes.home)),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Already have an account? ',
                    style: Theme.of(context).textTheme.bodyMedium),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.login),
                  child: const Text('Log In',
                      style: TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w700, color: AppColors.primary)),
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