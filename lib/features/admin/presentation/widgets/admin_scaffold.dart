import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/router/app_router.dart';

class AdminScaffold extends StatelessWidget {
  final Widget child;
  const AdminScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location.startsWith(AppRoutes.adminStudents)) currentIndex = 1;
    if (location.startsWith(AppRoutes.adminCurriculum)) currentIndex = 2;
    if (location.startsWith(AppRoutes.adminProfile)) currentIndex = 3;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: context.borderColor))),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBtn(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  active: currentIndex == 0,
                  onTap: () => context.go(AppRoutes.admin),
                ),
                _NavBtn(
                  icon: Icons.people_outline,
                  label: 'Students',
                  active: currentIndex == 1,
                  onTap: () => context.go(AppRoutes.adminStudents),
                ),
                _NavBtn(
                  icon: Icons.menu_book_outlined,
                  label: 'Curriculum',
                  active: currentIndex == 2,
                  onTap: () => context.go(AppRoutes.adminCurriculum),
                ),
                _NavBtn(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  active: currentIndex == 3,
                  onTap: () => context.go(AppRoutes.adminProfile),
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
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavBtn(
      {required this.icon,
      required this.label,
      required this.active,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.accentBlue : AppColors.textHint;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.w400)),
        ]),
      ),
    );
  }
}
