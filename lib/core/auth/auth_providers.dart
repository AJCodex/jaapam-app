import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'user_profile.dart';

/// Firebase Auth instance.
final firebaseAuthProvider = Provider<FirebaseAuth>((_) => FirebaseAuth.instance);

/// Firestore instance.
final firestoreProvider = Provider<FirebaseFirestore>(
  (_) => FirebaseFirestore.instance,
);

/// Streams Firebase Auth state changes.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// Current signed-in user (sync snapshot of authStateProvider).
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Streams the signed-in user's Firestore profile document.
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snap) {
    if (!snap.exists || snap.data() == null) return null;
    return UserProfile.fromMap(user.uid, snap.data()!);
  });
});

/// True only when the current signed-in user's profile has `isAdmin: true`.
/// Server-side rules enforce the same check; this is purely for UI gating.
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).valueOrNull?.isAdmin ?? false;
});

/// Auth service for sign-in / sign-out / profile writes.
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  ),
);

class AuthService {
  AuthService(this._auth, this._db);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Future<UserCredential> signInWithGoogleWebPopup() async {
    final provider = GoogleAuthProvider()..addScope('email');
    return _auth.signInWithPopup(provider);
  }

  Future<void> sendEmailLink({
    required String email,
    required String continueUrl,
  }) async {
    final settings = ActionCodeSettings(
      url: continueUrl,
      handleCodeInApp: true,
    );
    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: settings,
    );
  }

  Future<UserCredential> completeEmailLinkSignIn({
    required String email,
    required String emailLink,
  }) {
    return _auth.signInWithEmailLink(email: email, emailLink: emailLink);
  }

  bool isEmailLink(String link) => _auth.isSignInWithEmailLink(link);

  Future<void> signOut() => _auth.signOut();

  Future<void> saveProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).set(
          profile.toMap(),
          SetOptions(merge: true),
        );
  }
}
