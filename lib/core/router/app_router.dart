import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/modules/presentation/screens/modules_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/lesson/presentation/screens/lesson_screen.dart';
import '../../features/quiz/presentation/screens/quiz_screen.dart';
import '../../features/achievements/presentation/screens/achievements_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/parent/presentation/screens/parent_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

abstract class AppRoutes {
  static const welcome = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const modules = '/modules';
  static const profile = '/profile';
  static const settings = '/settings';
  static const lesson = '/lesson';
  static const quiz = '/quiz';
  static const achievements = '/achievements';
  static const notifications = '/notifications';
  static const parent = '/parent';
  static const admin = '/admin';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.welcome,
  routes: [
    GoRoute(path: AppRoutes.welcome, builder: (_, __) => const WelcomeScreen()),
    GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
    GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),
    ShellRoute(
      builder: (_, __, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
        GoRoute(path: AppRoutes.modules, builder: (_, __) => const ModulesScreen()),
        GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfileScreen()),
        GoRoute(path: AppRoutes.settings, builder: (_, __) => const SettingsScreen()),
      ],
    ),
    GoRoute(path: AppRoutes.lesson, builder: (_, __) => const LessonScreen()),
    GoRoute(path: AppRoutes.quiz, builder: (_, __) => const QuizScreen()),
    GoRoute(path: AppRoutes.achievements, builder: (_, __) => const AchievementsScreen()),
    GoRoute(path: AppRoutes.notifications, builder: (_, __) => const NotificationsScreen()),
    GoRoute(path: AppRoutes.parent, builder: (_, __) => const ParentDashboardScreen()),
    GoRoute(path: AppRoutes.admin, builder: (_, __) => const AdminDashboardScreen()),
  ],
);