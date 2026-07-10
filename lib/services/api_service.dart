import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class ApiService {
  final AuthService _authService = AuthService();

  static const String _baseUrlProd = 'https://backend-ruddy-chi-21.vercel.app';

  String get baseUrl => _baseUrlProd;

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
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        final errBody = jsonDecode(response.body);
        throw Exception(errBody['error'] ?? 'Server error ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("API Service direct connection to $url failed: $e.");
      rethrow;
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
}
