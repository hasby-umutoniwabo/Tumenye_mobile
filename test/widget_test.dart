import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tumenye/core/theme/app_theme.dart';
import 'package:tumenye/features/auth/presentation/screens/welcome_screen.dart';
import 'package:tumenye/features/auth/presentation/screens/login_screen.dart';

Widget _w(Widget child) => ProviderScope(
    child: MaterialApp(theme: AppTheme.light, home: child));

void main() {
  group('WelcomeScreen', () {
    testWidgets('shows TUMENYE', (t) async {
      await t.pumpWidget(_w(const WelcomeScreen()));
      expect(find.text('TUMENYE'), findsOneWidget);
    });
    testWidgets('shows Get Started button', (t) async {
      await t.pumpWidget(_w(const WelcomeScreen()));
      expect(find.text('Get Started'), findsOneWidget);
    });
    testWidgets('shows Log In link', (t) async {
      await t.pumpWidget(_w(const WelcomeScreen()));
      expect(find.text('Log In'), findsOneWidget);
    });
  });

  group('LoginScreen', () {
    testWidgets('shows Email Login heading', (t) async {
      await t.pumpWidget(_w(const LoginScreen()));
      expect(find.text('Email Login'), findsOneWidget);
    });
    testWidgets('shows Muraho greeting', (t) async {
      await t.pumpWidget(_w(const LoginScreen()));
      expect(find.text('Hello! Muraho!'), findsOneWidget);
    });
    testWidgets('shows validation errors when submitted empty', (t) async {
      await t.pumpWidget(_w(const LoginScreen()));
      await t.tap(find.text('Start Learning'));
      await t.pump();
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });
    testWidgets('shows invalid email error', (t) async {
      await t.pumpWidget(_w(const LoginScreen()));
      await t.enterText(find.byType(TextFormField).first, 'bademail');
      await t.tap(find.text('Start Learning'));
      await t.pump();
      expect(find.text('Enter a valid email address'), findsOneWidget);
    });
    testWidgets('shows short password error', (t) async {
      await t.pumpWidget(_w(const LoginScreen()));
      await t.enterText(find.byType(TextFormField).first, 'a@b.com');
      await t.enterText(find.byType(TextFormField).last, '123');
      await t.tap(find.text('Start Learning'));
      await t.pump();
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });
  });
}