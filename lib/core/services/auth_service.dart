import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ─── Email / Password ───────────────────────────────────────────────────────

  Future<UserModel> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _updateLastLogin(credential.user!.uid);
    final userData = await getUserData(credential.user!.uid);
    return userData!;
  }

  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user!.updateDisplayName(name.trim());
    await _createUserDocument(
      uid: credential.user!.uid,
      email: email.trim(),
      name: name.trim(),
      role: role,
    );
    final userData = await getUserData(credential.user!.uid);
    return userData!;
  }

  // ─── Google Sign-In ─────────────────────────────────────────────────────────

  Future<UserModel?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // user cancelled

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;
    final isNew = userCredential.additionalUserInfo?.isNewUser ?? false;

    if (isNew) {
      await _createUserDocument(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? 'Student',
        role: 'student',
      );
    } else {
      await _updateLastLogin(user.uid);
    }

    return await getUserData(user.uid);
  }

  // ─── Password Reset ──────────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ─── Sign Out ────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ─── Firestore Helpers ───────────────────────────────────────────────────────

  Future<UserModel?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String name,
    required String role,
  }) async {
    final now = DateTime.now();
    await _db.collection('users').doc(uid).set({
      'email': email,
      'name': name,
      'role': role,
      'language': 'en',
      'avatarUrl': null,
      'createdAt': Timestamp.fromDate(now),
      'lastLoginAt': Timestamp.fromDate(now),
    });
  }

  Future<void> _updateLastLogin(String uid) async {
    await _db.collection('users').doc(uid).update({
      'lastLoginAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ─── Firebase Error Messages ─────────────────────────────────────────────────

  static String friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
