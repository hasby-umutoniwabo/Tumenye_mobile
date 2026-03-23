import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _State();
}

class _State extends State<NotificationsScreen> {
  int _f = 0;
  static const _filters = ['All', 'Achievements', 'Reminders'];
  static const _notifs = [
    _N(Icons.alarm, AppColors.primary, 'Lesson Reminder',
        'Time to learn! Your next Digital Safety module is waiting.', '10m ago', true),
    _N(Icons.emoji_events, AppColors.accentYellow, 'Goal Achievement',
        "Champion! You've completed the 'Internet Basics' quest.", '2h ago', true),
    _N(Icons.local_fire_department, AppColors.accentOrange, 'Streak Update',
        "5 Days Strong! You're becoming a digital expert.", 'Yesterday', false),
    _N(Icons.person_add_outlined, AppColors.accentBlue, 'New Friend Request',
        'Kallan from Kigali sent you a friend request.', '2d ago', false),
    _N(Icons.shield_outlined, AppColors.accentRed, 'Security Tip',
        "Never share your password with anyone, even friends!", '3d ago', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            GestureDetector(onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new, size: 20)),
            const Spacer(),
            Text('My Notifications', style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(), const SizedBox(width: 20),
          ]),
        ),
        const SizedBox(height: 16),
        SizedBox(height: 36, child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final on = i == _f;
            return GestureDetector(
              onTap: () => setState(() => _f = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                    color: on ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(_filters[i], style: TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: on ? Colors.white : AppColors.textSecondary))));
          })),
        const SizedBox(height: 14),
        Expanded(child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _notifs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final n = _notifs[i];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: n.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(n.icon, color: n.color, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(n.title, style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text(n.time, style: Theme.of(context).textTheme.bodySmall),
                  ]),
                  const SizedBox(height: 3),
                  Text(n.body, style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary)),
                ])),
                if (n.isNew) Container(margin: const EdgeInsets.only(left: 8, top: 5),
                    width: 8, height: 8,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
              ]));
          })),
      ])),
    );
  }
}

class _N { final IconData icon; final Color color; final String title, body, time; final bool isNew;
  const _N(this.icon, this.color, this.title, this.body, this.time, this.isNew); }