import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tumenye/core/services/auth_service.dart';

FirebaseAuthException _make(String code) =>
    FirebaseAuthException(code: code);

void main() {
  group('AuthService.friendlyError', () {
    test('user-not-found returns correct message', () {
      expect(
        AuthService.friendlyError(_make('user-not-found')),
        'No account found with this email.',
      );
    });

    test('wrong-password returns correct message', () {
      expect(
        AuthService.friendlyError(_make('wrong-password')),
        'Incorrect password. Please try again.',
      );
    });

    test('invalid-credential returns correct message', () {
      expect(
        AuthService.friendlyError(_make('invalid-credential')),
        'Invalid email or password.',
      );
    });

    test('email-already-in-use returns correct message', () {
      expect(
        AuthService.friendlyError(_make('email-already-in-use')),
        'An account already exists with this email.',
      );
    });

    test('weak-password returns correct message', () {
      expect(
        AuthService.friendlyError(_make('weak-password')),
        'Password is too weak. Use at least 6 characters.',
      );
    });

    test('invalid-email returns correct message', () {
      expect(
        AuthService.friendlyError(_make('invalid-email')),
        'Please enter a valid email address.',
      );
    });

    test('too-many-requests returns correct message', () {
      expect(
        AuthService.friendlyError(_make('too-many-requests')),
        'Too many attempts. Please try again later.',
      );
    });

    test('network-request-failed returns correct message', () {
      expect(
        AuthService.friendlyError(_make('network-request-failed')),
        'No internet connection. Please check your network.',
      );
    });

    test('unknown code falls back to generic message', () {
      expect(
        AuthService.friendlyError(_make('some-unknown-error')),
        'Something went wrong. Please try again.',
      );
    });

    test('empty code string falls back to generic message', () {
      expect(
        AuthService.friendlyError(_make('')),
        'Something went wrong. Please try again.',
      );
    });

    test('all known codes return non-empty messages', () {
      final codes = [
        'user-not-found',
        'wrong-password',
        'invalid-credential',
        'email-already-in-use',
        'weak-password',
        'invalid-email',
        'too-many-requests',
        'network-request-failed',
      ];
      for (final code in codes) {
        final msg = AuthService.friendlyError(_make(code));
        expect(msg.isNotEmpty, true,
            reason: 'Error message for "$code" must not be empty');
      }
    });
  });
}
