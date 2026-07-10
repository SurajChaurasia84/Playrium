import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class TapChallengeScreen extends StatefulWidget {
  final Function(int score, Map<String, dynamic> telemetry) onGameFinished;

  const TapChallengeScreen({super.key, required this.onGameFinished});

  @override
  State<TapChallengeScreen> createState() => _TapChallengeScreenState();
}

class _TapChallengeScreenState extends State<TapChallengeScreen> with SingleTickerProviderStateMixin {
  int _taps = 0;
  bool _isPlaying = false;
  int _secondsLeft = 5;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
    );
    _pulseController.value = 1.0;
  }

  void _startGame() {
    setState(() {
      _taps = 0;
      _isPlaying = true;
      _secondsLeft = 5;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsLeft > 1) {
          _secondsLeft--;
        } else {
          _secondsLeft = 0;
          _endGame();
        }
      });
    });
  }

  void _onTap() {
    if (!_isPlaying) return;
    setState(() {
      _taps++;
    });
    _pulseController.forward(from: 0.9);
  }

  void _endGame() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
    });

    // Package telemetry payload
    final telemetry = {
      'tapCount': _taps,
      'durationSeconds': 5,
    };

    widget.onGameFinished(_taps, telemetry);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.darkBgColor, Color(0xFF1E1435)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: GlassCard(
            blur: 16,
            opacity: 0.1,
            color: Colors.white.withOpacity(0.05),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.touch_app, size: 50, color: AppTheme.secondaryColor),
                const SizedBox(height: 12),
                const Text(
                  "Tapping Speed Challenge",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Tap the button as fast as you can. You have 5 seconds!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 24),
                if (_isPlaying) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statWidget("TAPS", "$_taps", AppTheme.secondaryColor),
                      _statWidget("TIME LEFT", "${_secondsLeft}s", Colors.redAccent),
                    ],
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTapDown: (_) => _onTap(),
                    child: ScaleTransition(
                      scale: _pulseController,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.secondaryColor.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "TAP!",
                            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  if (_taps > 0) ...[
                    Text(
                      "You scored $_taps taps!",
                      style: const TextStyle(color: AppTheme.accentColor, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Speed: ${(_taps / 5).toStringAsFixed(1)} taps/sec",
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                  ],
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _startGame,
                    child: Text(
                      _taps == 0 ? "START PLAYING" : "PLAY AGAIN",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statWidget(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
