import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../features/parent/presentation/screens/parent_activity_screen.dart';
import '../../features/parent/presentation/screens/parent_account_screen.dart';
import '../../features/parent/presentation/widgets/parent_scaffold.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_students_screen.dart';
import '../../features/admin/presentation/screens/admin_student_detail_screen.dart';
import '../../features/admin/presentation/screens/admin_curriculum_screen.dart';
import '../../features/admin/presentation/screens/admin_add_lesson_screen.dart';
import '../../features/admin/presentation/screens/admin_add_quiz_screen.dart';
import '../../features/admin/presentation/screens/admin_add_module_screen.dart';
import '../../features/admin/presentation/screens/admin_profile_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../models/module_model.dart';
import '../../features/admin/presentation/widgets/admin_scaffold.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../providers/auth_provider.dart';

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
  static const parentActivity = '/parent/activity';
  static const parentAccount = '/parent/account';
  static const admin = '/admin';
  static const adminStudents = '/admin/students';
  static const adminStudentDetail = '/admin/students/:uid';
  static const adminCurriculum = '/admin/curriculum';
  static const adminProfile = '/admin/profile';
  static const adminAddLesson = '/admin/add-lesson';
  static const adminAddQuiz = '/admin/add-quiz';
  static const adminAddModule = '/admin/add-module';
  static const emailVerification = '/email-verification';
  static const forgotPassword = '/forgot-password';
}

const _authRoutes = {
  AppRoutes.welcome,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.forgotPassword,
};

/// Notifies GoRouter to re-evaluate redirects whenever the current user's
/// role stream emits (e.g. after sign-in, role loaded, sign-out).
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen<AsyncValue>(currentUserStreamProvider, (_, __) {
      notifyListeners();
    });
    // Also refresh on raw auth state changes (sign-in / sign-out)
    ref.listen<AsyncValue>(authStateProvider, (_, __) {
      notifyListeners();
    });
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.welcome,
    refreshListenable: notifier,
    redirect: (context, state) {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final isLoggedIn = firebaseUser != null;
      final loc = state.matchedLocation;
      final onAuthRoute = _authRoutes.contains(loc);
      final onAdminRoute = loc.startsWith('/admin');
      final onVerifyRoute = loc == AppRoutes.emailVerification;

      // Not logged in → always go to welcome (verification screen also needs auth)
      if (!isLoggedIn && !onAuthRoute) return AppRoutes.welcome;

      if (isLoggedIn) {
        final isEmailVerified = firebaseUser.emailVerified;
        final isGoogleUser = firebaseUser.providerData
            .any((p) => p.providerId == 'google.com');
        final needsVerification = !isEmailVerified && !isGoogleUser;

        // Unverified email user → force to verification screen
        if (needsVerification && !onVerifyRoute) {
          return AppRoutes.emailVerification;
        }

        final userAsync = ref.read(currentUserStreamProvider);

        // Role still loading — stay put and wait for next notification
        if (userAsync.isLoading) return null;

        final role = userAsync.valueOrNull?.role;

        // Firestore doc not created yet (right after registration) — wait
        if (role == null) return null;

        // Verified user on verification screen → redirect to role home
        if (onVerifyRoute && !needsVerification) {
          if (role == 'admin') return AppRoutes.admin;
          if (role == 'parent') return AppRoutes.parent;
          return AppRoutes.home;
        }

        // On an auth screen while logged in → redirect to role home
        if (onAuthRoute) {
          if (role == 'admin') return AppRoutes.admin;
          if (role == 'parent') return AppRoutes.parent;
          return AppRoutes.home;
        }

        // Non-admin trying to reach an admin route → back to home
        if (onAdminRoute && role != 'admin') return AppRoutes.home;

        // Admin on non-admin routes → send to admin dashboard
        if (role == 'admin' && !onAdminRoute) return AppRoutes.admin;

        // Parent on non-parent routes → send to parent dashboard
        if (role == 'parent' && !loc.startsWith('/parent')) return AppRoutes.parent;
      }

      return null;
    },
    routes: [
      GoRoute(
          path: AppRoutes.welcome, builder: (_, __) => const WelcomeScreen()),
      GoRoute(
          path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (_, __, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
              path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
          GoRoute(
              path: AppRoutes.modules,
              builder: (_, __) => const ModulesScreen()),
          GoRoute(
              path: AppRoutes.profile,
              builder: (_, __) => const ProfileScreen()),
          GoRoute(
              path: AppRoutes.settings,
              builder: (_, __) => const SettingsScreen()),
        ],
      ),
      GoRoute(
          path: AppRoutes.lesson, builder: (_, __) => const LessonScreen()),
      GoRoute(path: AppRoutes.quiz, builder: (_, __) => const QuizScreen()),
      GoRoute(
          path: AppRoutes.achievements,
          builder: (_, __) => const AchievementsScreen()),
      GoRoute(
          path: AppRoutes.notifications,
          builder: (_, __) => const NotificationsScreen()),
      // Parent shell with bottom nav
      ShellRoute(
        builder: (_, __, child) => ParentScaffold(child: child),
        routes: [
          GoRoute(
              path: AppRoutes.parent,
              builder: (_, __) => const ParentDashboardScreen()),
          GoRoute(
              path: AppRoutes.parentActivity,
              builder: (_, __) => const ParentActivityScreen()),
          GoRoute(
              path: AppRoutes.parentAccount,
              builder: (_, __) => const ParentAccountScreen()),
        ],
      ),
      // Admin shell with bottom nav
      ShellRoute(
        builder: (_, __, child) => AdminScaffold(child: child),
        routes: [
          GoRoute(
              path: AppRoutes.admin,
              builder: (_, __) => const AdminDashboardScreen()),
          GoRoute(
              path: AppRoutes.adminStudents,
              builder: (_, __) => const AdminStudentsScreen()),
          GoRoute(
              path: AppRoutes.adminCurriculum,
              builder: (_, __) => const AdminCurriculumScreen()),
          GoRoute(
              path: AppRoutes.adminProfile,
              builder: (_, __) => const AdminProfileScreen()),
        ],
      ),
      // Student detail — no bottom nav
      GoRoute(
        path: '/admin/students/:uid',
        builder: (_, state) => AdminStudentDetailScreen(
          studentUid: state.pathParameters['uid']!,
          student: state.extra as dynamic,
        ),
      ),
      // Add / edit lesson — no bottom nav
      GoRoute(
        path: AppRoutes.adminAddLesson,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AdminAddLessonScreen(
            lesson: extra?['lesson'],
            initialModuleId: extra?['moduleId'] as String?,
          );
        },
      ),
      // Add / edit module — no bottom nav
      GoRoute(
        path: AppRoutes.adminAddModule,
        builder: (_, state) => AdminAddModuleScreen(
          module: state.extra as ModuleModel?,
        ),
      ),
      // Add / edit quiz — no bottom nav
      GoRoute(
        path: AppRoutes.adminAddQuiz,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>;
          return AdminAddQuizScreen(
            lessonId: extra['lessonId'] as String,
            quiz: extra['quiz'],
          );
        },
      ),
      // Email verification gate — no bottom nav
      GoRoute(
        path: AppRoutes.emailVerification,
        builder: (_, __) => const EmailVerificationScreen(),
      ),
      // Forgot password — no bottom nav
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
    ],
  );
});
