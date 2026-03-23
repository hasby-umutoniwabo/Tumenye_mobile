import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';

const _slides = [
  _Slide('Unlock Your\nDigital Future',
      'Join thousands of Rwandan students learning the skills of tomorrow, today.'),
  _Slide('Learn at\nYour Own Pace',
      'Bite-sized lessons in Kinyarwanda and English. Study offline, anytime.'),
  _Slide('Track Your\nProgress',
      'Earn badges, maintain streaks, and watch your digital literacy grow.'),
];

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final int _page = 0;
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Text('TUMENYE',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(letterSpacing: 4)),
                  const SizedBox(height: 28),
                  Expanded(child: _HeroCard()),
                  const SizedBox(height: 28),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: Column(
                      key: ValueKey(_page),
                      children: [
                        Text(
                          _slides[_page].title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(height: 1.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _slides[_page].body,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _page ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.register),
                    child: const Text('Get Started'),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ',
                          style: Theme.of(context).textTheme.bodyMedium),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.login),
                        child: const Text('Log In',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(28)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
              top: 24,
              right: 28,
              child: _Dot(60, AppColors.primary.withValues(alpha: 0.18))),
          Positioned(
              bottom: 36,
              left: 28,
              child: _Dot(40, AppColors.accentBlue.withValues(alpha: 0.14))),
          Positioned(
              top: 60,
              left: 16,
              child: _Dot(20, AppColors.accentYellow.withValues(alpha: 0.2))),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 130,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.laptop_mac,
                      size: 52, color: AppColors.primary),
                ),
                const SizedBox(height: 24),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Avatar(AppColors.accentOrange, 0),
                    _Avatar(AppColors.primary, -10),
                    _Avatar(AppColors.accentBlue, -10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final double size;
  final Color color;
  const _Dot(this.size, this.color);
  @override
  Widget build(BuildContext context) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

class _Avatar extends StatelessWidget {
  final Color color;
  final double offset;
  const _Avatar(this.color, this.offset);
  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(left: offset < 0 ? offset.abs() : 0),
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
        ),
        child: const Icon(Icons.person, color: Colors.white, size: 24),
      );
}

class _Slide {
  final String title, body;
  const _Slide(this.title, this.body);
}