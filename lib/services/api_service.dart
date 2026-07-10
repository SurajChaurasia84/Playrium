import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  final AuthService _authService = AuthService();

  // URL config. If running on Android emulator, use 10.0.2.2. If on web/iOS, use localhost.
  // In production, change to your Vercel deployment URL (e.g. https://playrium.vercel.app)
  static const String _baseUrlDev = kIsWeb 
      ? 'http://localhost:3000' 
      : 'http://10.0.2.2:3000'; // Loopback address for android emulator
  static const String _baseUrlProd = 'https://playrium-backend-placeholder.vercel.app';

  String get baseUrl => kDebugMode ? _baseUrlDev : _baseUrlProd;

  // Post helper with token insertion
  Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> body) async {
    final token = await _authService.getIdToken();
    final url = Uri.parse('$baseUrl$endpoint');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        final errBody = jsonDecode(response.body);
        throw Exception(errBody['error'] ?? 'Server error ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("API Service direct connection to $url failed: $e. Falling back to local simulation...");
      // Re-throw if in production, but in development, simulate the backend's rewards logic!
      if (kReleaseMode) {
        rethrow;
      }
      return _simulateBackendResponse(endpoint, body);
    }
  }

  Future<Map<String, dynamic>> claimTask(String taskId, {Map<String, dynamic>? details}) async {
    final Map<String, dynamic> body = {
      'taskId': taskId,
    };
    if (details != null) {
      body['details'] = details;
    }
    return await _post('/api/rewards/claim-task', body);
  }

  // Submit mini-game score
  Future<Map<String, dynamic>> submitScore(String gameId, int score, Map<String, dynamic> telemetry) async {
    return await _post('/api/rewards/submit-score', {
      'gameId': gameId,
      'score': score,
      'telemetry': telemetry,
    });
  }

  // Claim optional rewarded ad coin
  Future<Map<String, dynamic>> claimAdReward() async {
    return await _post('/api/rewards/claim-ad', {});
  }

  // Simulated backend response for seamless offline/disconnected testing
  Map<String, dynamic> _simulateBackendResponse(String endpoint, Map<String, dynamic> body) {
    if (endpoint.contains('claim-task')) {
      final taskId = body['taskId'];
      int coins = 10;
      if (taskId == 'daily_checkin') coins = 5;
      if (taskId == 'daily_streak') coins = 10;
      if (taskId == 'complete_profile') coins = 20;
      if (taskId == 'take_quiz') coins = 15;
      if (taskId == 'quiz_80_percent') coins = 25;
      if (taskId == 'weekly_challenge') coins = 100;
      if (taskId == 'invite_user') coins = 50;

      return {
        'success': true,
        'reward': {'coins': coins, 'xp': coins * 2},
        'message': '[Client Simulation] Successfully claimed task: $taskId',
      };
    } else if (endpoint.contains('submit-score')) {
      final gameId = body['gameId'];
      final score = body['score'] as int;
      
      // Basic anti-cheat simulation on client
      if (gameId == 'reaction_time') {
        final reaction = body['telemetry']?['reactionTimeMs'] ?? 300;
        if (reaction < 120) {
          return {
            'success': false,
            'error': 'Security check failed: Suspicious gameplay telemetry detected (reaction too fast)',
            'code': 'ANTI_CHEAT_TRIGGERED'
          };
        }
      }

      int coins = (score / 10).floor().clamp(1, 15);
      return {
        'success': true,
        'reward': {'coins': coins, 'xp': coins * 2},
        'newHighScore': true,
        'message': '[Client Simulation] Score registered for game: $gameId'
      };
    } else if (endpoint.contains('claim-ad')) {
      return {
        'success': true,
        'reward': {'coins': 5, 'xp': 10},
        'adsWatchedToday': 1,
        'message': '[Client Simulation] Ad reward credited.'
      };
    }

    return {'success': false, 'error': 'Unknown simulated route'};
  }
}
