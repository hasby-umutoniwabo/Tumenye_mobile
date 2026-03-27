import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../../core/providers/preferences_providers.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../shared/widgets/icon_box.dart';

class ParentAccountScreen extends ConsumerWidget {
  const ParentAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final parentName = user?.displayName ?? user?.email?.split('@').first ?? 'Parent';
    final email = user?.email ?? '';
    final initial = parentName.isNotEmpty ? parentName[0].toUpperCase() : 'P';

    final childrenAsync = ref.watch(linkedChildrenProvider);
    final reminders = ref.watch(remindersProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          // ── Header ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Text('Account',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: context.textPrimaryColor)),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Profile card ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: context.borderColor)),
                child: Row(children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                        color: AppColors.accentOrange, shape: BoxShape.circle),
                    child: Center(
                      child: Text(initial,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(parentName,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: context.textPrimaryColor)),
                      const SizedBox(height: 3),
                      Text(email,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: context.textSecondaryColor)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppColors.accentOrange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text('Parent Account',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentOrange)),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 22)),

          // ── Linked children ───────────────────────────────────────────
          _SectionLabel('Linked Children'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: childrenAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e',
                    style: const TextStyle(color: AppColors.accentRed)),
                data: (children) => Column(children: [
                  if (children.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: context.borderColor)),
                      child: Row(children: [
                        const Icon(Icons.child_care,
                            color: AppColors.textHint, size: 22),
                        const SizedBox(width: 12),
                        Text('No children linked yet',
                            style: TextStyle(
                                color: context.textSecondaryColor,
                                fontSize: 13)),
                      ]),
                    ),
                  ...children.map((child) {
                    final name =
                        child.name.isNotEmpty ? child.name : child.email;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: context.borderColor)),
                      child: Row(children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                              color: AppColors.accentOrange,
                              shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              name[0].toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: context.textPrimaryColor)),
                              Text(child.email,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: context.textSecondaryColor)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              _confirmUnlink(context, ref, child.uid, name),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: AppColors.accentRed
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Text('Unlink',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accentRed)),
                          ),
                        ),
                      ]),
                    );
                  }),
                  const SizedBox(height: 4),
                  _AddChildInline(),
                ]),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 22)),

          // ── Preferences ───────────────────────────────────────────────
          _SectionLabel('Preferences'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.borderColor)),
                child: Column(children: [
                  SwitchListTile(
                      secondary: const IconBox(
                          icon: Icons.dark_mode_outlined,
                          color: AppColors.accentPurple),
                      title: Text('Dark Mode',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimaryColor)),
                      value: isDark,
                      onChanged: (_) =>
                          ref.read(themeModeProvider.notifier).toggle(),
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.primary),
                  Divider(height: 1, indent: 60, endIndent: 16,
                      color: context.borderColor),
                  SwitchListTile(
                      secondary: const IconBox(
                          icon: Icons.notifications_outlined,
                          color: AppColors.accentOrange),
                      title: Text('Learning Alerts',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimaryColor)),
                      subtitle: Text(
                          'Get notified when your child completes a lesson',
                          style: TextStyle(
                              fontSize: 12,
                              color: context.textSecondaryColor)),
                      value: reminders,
                      onChanged: (_) =>
                          ref.read(remindersProvider.notifier).toggle(),
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.primary),
                ]),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 22)),

          // ── Support ───────────────────────────────────────────────────
          _SectionLabel('Support'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.borderColor)),
                child: Column(children: [
                  ListTile(
                      leading: const IconBox(
                          icon: Icons.help_outline,
                          color: AppColors.accentBlue),
                      title: Text('Help Center',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimaryColor)),
                      trailing: Icon(Icons.chevron_right,
                          color: context.textSecondaryColor),
                      onTap: () {}),
                  Divider(
                      height: 1,
                      indent: 60,
                      endIndent: 16,
                      color: context.borderColor),
                  ListTile(
                      leading: IconBox(
                          icon: Icons.info_outline,
                          color: context.textSecondaryColor),
                      title: Text('About Tumenye',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimaryColor)),
                      trailing: Icon(Icons.chevron_right,
                          color: context.textSecondaryColor),
                      onTap: () {}),
                ]),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Sign out ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                  onPressed: () => _confirmSignOut(context, ref),
                  icon: const Icon(Icons.logout,
                      size: 16, color: AppColors.accentRed),
                  label: const Text('Sign Out',
                      style: TextStyle(color: AppColors.accentRed)),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: AppColors.accentRed),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)))),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('Tumenye · Rwanda Digital Education',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: context.textSecondaryColor)),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ]),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(authServiceProvider).signOut();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentRed),
              child: const Text('Sign Out')),
        ],
      ),
    );
  }

  void _confirmUnlink(
      BuildContext context, WidgetRef ref, String childUid, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Unlink Child'),
        content: Text('Remove $name from your linked children?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid == null) return;
                await FirestoreService().unlinkChild(uid, childUid);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentRed),
              child: const Text('Unlink')),
        ],
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(text.toUpperCase(),
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: context.textSecondaryColor,
                  letterSpacing: 0.6)),
        ),
      );
}

// ─── Inline add child ─────────────────────────────────────────────────────────

class _AddChildInline extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddChildInline> createState() => _AddChildInlineState();
}

class _AddChildInlineState extends ConsumerState<_AddChildInline> {
  bool _expanded = false;
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _link() async {
    final email = _ctrl.text.trim();
    if (email.isEmpty) return;
    setState(() { _loading = true; _error = null; });
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final err = await FirestoreService().linkChildByEmail(uid, email);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = err;
      if (err == null) _expanded = false;
    });
    if (err == null) _ctrl.clear();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!_expanded) {
      return TextButton.icon(
        onPressed: () => setState(() => _expanded = true),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Link another child'),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor)),
      child: Column(children: [
        TextField(
          controller: _ctrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: "Child's email address",
            prefixIcon: const Icon(Icons.email_outlined, size: 20),
            errorText: _error,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _loading ? null : _link,
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
              child: _loading
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Link'),
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
              onPressed: () => setState(() => _expanded = false),
              child: const Text('Cancel')),
        ]),
      ]),
    );
  }
}
