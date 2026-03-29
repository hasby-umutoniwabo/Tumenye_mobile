import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tumenye/core/theme/app_theme.dart';
import 'package:tumenye/features/auth/presentation/screens/register_screen.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(theme: AppTheme.light, home: child),
    );

// The RegisterScreen wraps its content in a SingleChildScrollView. In the
// default 800×600 test viewport the submit button is below the fold.
// Every validation test that needs to tap the button must first call
// ensureVisible() to scroll it into view, then use the ElevatedButton finder
// (not the Text child) so the tap actually hits its RenderBox.

void main() {
  group('RegisterScreen — UI', () {
    testWidgets('shows Create Account heading', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      expect(find.text('Create Account'), findsWidgets);
    });

    testWidgets('shows role selector tabs', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      expect(find.text('Student'), findsOneWidget);
      expect(find.text('Parent'), findsOneWidget);
      expect(find.text('Teacher'), findsOneWidget);
    });

    testWidgets('shows full name, email, password fields', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      expect(find.byType(TextFormField), findsAtLeastNWidgets(3));
    });

    testWidgets('shows Log In link for existing users', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      expect(find.text('Log In'), findsOneWidget);
    });
  });

  group('RegisterScreen — Validation', () {
    // Helper: scrolls the ElevatedButton into view and taps it.
    Future<void> tapSubmit(WidgetTester t) async {
      final btn = find.widgetWithText(ElevatedButton, 'Create Account');
      await t.ensureVisible(btn);
      await t.tap(btn);
      await t.pumpAndSettle();
    }

    testWidgets('shows name required error on empty submit', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      await tapSubmit(t);
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('shows email required error on empty submit', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      await tapSubmit(t);
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows password too short error', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), 'Amina');
      await t.enterText(fields.at(1), 'amina@test.rw');
      await t.enterText(fields.at(2), '123');
      await tapSubmit(t);
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('shows passwords do not match error', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), 'Amina');
      await t.enterText(fields.at(1), 'amina@test.rw');
      await t.enterText(fields.at(2), 'pass123');
      await t.enterText(fields.at(3), 'different');
      await tapSubmit(t);
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('shows invalid email error', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), 'Amina');
      await t.enterText(fields.at(1), 'notanemail');
      await tapSubmit(t);
      expect(find.text('Enter a valid email address'), findsOneWidget);
    });
  });

  group('RegisterScreen — Role Switching', () {
    testWidgets('tapping Parent tab shows child email field', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      await t.tap(find.text('Parent'));
      await t.pump();
      expect(find.text("CHILD'S EMAIL (OPTIONAL)"), findsOneWidget);
    });

    testWidgets('tapping Student tab hides child email field', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      await t.tap(find.text('Parent'));
      await t.pump();
      await t.tap(find.text('Student'));
      await t.pump();
      expect(find.text("CHILD'S EMAIL (OPTIONAL)"), findsNothing);
    });

    testWidgets('Teacher tab is selectable', (t) async {
      await t.pumpWidget(_wrap(const RegisterScreen()));
      await t.tap(find.text('Teacher'));
      await t.pump();
      expect(find.text("CHILD'S EMAIL (OPTIONAL)"), findsNothing);
    });
  });
}
