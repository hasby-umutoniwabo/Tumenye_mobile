import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tumenye/core/theme/app_theme.dart';
import 'package:tumenye/features/auth/presentation/screens/welcome_screen.dart';
import 'package:tumenye/features/auth/presentation/screens/login_screen.dart';
import 'package:tumenye/features/auth/presentation/screens/register_screen.dart';
import 'package:tumenye/features/auth/presentation/screens/forgot_password_screen.dart';

Widget _wrap(Widget child) => ProviderScope(
    child: MaterialApp(theme: AppTheme.light, home: child));

void main() {
  // ─────────────────────────────────────────────
  // WelcomeScreen
  // ─────────────────────────────────────────────
  group('WelcomeScreen', () {
    testWidgets('shows first slide title', (t) async {
      await t.pumpWidget(_wrap(const WelcomeScreen()));
      await t.pump();
      expect(find.textContaining('Unlock Your'), findsOneWidget);
    });

    testWidgets('shows Next button on first slide', (t) async {
      await t.pumpWidget(_wrap(const WelcomeScreen()));
      await t.pump();
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('shows Log In link', (t) async {
      await t.pumpWidget(_wrap(const WelcomeScreen()));
      await t.pump();
      expect(find.text('Log In'), findsOneWidget);
    });

    testWidgets('shows Skip button', (t) async {
      await t.pumpWidget(_wrap(const WelcomeScreen()));
      await t.pump();
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('shows Already have an account text', (t) async {
      await t.pumpWidget(_wrap(const WelcomeScreen()));
      await t.pump();
      expect(find.textContaining('Already have an account'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────
  // LoginScreen
  // ─────────────────────────────────────────────
  group('LoginScreen', () {
    testWidgets('shows Email Login heading', (t) async {
      await t.pumpWidget(_wrap(const LoginScreen()));
      expect(find.text('Email Login'), findsOneWidget);
    });

    testWidgets('shows Muraho greeting', (t) async {
      await t.pumpWidget(_wrap(const LoginScreen()));
      expect(find.text('Hello! Muraho!'), findsOneWidget);
    });

    testWidgets('shows validation errors when submitted empty', (t) async {
      await t.pumpWidget(_wrap(const LoginScreen()));
      await t.tap(find.text('Start Learning'));
      await t.pump();
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows invalid email error', (t) async {
      await t.pumpWidget(_wrap(const LoginScreen()));
      await t.enterText(find.byType(TextFormField).first, 'bademail');
      await t.tap(find.text('Start Learning'));
      await t.pump();
      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows short password error', (t) async {
      await t.pumpWidget(_wrap(const LoginScreen()));
      await t.enterText(find.byType(TextFormField).first, 'a@b.com');
      await t.enterText(find.byType(TextFormField).last, '123');
      await t.tap(find.text('Start Learning'));
      await t.pump();
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────
  // RegisterScreen
  // ─────────────────────────────────────────────
  group('RegisterScreen', () {
    testWidgets('shows Create Account heading', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      expect(find.text('Create Account'), findsWidgets);
    });

    testWidgets('shows role tabs: Student, Parent, Teacher', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      expect(find.text('Student'), findsOneWidget);
      expect(find.text('Parent'), findsOneWidget);
      expect(find.text('Teacher'), findsOneWidget);
    });

    testWidgets('shows tagline text', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      expect(find.text('Join the Tumenye community today!'), findsOneWidget);
    });

    testWidgets('shows name required error on empty submit', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      final btn = find.widgetWithText(ElevatedButton, 'Create Account');
      await t.ensureVisible(btn);
      await t.tap(btn);
      await t.pump();
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('shows email required error on empty submit', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      final btn = find.widgetWithText(ElevatedButton, 'Create Account');
      await t.ensureVisible(btn);
      await t.tap(btn);
      await t.pump();
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows password required error on empty submit', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      final btn = find.widgetWithText(ElevatedButton, 'Create Account');
      await t.ensureVisible(btn);
      await t.tap(btn);
      await t.pump();
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows weak password error for short password', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), 'Alice Uwera');
      await t.enterText(fields.at(1), 'alice@example.com');
      await t.enterText(fields.at(2), 'short');
      final btn = find.widgetWithText(ElevatedButton, 'Create Account');
      await t.ensureVisible(btn);
      await t.tap(btn);
      await t.pump();
      expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    });

    testWidgets('shows uppercase error for password without uppercase', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), 'Alice Uwera');
      await t.enterText(fields.at(1), 'alice@example.com');
      await t.enterText(fields.at(2), 'alllower1');
      final btn = find.widgetWithText(ElevatedButton, 'Create Account');
      await t.ensureVisible(btn);
      await t.tap(btn);
      await t.pump();
      expect(find.text('Must contain an uppercase letter'), findsOneWidget);
    });

    testWidgets('shows number error for password without digit', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), 'Alice Uwera');
      await t.enterText(fields.at(1), 'alice@example.com');
      await t.enterText(fields.at(2), 'NoDigitsHere');
      final btn = find.widgetWithText(ElevatedButton, 'Create Account');
      await t.ensureVisible(btn);
      await t.tap(btn);
      await t.pump();
      expect(find.text('Must contain a number'), findsOneWidget);
    });

    testWidgets('shows passwords do not match error', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), 'Alice Uwera');
      await t.enterText(fields.at(1), 'alice@example.com');
      await t.enterText(fields.at(2), 'ValidPass1');
      await t.enterText(fields.at(3), 'DifferentPass1');
      final btn = find.widgetWithText(ElevatedButton, 'Create Account');
      await t.ensureVisible(btn);
      await t.tap(btn);
      await t.pump();
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets("shows child email field when Parent role is selected", (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      await t.tap(find.text('Parent'));
      await t.pump();
      expect(find.text("CHILD'S EMAIL (OPTIONAL)"), findsOneWidget);
    });

    testWidgets("hides child email field for Student role", (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      // Student is selected by default
      expect(find.text("CHILD'S EMAIL (OPTIONAL)"), findsNothing);
    });

    testWidgets('shows Sign up with Google button', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      expect(find.text('Sign up with Google'), findsOneWidget);
    });

    testWidgets('shows Log In link for existing users', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      expect(find.text('Log In'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────
  // ForgotPasswordScreen
  // ─────────────────────────────────────────────
  group('ForgotPasswordScreen', () {
    testWidgets('shows Reset Password title', (t) async {
      await t.pumpWidget(_wrap(const ForgotPasswordScreen()));
      expect(find.text('Reset Password'), findsOneWidget);
    });

    testWidgets('shows subtitle instruction text', (t) async {
      await t.pumpWidget(_wrap(const ForgotPasswordScreen()));
      expect(find.textContaining("we'll send"), findsOneWidget);
    });

    testWidgets('shows Send Reset Link button', (t) async {
      await t.pumpWidget(_wrap(const ForgotPasswordScreen()));
      expect(find.text('Send Reset Link'), findsOneWidget);
    });

    testWidgets('shows email required error on empty submit', (t) async {
      await t.pumpWidget(_wrap(const ForgotPasswordScreen()));
      await t.tap(find.text('Send Reset Link'));
      await t.pump();
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows invalid email error for bad format', (t) async {
      await t.pumpWidget(_wrap(const ForgotPasswordScreen()));
      await t.enterText(find.byType(TextFormField).first, 'notanemail');
      await t.tap(find.text('Send Reset Link'));
      await t.pump();
      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows EMAIL ADDRESS label', (t) async {
      await t.pumpWidget(_wrap(const ForgotPasswordScreen()));
      expect(find.text('EMAIL ADDRESS'), findsOneWidget);
    });
  });
}
