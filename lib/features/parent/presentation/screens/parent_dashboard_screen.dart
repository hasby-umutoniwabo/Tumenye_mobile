import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                          color: AppColors.accentOrange,
                          shape: BoxShape.circle),
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kalisa',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: AppColors.textSecondary)),
                          Text('Parent Dashboard',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const Icon(Icons.notifications_outlined, size: 24),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            // Student progress card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                            color: AppColors.accentBlue,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.child_care,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Kalisa's Progress",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.w700)),
                            Text(
                                'Got 70% of Word module completed.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text('ACTIVE NOW',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.4)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            // Current focus
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Focus',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontSize: 16)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Microsoft Word',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                          fontWeight: FontWeight.w700)),
                              const Text('70%',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(4)),
                            child: LinearProgressIndicator(
                              value: 0.70,
                              minHeight: 8,
                              backgroundColor: AppColors.border,
                              valueColor: AlwaysStoppedAnimation(
                                  AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                              'Next: Advanced Formatting • 4/6 lessons',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            // Screen time
            SliverToBoxAdapter(child: _ScreenTime()),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            // Recent badges
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Badges',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontSize: 16)),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        _BChip('Typing Pro', Icons.keyboard,
                            AppColors.accentYellow),
                        _BChip('Safety Hero', Icons.shield,
                            AppColors.accentBlue),
                        _BChip('7 Day Streak',
                            Icons.local_fire_department,
                            AppColors.accentOrange),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            // Content controls
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Content Controls',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontSize: 16)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          SwitchListTile(
                            secondary: const Icon(
                                Icons.menu_book_outlined,
                                color: AppColors.accentBlue),
                            title: const Text('Digital Literacy Basics',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            subtitle: const Text(
                                'Enable access to core modules',
                                style: TextStyle(fontSize: 12)),
                            value: true,
                            onChanged: (_) {},
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppColors.primary,
                          ),
                          const Divider(height: 1, indent: 56),
                          SwitchListTile(
                            secondary: const Icon(Icons.security,
                                color: AppColors.accentOrange),
                            title: const Text('Internet Safety Quiz',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            subtitle: const Text(
                                'Require 100% to proceed',
                                style: TextStyle(fontSize: 12)),
                            value: false,
                            onChanged: (_) {},
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.bar_chart, size: 16),
                  label: const Text('View Full Activity Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border))),
        child: const SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(Icons.home, 'Home', true, AppColors.accentOrange),
                _NavItem(Icons.menu_book_outlined, 'Lessons', false,
                    AppColors.accentOrange),
                _NavItem(Icons.message_outlined, 'Messages', false,
                    AppColors.accentOrange),
                _NavItem(Icons.settings_outlined, 'Account', false,
                    AppColors.accentOrange),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScreenTime extends StatelessWidget {
  final _days = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final _vals = const [0.4, 0.7, 0.9, 0.6, 0.8, 1.0, 0.5];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Screen Time Activity',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('+12%',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('5.2 hrs',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                7,
                (i) => Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 32,
                      height: 64 * _vals[i],
                      decoration: BoxDecoration(
                        color: i == 5
                            ? AppColors.accentOrange
                            : AppColors.accentOrange
                                .withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(_days[i],
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textHint)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _BChip(this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color ac;
  const _NavItem(this.icon, this.label, this.active, this.ac);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon,
            color: active ? ac : AppColors.textHint, size: 22),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: active ? ac : AppColors.textHint,
                fontWeight: active
                    ? FontWeight.w600
                    : FontWeight.w400)),
      ],
    );
  }
}