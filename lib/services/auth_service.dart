import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  bool get isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // Stream of User Auth state
  Stream<User?> get authStateChanges {
    if (isFirebaseAvailable) {
      return FirebaseAuth.instance.authStateChanges();
    } else {
      // Mock auth states stream
      return _mockAuthStreamController.stream;
    }
  }

  // Mock Stream Controller for dev testing
  static final StreamController<User?> _mockAuthStreamController = StreamController<User?>.broadcast();
  static User? _currentMockUser;

  User? get currentUser {
    if (isFirebaseAvailable) {
      return FirebaseAuth.instance.currentUser;
    }
    return _currentMockUser;
  }

  Future<String?> getIdToken() async {
    if (isFirebaseAvailable && FirebaseAuth.instance.currentUser != null) {
      return await FirebaseAuth.instance.currentUser!.getIdToken();
    }
    return "mock_developer_id_token_123";
  }

  // Google Sign-In logic
  Future<User?> signInWithGoogle() async {
    if (!isFirebaseAvailable) {
      debugPrint("[MOCK AUTH] Simulating Google Sign-in...");
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // We will create a class that implements User since User cannot be instantiated directly
      // However, we can just return a Mock User instance or mock object, but since the types in Dart are strict,
      // let's return a simulated logged-in state inside our state notifier or mock user manager.
      // For GoRouter, let's push a custom mock user state.
      // Since FirebaseAuth's User is an abstract class, we can mock it by setting a flag or using a wrapper.
      // But wait! If we return a simulated Firebase User, we can't easily instantiate a real User object.
      // Instead, we can write a wrapper, or we can use custom Auth states that represent either a FireUser or a MockUser.
      // Let's create a custom UserSession object or just trigger a mock event on our stream if FirebaseAuth is not available.
      // Wait, a better way is to use a mock user proxy or define a MockUser class if we can.
      // But standard Firebase Auth User is sealed/abstract.
      // Let's mock a User object by setting static fields or using a custom proxy that satisfies the Router!
      // In Dart, since User is abstract, we can implement it in a custom class!
      // Yes! we can write `class MockUser implements User { ... }` implementing all members, or just the ones needed like uid, email, displayName, photoURL.
      // But implementing all members of User requires overriding a huge list of properties.
      // Let's write a compact MockUser class implementing only the core properties, throwing UnimplementedError for others.
      // That works perfectly!
      _currentMockUser = MockUser(
        uid: 'mock_uid_123',
        email: 'tester@playrium.com',
        displayName: 'Playrium Gamer',
        photoURL: 'https://lh3.googleusercontent.com/a/default-user',
      );
      _mockAuthStreamController.add(_currentMockUser);
      return _currentMockUser;
    }

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

  // Sign out
  Future<void> signOut() async {
    if (!isFirebaseAvailable) {
      _currentMockUser = null;
      _mockAuthStreamController.add(null);
      return;
    }
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }
}

// Compact MockUser to satisfy Riverpod authStateChanges stream in mock mode
class MockUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final String? photoURL;

  MockUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
  });

  @override
  bool get emailVerified => true;

  @override
  bool get isAnonymous => false;

  @override
  List<UserInfo> get providerData => [];

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async => "mock_developer_id_token_123";

  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) => throw UnimplementedError();

  @override
  Future<void> reload() async {}

  @override
  Future<void> delete() => throw UnimplementedError();

  // Dynamic dispatch fallbacks for missing overrides to satisfy compilation
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
