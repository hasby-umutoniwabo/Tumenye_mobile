import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/router/app_router.dart';

class ParentScaffold extends StatelessWidget {
  final Widget child;
  const ParentScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location.startsWith(AppRoutes.parentActivity)) currentIndex = 1;
    if (location.startsWith(AppRoutes.parentAccount)) currentIndex = 2;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: context.cardColor,
            border: Border(top: BorderSide(color: context.borderColor))),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBtn(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  active: currentIndex == 0,
                  onTap: () => context.go(AppRoutes.parent),
                ),
                _NavBtn(
                  icon: Icons.bolt_outlined,
                  activeIcon: Icons.bolt_rounded,
                  label: 'Activity',
                  active: currentIndex == 1,
                  onTap: () => context.go(AppRoutes.parentActivity),
                ),
                _NavBtn(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Account',
                  active: currentIndex == 2,
                  onTap: () => context.go(AppRoutes.parentAccount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavBtn({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textHint;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(active ? activeIcon : icon, color: color, size: 24),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight:
                      active ? FontWeight.w700 : FontWeight.w400)),
        ]),
      ),
    );
  }
}
