import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class ColorMatchScreen extends StatefulWidget {
  final Function(int score, Map<String, dynamic> telemetry) onGameFinished;

  const ColorMatchScreen({super.key, required this.onGameFinished});

  @override
  State<ColorMatchScreen> createState() => _ColorMatchScreenState();
}

class _ColorMatchScreenState extends State<ColorMatchScreen> {
  final List<String> _colorNames = ["RED", "BLUE", "GREEN", "YELLOW", "ORANGE", "PURPLE"];
  final List<Color> _colors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purpleAccent
  ];

  late String _displayedText;
  late Color _displayedColor;

  int _score = 0;
  bool _isPlaying = false;
  int _secondsLeft = 15;
  Timer? _timer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _nextColorChallenge();
  }

  void _nextColorChallenge() {
    final textIdx = _random.nextInt(_colorNames.length);
    final colorIdx = _random.nextInt(_colors.length);
    
    // We compare if the meaning of the written word matches the font color
    // E.g. "RED" printed in Blue font does NOT match
    _displayedText = _colorNames[textIdx];
    _displayedColor = _colors[colorIdx];

    // Meaning we want to test:
    // Let's display a prompt like: Does the text match the color?
    // Meaning we compare if textIdx == colorIdx
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _isPlaying = true;
      _secondsLeft = 15;
      _nextColorChallenge();
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

  void _submitAnswer(bool userSaysYes) {
    if (!_isPlaying) return;

    final actualTextIndex = _colorNames.indexOf(_displayedText);
    final actualColorIndex = _colors.indexOf(_displayedColor);
    final isMatching = actualTextIndex == actualColorIndex;

    if (userSaysYes == isMatching) {
      setState(() {
        _score++;
      });
    }

    setState(() {
      _nextColorChallenge();
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
    });

    final telemetry = {
      'score': _score,
      'durationMs': 15000,
    };

    widget.onGameFinished(_score, telemetry);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.darkBgColor, Color(0xFF0F1E23)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: GlassCard(
            blur: 14,
            opacity: 0.08,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.palette, size: 50, color: AppTheme.secondaryColor),
                const SizedBox(height: 12),
                const Text(
                  "Color Stroop Match",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Does the color of the text match the word's meaning?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 24),
                if (_isPlaying) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statWidget("SCORE", "$_score", AppTheme.accentColor),
                      _statWidget("TIME LEFT", "${_secondsLeft}s", Colors.redAccent),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Word Display
                  Container(
                    height: 120,
                    alignment: Alignment.center,
                    child: Text(
                      _displayedText,
                      style: TextStyle(
                        color: _displayedColor,
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Controls
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => _submitAnswer(true),
                          child: const Text("YES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => _submitAnswer(false),
                          child: const Text("NO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  if (_score > 0) ...[
                    Text(
                      "You scored $_score!",
                      style: const TextStyle(color: AppTheme.accentColor, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                  ],
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _startGame,
                    child: Text(
                      _score == 0 ? "START GAME" : "PLAY AGAIN",
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
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
