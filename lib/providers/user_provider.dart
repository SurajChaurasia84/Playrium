import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/api_service.dart';
import '../navigation/app_router.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return UserNotifier(authState.value?.uid);
});

class UserNotifier extends StateNotifier<UserModel?> {
  final String? _uid;
  final FirestoreService _firestoreService = FirestoreService();
  final ApiService _apiService = ApiService();

  UserNotifier(this._uid) : super(null) {
    if (_uid != null) {
      _loadOrCreateUser();
    }
  }

  Future<void> _loadOrCreateUser() async {
    if (_uid == null) return;
    
    // Check Firestore
    var user = await _firestoreService.getUserProfile(_uid);
    if (user == null) {
      // Create a default user profile
      final authUser = AuthService().currentUser;
      user = UserModel(
        uid: _uid,
        username: authUser?.displayName ?? 'Player_${_uid.substring(0, 5)}',
        email: authUser?.email ?? '',
        avatarUrl: authUser?.photoURL ?? 'https://lh3.googleusercontent.com/a/default-user',
        coins: 100, // starting coins bonus
        level: 1,
        xp: 0,
        streak: 1,
        profileCompleted: false,
        hasProfilePhoto: authUser?.photoURL != null,
      );
      await _firestoreService.createUserProfile(user);
    }
    state = user;
  }

  // Update profile attributes (such as complete profile)
  Future<void> completeProfileDetails({required String username, required String avatar}) async {
    if (state == null) return;

    final updated = state!.copyWith(
      username: username,
      avatarUrl: avatar,
      profileCompleted: true,
      hasProfilePhoto: avatar.isNotEmpty,
    );

    state = updated;
    await _firestoreService.createUserProfile(updated);
    
    // Claim coin rewards for complete profile!
    await claimTaskReward('complete_profile');
  }

  // Claim rewards via Secure Node Vercel API
  Future<bool> claimTaskReward(String taskId, [Map<String, dynamic>? details]) async {
    if (state == null) return false;

    try {
      final response = await _apiService.claimTask(taskId, details: details);
      if (response['success'] == true) {
        final rewardCoins = response['reward']?['coins'] as int? ?? 0;
        final rewardXp = response['reward']?['xp'] as int? ?? 0;

        final newCoins = state!.coins + rewardCoins;
        
        // Custom local level-up calculations mirroring backend
        int newXp = state!.xp + rewardXp;
        int newLevel = state!.level;
        while (newXp >= newLevel * 100) {
          newXp -= newLevel * 100;
          newLevel++;
        }

        final updated = state!.copyWith(
          coins: newCoins,
          xp: newXp,
          level: newLevel,
          lastCheckInDate: taskId == 'daily_checkin' ? DateTime.now().toIso8601String().split('T')[0] : state!.lastCheckInDate,
          streak: taskId == 'daily_checkin' ? state!.streak + 1 : state!.streak,
        );

        state = updated;
        await _firestoreService.updateUserProfileLocal(updated); // offline backup
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Claim task error: $e");
      return false;
    }
  }

  // Submit Game scores via Vercel secure API
  Future<Map<String, dynamic>> submitGameScore(String gameId, int score, Map<String, dynamic> telemetry) async {
    if (state == null) return {'success': false, 'error': 'User not authenticated'};

    try {
      final response = await _apiService.submitScore(gameId, score, telemetry);
      if (response['success'] == true) {
        final rewardCoins = response['reward']?['coins'] as int? ?? 0;
        final rewardXp = response['reward']?['xp'] as int? ?? 0;

        final newCoins = state!.coins + rewardCoins;
        
        int newXp = state!.xp + rewardXp;
        int newLevel = state!.level;
        while (newXp >= newLevel * 100) {
          newXp -= newLevel * 100;
          newLevel++;
        }

        final isNewHighScore = response['newHighScore'] as bool? ?? false;

        final updated = state!.copyWith(
          coins: newCoins,
          xp: newXp,
          level: newLevel,
        );

        state = updated;
        await _firestoreService.updateUserProfileLocal(updated);
        
        if (isNewHighScore) {
          await _firestoreService.saveGameStatsLocal(_uid!, gameId, score);
        }

        return {
          'success': true,
          'rewardCoins': rewardCoins,
          'rewardXp': rewardXp,
          'newHighScore': isNewHighScore,
        };
      }
      return {'success': false, 'error': 'Failed score sub'};
    } catch (e) {
      debugPrint("Error submitting score: $e");
      return {'success': false, 'error': e.toString()};
    }
  }

  // Claim ad coins
  Future<bool> claimRewardedAdCoins() async {
    if (state == null) return false;

    try {
      final response = await _apiService.claimAdReward();
      if (response['success'] == true) {
        final rewardCoins = response['reward']?['coins'] as int? ?? 5;
        final rewardXp = response['reward']?['xp'] as int? ?? 10;

        final newCoins = state!.coins + rewardCoins;
        int newXp = state!.xp + rewardXp;
        int newLevel = state!.level;
        while (newXp >= newLevel * 100) {
          newXp -= newLevel * 100;
          newLevel++;
        }

        final updated = state!.copyWith(
          coins: newCoins,
          xp: newXp,
          level: newLevel,
        );

        state = updated;
        await _firestoreService.updateUserProfileLocal(updated);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Ad reward error: $e");
      return false;
    }
  }
}
