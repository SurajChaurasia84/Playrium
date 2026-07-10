import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class ReactionTimeScreen extends StatefulWidget {
  final Function(int score, Map<String, dynamic> telemetry) onGameFinished;

  const ReactionTimeScreen({super.key, required this.onGameFinished});

  @override
  State<ReactionTimeScreen> createState() => _ReactionTimeScreenState();
}

enum GameState { idle, waiting, green, failed, finished }

class _ReactionTimeScreenState extends State<ReactionTimeScreen> {
  GameState _state = GameState.idle;
  Timer? _triggerTimer;
  int _startTime = 0;
  int _reactionTime = 0;
  final Random _random = Random();

  void _startWaiting() {
    setState(() {
      _state = GameState.waiting;
    });

    // Random delay between 2 to 5 seconds
    final delayMs = _random.nextInt(3000) + 2000;
    _triggerTimer = Timer(Duration(milliseconds: delayMs), () {
      if (_state == GameState.waiting) {
        setState(() {
          _state = GameState.green;
          _startTime = DateTime.now().millisecondsSinceEpoch;
        });
      }
    });
  }

  void _screenTapped() {
    if (_state == GameState.waiting) {
      // Tapped too early
      _triggerTimer?.cancel();
      setState(() {
        _state = GameState.failed;
      });
    } else if (_state == GameState.green) {
      final now = DateTime.now().millisecondsSinceEpoch;
      _reactionTime = now - _startTime;
      setState(() {
        _state = GameState.finished;
      });

      // Score calculation: faster reaction = higher score
      // Under 200ms = 100 points, under 300ms = 80 points, etc.
      int score = 0;
      if (_reactionTime < 200) {
        score = 100;
      } else if (_reactionTime < 300) {
        score = 80;
      } else if (_reactionTime < 450) {
        score = 60;
      } else {
        score = 40;
      }

      final telemetry = {
        'reactionTimeMs': _reactionTime,
      };

      widget.onGameFinished(score, telemetry);
    }
  }

  @override
  void dispose() {
    _triggerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bg = AppTheme.darkBgColor;
    String title = "Reaction Time";
    String subtitle = "Test your visual reflexes";
    IconData icon = Icons.timer;
    Color iconColor = AppTheme.secondaryColor;

    if (_state == GameState.waiting) {
      bg = const Color(0xFFC0392B); // Solid warning red
      title = "WAIT FOR GREEN...";
      subtitle = "Do not tap yet!";
      icon = Icons.hourglass_empty;
      iconColor = Colors.white;
    } else if (_state == GameState.green) {
      bg = const Color(0xFF27AE60); // Bright reaction green
      title = "TAP NOW!";
      subtitle = "QUICKLY!";
      icon = Icons.flash_on;
      iconColor = AppTheme.accentColor;
    } else if (_state == GameState.failed) {
      bg = const Color(0xFF7F8C8D);
      title = "Too Early!";
      subtitle = "You must wait for green.";
      icon = Icons.cancel;
      iconColor = Colors.redAccent;
    } else if (_state == GameState.finished) {
      bg = const Color(0xFF1E2230);
      title = "Reflex Completed!";
      subtitle = "Reaction Speed: ${_reactionTime}ms";
      icon = Icons.check_circle;
      iconColor = AppTheme.secondaryColor;
    }

    return GestureDetector(
      onTap: _screenTapped,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: bg,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: GlassCard(
              blur: 10,
              opacity: 0.12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 64, color: iconColor),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  if (_state == GameState.idle || _state == GameState.failed || _state == GameState.finished)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _startWaiting,
                      child: const Text("START TEST", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
