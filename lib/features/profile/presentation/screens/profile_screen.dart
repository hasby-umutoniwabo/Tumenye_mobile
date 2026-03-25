import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/providers/preferences_providers.dart';
import '../../../../shared/widgets/icon_box.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(offlineModeProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _Header()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const IconBox(
                  icon: Icons.cloud_download_outlined,
                  color: AppColors.primary),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                Text('Ready for Offline Learning',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Text('Lessons are synced to your device.',
                    style: Theme.of(context).textTheme.bodySmall),
              ])),
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 22),
            ]),
          ),
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 18)),
        SliverToBoxAdapter(child: _DailyGoal()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(child: _SettingsTiles(ref: ref, offline: offline)),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () => showDialog(
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
                            onPressed: () {
                              Navigator.pop(ctx);
                              context.go(AppRoutes.welcome);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentRed),
                            child: const Text('Sign Out')),
                      ],
                    )),
            child: const Row(children: [
              Icon(Icons.logout, size: 18, color: AppColors.accentRed),
              SizedBox(width: 10),
              Text('Sign Out',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentRed)),
            ]),
          ),
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 44)),
      ])),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(children: [
        Row(children: [
          const Icon(Icons.arrow_back_ios_new, size: 20),
          const Spacer(),
          Text('My Profile',
              style: Theme.of(context).textTheme.headlineSmall),
          const Spacer(),
          const SizedBox(width: 20),
        ]),
        const SizedBox(height: 24),
        Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
                color: AppColors.accentOrange,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3)),
            child: const Icon(Icons.person, color: Colors.white, size: 46)),
        const SizedBox(height: 12),
        Text('Emmanuel Nkurunziza',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('Level 4',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white))),
          const SizedBox(width: 8),
          const Text('Fluent Reader',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
        ]),
        const SizedBox(height: 4),
        Text('Kigali, Rwanda',
            style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }
}

class _DailyGoal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Daily Goal',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontSize: 16)),
          const Text('Edit Goal',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
        ]),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(18)),
          child: Column(children: [
            SizedBox(
                width: 100,
                height: 100,
                child: Stack(alignment: Alignment.center, children: [
                  CircularProgressIndicator(
                      value: 0.66,
                      strokeWidth: 10,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.18),
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.primary)),
                  const Text('66%',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                ])),
            const SizedBox(height: 16),
            Text('Learn 15 mins daily',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text(
                "You've completed 10 minutes today.\nOnly 5 more to reach your goal!",
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44)),
                child: const Text('Resume Lesson')),
          ]),
        ),
      ]),
    );
  }
}

class _SettingsTiles extends StatelessWidget {
  final WidgetRef ref;
  final bool offline;
  const _SettingsTiles({required this.ref, required this.offline});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Settings',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontSize: 16)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            SwitchListTile(
                secondary: const IconBox(
                    icon: Icons.cloud_download_outlined,
                    color: AppColors.primary),
                title: const Text('Offline Mode',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: const Text(
                    'Save storage by downloading lessons',
                    style: TextStyle(fontSize: 12)),
                value: offline,
                onChanged: (_) =>
                    ref.read(offlineModeProvider.notifier).toggle(),
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primary),
            const Divider(height: 1, indent: 60, endIndent: 16),
            ListTile(
                leading: const IconBox(
                    icon: Icons.language, color: AppColors.accentBlue),
                title: const Text('Language (Kinyarwanda)',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textHint),
                onTap: () {}),
            const Divider(height: 1, indent: 60, endIndent: 16),
            ListTile(
                leading: const IconBox(
                    icon: Icons.notifications_outlined,
                    color: AppColors.accentOrange),
                title: const Text('Daily Reminders',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textHint),
                onTap: () {}),
          ]),
        ),
      ]),
    );
  }
}