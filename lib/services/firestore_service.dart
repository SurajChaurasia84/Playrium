import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class FirestoreService {
  bool get isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    if (!isFirebaseAvailable) {
      debugPrint("[MOCK FIRESTORE] Fetching mock user profile from SharedPreferences...");
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('mock_user_profile_$uid');
      if (userJson != null) {
        return UserModel.fromMap(jsonDecode(userJson));
      }
      return null;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching user profile from Firestore: $e");
      return null;
    }
  }

  // Create user profile
  Future<void> createUserProfile(UserModel user) async {
    if (!isFirebaseAvailable) {
      debugPrint("[MOCK FIRESTORE] Saving mock user profile to SharedPreferences...");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mock_user_profile_${user.uid}', jsonEncode(user.toMap()));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error creating user profile in Firestore: $e");
    }
  }

  // Update user profile directly (local update helper)
  Future<void> updateUserProfileLocal(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mock_user_profile_${user.uid}', jsonEncode(user.toMap()));
  }

  // Fetch Game Leaderboard
  Future<List<Map<String, dynamic>>> getLeaderboard(String gameId) async {
    if (!isFirebaseAvailable) {
      // Return simulated global leaderboard
      return [
        {'username': 'SpeedRunnerX', 'score': 450, 'avatarUrl': ''},
        {'username': 'RetroGamer', 'score': 380, 'avatarUrl': ''},
        {'username': 'PixelHero', 'score': 310, 'avatarUrl': ''},
        {'username': 'TapperGod', 'score': 290, 'avatarUrl': ''},
        {'username': 'MemoryMaster', 'score': 250, 'avatarUrl': ''},
      ];
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('leaderboards')
          .where('gameId', isEqualTo: gameId)
          .orderBy('score', descending: true)
          .limit(10)
          .get();

      return snap.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint("Error getting leaderboard: $e");
      return [];
    }
  }

  // Save Game Stats locally (for offline backup)
  Future<void> saveGameStatsLocal(String uid, String gameId, int highScore) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mock_game_highscore_${uid}_$gameId', highScore);
  }

  Future<int> getGameHighScoreLocal(String uid, String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('mock_game_highscore_${uid}_$gameId') ?? 0;
  }
}
