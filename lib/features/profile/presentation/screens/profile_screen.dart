import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../../core/providers/preferences_providers.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../shared/widgets/icon_box.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(offlineModeProvider);
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? user?.email?.split('@').first ?? 'User';
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
          child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _Header(displayName: displayName, ref: ref)),
        if (offline) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: context.primaryLightColor,
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
                          color: context.textPrimaryColor)),
                  Text('Lessons are synced to your device.',
                      style: Theme.of(context).textTheme.bodySmall),
                ])),
                const Icon(Icons.check_circle,
                    color: AppColors.primary, size: 22),
              ]),
            ),
          )),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 18)),
        SliverToBoxAdapter(child: _DailyGoal()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(child: _SettingsTiles()),
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
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await ref
                                  .read(authServiceProvider)
                                  .signOut();
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

class _Header extends ConsumerStatefulWidget {
  final String displayName;
  final WidgetRef ref;
  const _Header({required this.displayName, required this.ref});

  @override
  ConsumerState<_Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<_Header> {
  bool _uploading = false;

  Future<void> _changeAvatar() async {
    setState(() => _uploading = true);
    try {
      await ImageUploadService().pickAndUploadAvatar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: AppColors.accentRed,
        ));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = ref.watch(currentUserStreamProvider).valueOrNull?.avatarUrl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(children: [
        Row(children: [
          GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new, size: 20)),
          const Spacer(),
          Text('My Profile',
              style: Theme.of(context).textTheme.headlineSmall),
          const Spacer(),
          const SizedBox(width: 20),
        ]),
        const SizedBox(height: 24),

        // ── Avatar with edit overlay ───────────────────────────────────
        GestureDetector(
          onTap: _uploading ? null : _changeAvatar,
          child: Stack(
            children: [
              // Avatar circle
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 3)),
                child: ClipOval(
                  child: avatarUrl != null
                      ? CachedNetworkImage(
                          imageUrl: avatarUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.accentOrange,
                            child: const Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white)),
                          ),
                          errorWidget: (_, __, ___) => _InitialsAvatar(
                              name: widget.displayName),
                        )
                      : _InitialsAvatar(name: widget.displayName),
                ),
              ),
              // Upload loading overlay
              if (_uploading)
                Positioned.fill(
                  child: ClipOval(
                    child: Container(
                      color: Colors.black45,
                      child: const Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              // Camera icon badge
              if (!_uploading)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 14),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        Text(widget.displayName,
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('Tap your photo to change it',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textHint)),
      ]),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String name;
  const _InitialsAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: AppColors.accentOrange,
      child: Center(
        child: Text(initial,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _DailyGoal extends ConsumerWidget {
  static const int _goalMinutes = 30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayMins = ref.watch(todayScreenTimeProvider).value ?? 0;
    final done = todayMins.clamp(0, _goalMinutes);
    final progress = done / _goalMinutes;
    final pct = (progress * 100).toInt();
    final remaining = _goalMinutes - done;
    final statusText = done >= _goalMinutes
        ? "You've reached your goal today!"
        : "You've completed $done min today.\nOnly $remaining more to reach your goal!";

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
              color: context.primaryLightColor,
              borderRadius: BorderRadius.circular(18)),
          child: Column(children: [
            progress >= 1.0
                ? Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 52))
                : SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(alignment: Alignment.center, children: [
                      CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.18),
                          valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary)),
                      Text('$pct%',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary)),
                    ])),
            const SizedBox(height: 16),
            Text('Learn $_goalMinutes mins daily',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text(statusText,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () => context.go(AppRoutes.modules),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44)),
                child: const Text('Resume Lesson')),
          ]),
        ),
      ]),
    );
  }
}

class _SettingsTiles extends ConsumerWidget {
  const _SettingsTiles();

  void _showLangPicker(BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
        context: context,
        backgroundColor: context.bgColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (ctx) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Language',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    for (final l in ['English', 'Kinyarwanda', 'French'])
                      ListTile(
                          title: Text(l),
                          trailing: l == current
                              ? const Icon(Icons.check, color: AppColors.primary)
                              : null,
                          onTap: () {
                            ref.read(languageProvider.notifier).set(l);
                            Navigator.pop(ctx);
                          }),
                  ]),
            ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(offlineModeProvider);
    final reminders = ref.watch(remindersProvider);
    final lang = ref.watch(languageProvider);

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
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            SwitchListTile(
                secondary: const IconBox(
                    icon: Icons.cloud_download_outlined,
                    color: AppColors.primary),
                title: const Text('Offline Mode',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: const Text('Save storage by downloading lessons',
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
                title: const Text('Language',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text(lang, style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textHint),
                onTap: () => _showLangPicker(context, ref, lang)),
            const Divider(height: 1, indent: 60, endIndent: 16),
            SwitchListTile(
                secondary: const IconBox(
                    icon: Icons.notifications_outlined,
                    color: AppColors.accentOrange),
                title: const Text('Daily Reminders',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                value: reminders,
                onChanged: (_) =>
                    ref.read(remindersProvider.notifier).toggle(),
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primary),
          ]),
        ),
      ]),
    );
  }
}