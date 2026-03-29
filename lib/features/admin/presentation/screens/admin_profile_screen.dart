import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../../core/providers/preferences_providers.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../../shared/widgets/icon_box.dart';

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fbUser = FirebaseAuth.instance.currentUser;
    final userAsync = ref.watch(currentUserStreamProvider);
    final user = userAsync.valueOrNull;
    final name = user?.name.isNotEmpty == true
        ? user!.name
        : fbUser?.displayName ?? fbUser?.email?.split('@').first ?? 'Admin';
    final email = fbUser?.email ?? '';
    final avatarUrl = user?.avatarUrl;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          // ── Header ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Text('My Profile',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: context.textPrimaryColor)),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Profile card ──────────────────────────────────────────
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
                  UserAvatar(
                    name: name,
                    avatarUrl: avatarUrl,
                    size: 64,
                    fallbackColor: AppColors.accentBlue,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(name,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: context.textPrimaryColor)),
                      const SizedBox(height: 3),
                      Text(email,
                          style: TextStyle(
                              fontSize: 12,
                              color: context.textSecondaryColor)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppColors.accentBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text('Administrator',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentBlue)),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Preferences ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('Preferences',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.textSecondaryColor,
                      letterSpacing: 0.5)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(16)),
                child: SwitchListTile(
                  secondary: IconBox(
                      icon: isDark ? Icons.dark_mode : Icons.light_mode,
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
                  activeTrackColor: AppColors.primary,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── App info ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('App',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.textSecondaryColor,
                      letterSpacing: 0.5)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  ListTile(
                    leading: const IconBox(
                        icon: Icons.info_outline,
                        color: AppColors.accentBlue),
                    title: Text('About Tumenye',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimaryColor)),
                    subtitle: Text('Version 2.4.0 · Rwanda Digital Education',
                        style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondaryColor)),
                  ),
                  Divider(height: 1, indent: 60, endIndent: 16,
                      color: context.borderColor),
                  ListTile(
                    leading: const IconBox(
                        icon: Icons.help_outline,
                        color: AppColors.accentPurple),
                    title: Text('Help & Support',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimaryColor)),
                    trailing: Icon(Icons.chevron_right,
                        color: context.textSecondaryColor),
                    onTap: () {},
                  ),
                ]),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Sign out ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: const Text('Sign Out'),
                    content:
                        const Text('Are you sure you want to sign out?'),
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
                ),
                icon: const Icon(Icons.logout,
                    size: 16, color: AppColors.accentRed),
                label: const Text('Sign Out',
                    style: TextStyle(color: AppColors.accentRed)),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: AppColors.accentRed),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ]),
      ),
    );
  }
}
