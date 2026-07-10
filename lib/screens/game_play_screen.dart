import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../providers/user_provider.dart';
import '../games/target_hit_game.dart';
import '../games/tap_challenge.dart';
import '../games/reaction_time.dart';
import '../games/memory_match.dart';
import '../games/color_match.dart';
import '../games/game_2048.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class GamePlayScreen extends ConsumerStatefulWidget {
  final String gameId;

  const GamePlayScreen({super.key, required this.gameId});

  @override
  ConsumerState<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends ConsumerState<GamePlayScreen> {
  bool _submittingScore = false;
  Map<String, dynamic>? _rewardResults;
  String? _errorMessage;

  void _onGameFinished(int score, Map<String, dynamic> telemetry) async {
    setState(() {
      _submittingScore = true;
      _errorMessage = null;
    });

    // Send score to Vercel Backend for verification and credit
    final notifier = ref.read(userProvider.notifier);
    final result = await notifier.submitGameScore(widget.gameId, score, telemetry);

    if (mounted) {
      setState(() {
        _submittingScore = false;
        if (result['success'] == true) {
          _rewardResults = result;
        } else {
          _errorMessage = result['error'] ?? "Anti-cheat validation failed.";
        }
      });
    }
  }

  Widget _buildSelectedGame() {
    switch (widget.gameId) {
      case 'target_hit':
        return TargetHitGameScreen(onGameFinished: _onGameFinished);
      case 'tap_challenge':
        return TapChallengeScreen(onGameFinished: _onGameFinished);
      case 'reaction_time':
        return ReactionTimeScreen(onGameFinished: _onGameFinished);
      case 'memory_match':
        return MemoryMatchScreen(onGameFinished: _onGameFinished);
      case 'color_match':
        return ColorMatchScreen(onGameFinished: _onGameFinished);
      case 'game_2048':
        return Game2048Screen(onGameFinished: _onGameFinished);
      default:
        return const Center(child: Text("Unknown Game ID", style: TextStyle(color: Colors.white)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.gameId.toUpperCase().replaceAll('_', ' ')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_rewardResults != null || _errorMessage != null) {
              Navigator.pop(context);
            } else {
              // Confirm exit dialog
              _showExitConfirmation();
            }
          },
        ),
      ),
      body: Stack(
        children: [
          // The Active Game Frame
          Positioned.fill(
            child: _buildSelectedGame(),
          ),

          // Loading overlay during secure API submission
          if (_submittingScore)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor)),
                    SizedBox(height: 20),
                    Text(
                      "Validating telemetry security checks...",
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),

          // Score / Reward summary overlay
          if (_rewardResults != null)
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: GlassCard(
                      blur: 16,
                      opacity: 0.1,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Lottie Celebration
                          SizedBox(
                            height: 120,
                            child: Lottie.network(
                              'https://assets5.lottiefiles.com/packages/lf20_touoh4ky.json',
                              errorBuilder: (_, _, _) => const Icon(Icons.emoji_events, size: 64, color: AppTheme.accentColor),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "GAME OVER!",
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                          ),
                          const SizedBox(height: 8),
                          if (_rewardResults!['newHighScore'] == true) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.accentColor),
                              ),
                              child: const Text(
                                "NEW HIGHSCORE!",
                                style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _rewardCell("+${_rewardResults!['rewardCoins']} Coins", Icons.monetization_on, AppTheme.accentColor),
                              _rewardCell("+${_rewardResults!['rewardXp']} XP", Icons.offline_bolt, AppTheme.secondaryColor),
                            ],
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("BACK TO LOBBY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Error / Cheating warning overlay
          if (_errorMessage != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.9),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: GlassCard(
                      blur: 16,
                      opacity: 0.1,
                      border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 68, color: Colors.redAccent),
                          const SizedBox(height: 16),
                          const Text(
                            "VALIDATION ERROR",
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("CLOSE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _rewardCell(String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
      ],
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkSurfaceColor,
        title: const Text("Exit Game?", style: TextStyle(color: Colors.white)),
        content: const Text("Any unsaved progress will be lost.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CONTINUE PLAYING", style: TextStyle(color: AppTheme.secondaryColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(this.context); // Close gameplay
            },
            child: const Text("EXIT", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
