import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';

class _Slide {
  final String title;
  final String body;
  final Widget visual;
  const _Slide(this.title, this.body, this.visual);
}

List<_Slide> _buildSlides(BuildContext context) => [
      _Slide(
        'Unlock Your\nDigital Future',
        'Join thousands of Rwandan students learning MS Office, internet safety, and digital skills.',
        _ImageVisual(context),
      ),
      _Slide(
        'Learn at\nYour Own Pace',
        'Bite-sized lessons in Kinyarwanda, English, and French. Study offline, anytime.',
        _PaceVisual(context),
      ),
      _Slide(
        'Track Your\nProgress',
        'Earn badges, maintain streaks, and watch your digital literacy grow every day.',
        _ProgressVisual(context),
      ),
    ];

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 2) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      context.go(AppRoutes.register);
    }
  }

  @override
  Widget build(BuildContext context) {
    final slides = _buildSlides(context);
    final isLast = _page == slides.length - 1;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip button ──────────────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 20, 0),
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.register),
                  child: Text('Skip',
                      style: TextStyle(
                          color: context.textSecondaryColor,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),

            // ── Slides ───────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _SlidePage(slide: slides[i]),
              ),
            ),

            // ── Dots ─────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _page ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _page ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Primary action button ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: _next,
                child: Text(isLast ? 'Get Started' : 'Next'),
              ),
            ),

            const SizedBox(height: 14),

            // ── Log In link ──────────────────────────────────────────────
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
    );
  }
}

class _SlidePage extends StatelessWidget {
  final _Slide slide;
  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Visual card
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: context.primaryLightColor,
                  borderRadius: BorderRadius.circular(28)),
              child: slide.visual,
            ),
          ),
          const SizedBox(height: 28),
          // Title
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.headlineMedium?.copyWith(height: 1.3),
          ),
          const SizedBox(height: 12),
          // Body
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Slide 1: welcome.png ─────────────────────────────────────────────────────

class _ImageVisual extends StatelessWidget {
  const _ImageVisual(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Image.asset(
        'assets/images/welcome.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}

// ── Slide 2: language / pace illustration ────────────────────────────────────

class _PaceVisual extends StatelessWidget {
  const _PaceVisual(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 8))
                ],
              ),
              child: const Icon(Icons.menu_book_rounded,
                  size: 60, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            // Language pills
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _Pill('English', AppColors.accentBlue),
                _Pill('Kinyarwanda', AppColors.primary),
                _Pill('Français', AppColors.accentPurple),
                _Pill('Offline ✓', AppColors.accentOrange),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Slide 3: achievement / progress illustration ──────────────────────────────

class _ProgressVisual extends StatelessWidget {
  const _ProgressVisual(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Trophy
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                  color: AppColors.accentYellow, shape: BoxShape.circle),
              child: const Icon(Icons.emoji_events_rounded,
                  size: 56, color: Colors.white),
            ),
            const SizedBox(height: 20),
            // Stat row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatBox(Icons.bolt, '12', 'Lessons'),
                const SizedBox(width: 12),
                _StatBox(Icons.star, '85%', 'Quiz avg'),
                const SizedBox(width: 12),
                _StatBox(Icons.local_fire_department, '7', 'Streak'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Text(label,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      );
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatBox(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary)),
        ]),
      );
}
