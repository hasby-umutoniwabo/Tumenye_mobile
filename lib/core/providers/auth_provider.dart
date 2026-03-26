import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

/// Single instance of AuthService
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Stream of Firebase auth state (User? — null when signed out)
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Current user's Firestore document, loaded once after sign-in
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return ref.read(authServiceProvider).getUserData(user.uid);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Real-time stream of the current user's Firestore document.
/// Used by the router to make role-based redirect decisions.
final currentUserStreamProvider = StreamProvider<UserModel?>((ref) {
  final authUser = ref.watch(authStateProvider).valueOrNull;
  if (authUser == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(authUser.uid)
      .snapshots()
      .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
});
