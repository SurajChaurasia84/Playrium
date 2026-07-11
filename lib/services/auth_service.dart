import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  bool get isFirebaseAvailable => true;

  // Stream of User Auth state
  Stream<User?> get authStateChanges {
    return FirebaseAuth.instance.authStateChanges();
  }

  User? get currentUser {
    return FirebaseAuth.instance.currentUser;
  }

  Future<String?> getIdToken() async {
    if (FirebaseAuth.instance.currentUser != null) {
      return await FirebaseAuth.instance.currentUser!.getIdToken();
    }
    return null;
  }

  // Google Sign-In logic
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      debugPrint("Error during Google Sign In: $e");
      rethrow;
    }
  }

  // Anonymous Sign-In (Guest Skip)
  Future<User?> signInAnonymously() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      debugPrint("Error during Anonymous Sign In: $e");
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }
}
