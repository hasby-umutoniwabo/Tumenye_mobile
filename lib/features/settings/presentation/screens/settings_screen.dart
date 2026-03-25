import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/providers/preferences_providers.dart';
import '../../../../shared/widgets/icon_box.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final offline = ref.watch(offlineModeProvider);
    final data = ref.watch(dataUsageProvider);
    final reminders = ref.watch(remindersProvider);
    final lang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          child: CustomScrollView(slivers: [
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Row(children: [
            GestureDetector(
                onTap: () => context.go(AppRoutes.home),
                child: const Icon(Icons.arrow_back_ios_new, size: 20)),
            const Spacer(),
            Text('Settings',
                style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            const SizedBox(width: 20),
          ]),
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                      color: AppColors.accentOrange,
                      shape: BoxShape.circle),
                  child: const Icon(Icons.person,
                      color: Colors.white, size: 28)),
              const SizedBox(width: 12),
              Expanded(
                  child:
                      Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                Text('Keza Uwase',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text('Digital Literacy Student',
                    style: Theme.of(context).textTheme.bodySmall),
              ])),
              const Icon(Icons.chevron_right,
                  size: 20, color: AppColors.textHint),
            ]),
          ),
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        const _Label('Appearance'),
        _Card([
          SwitchListTile(
              secondary: IconBox(
                  icon: isDark ? Icons.dark_mode : Icons.light_mode,
                  color: AppColors.accentPurple),
              title: const Text('Dark Mode',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              value: isDark,
              onChanged: (_) =>
                  ref.read(themeModeProvider.notifier).toggle(),
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary),
        ]),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const _Label('Connection & Storage'),
        _Card([
          SwitchListTile(
              secondary: const IconBox(
                  icon: Icons.download_outlined, color: AppColors.primary),
              title: const Text('Offline Downloads',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text(
                  'Save lessons to study without internet',
                  style: TextStyle(fontSize: 12)),
              value: offline,
              onChanged: (_) =>
                  ref.read(offlineModeProvider.notifier).toggle(),
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary),
          const Divider(height: 1, indent: 60, endIndent: 16),
          SwitchListTile(
              secondary: const IconBox(
                  icon: Icons.data_usage, color: AppColors.accentBlue),
              title: const Text('Data Usage Mode',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text(
                  'Use less data by lowering video quality',
                  style: TextStyle(fontSize: 12)),
              value: data,
              onChanged: (_) =>
                  ref.read(dataUsageProvider.notifier).toggle(),
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary),
        ]),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const _Label('Personalization'),
        _Card([
          SwitchListTile(
              secondary: const IconBox(
                  icon: Icons.notifications_outlined,
                  color: AppColors.accentOrange),
              title: const Text('Daily Reminders',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              value: reminders,
              onChanged: (_) =>
                  ref.read(remindersProvider.notifier).toggle(),
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary),
          const Divider(height: 1, indent: 60, endIndent: 16),
          ListTile(
              leading: const IconBox(
                  icon: Icons.language, color: AppColors.accentCyan),
              title: const Text('Language',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text(lang,
                  style: const TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textHint),
              onTap: () => _showLangPicker(context, ref, lang)),
        ]),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const _Label('Support'),
        _Card([
          ListTile(
              leading: const IconBox(
                  icon: Icons.help_outline,
                  color: AppColors.accentPurple),
              title: const Text('Help Center',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textHint),
              onTap: () {}),
          const Divider(height: 1, indent: 60, endIndent: 16),
          ListTile(
              leading: const IconBox(
                  icon: Icons.info_outline,
                  color: AppColors.textSecondary),
              title: const Text('About the App',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textHint),
              onTap: () {}),
        ]),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.welcome),
              icon: const Icon(Icons.logout,
                  size: 16, color: AppColors.accentRed),
              label: const Text('Sign Out',
                  style: TextStyle(color: AppColors.accentRed)),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: AppColors.accentRed),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)))),
        )),
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
              child: Text('Version 2.4.0 (Rwanda Digital Ed)',
                  style: Theme.of(context).textTheme.bodySmall)),
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ])),
    );
  }

  void _showLangPicker(
      BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.background,
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24))),
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
                              ? const Icon(Icons.check,
                                  color: AppColors.primary)
                              : null,
                          onTap: () {
                            ref.read(languageProvider.notifier).set(l);
                            Navigator.pop(ctx);
                          }),
                  ]),
            ));
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5)),
      ));
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card(this.children);
  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16)),
            child: Column(children: children)),
      ));
}