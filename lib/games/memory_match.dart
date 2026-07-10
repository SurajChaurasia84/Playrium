import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class MemoryMatchScreen extends StatefulWidget {
  final Function(int score, Map<String, dynamic> telemetry) onGameFinished;

  const MemoryMatchScreen({super.key, required this.onGameFinished});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  final List<IconData> _icons = [
    Icons.gamepad, Icons.gamepad,
    Icons.rocket_launch, Icons.rocket_launch,
    Icons.military_tech, Icons.military_tech,
    Icons.ac_unit, Icons.ac_unit,
    Icons.emoji_events, Icons.emoji_events,
    Icons.anchor, Icons.anchor,
    Icons.offline_bolt, Icons.offline_bolt,
    Icons.palette, Icons.palette,
  ];

  late List<bool> _cardFlipped;
  late List<bool> _cardMatched;
  List<int> _selectedIndices = [];
  int _moves = 0;
  int _matchedPairs = 0;
  bool _isPlaying = false;
  int _elapsedMs = 0;
  Timer? _timer;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    _icons.shuffle();
    _cardFlipped = List.generate(16, (_) => false);
    _cardMatched = List.generate(16, (_) => false);
    _selectedIndices.clear();
    _moves = 0;
    _matchedPairs = 0;
    _isPlaying = false;
    _elapsedMs = 0;
    _timer?.cancel();
  }

  void _startGame() {
    _resetGame();
    setState(() {
      _isPlaying = true;
      _startTime = DateTime.now();
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _elapsedMs = DateTime.now().difference(_startTime).inMilliseconds;
        });
      }
    });
  }

  void _onCardTap(int index) {
    if (!_isPlaying) return;
    if (_cardFlipped[index] || _cardMatched[index]) return;
    if (_selectedIndices.length >= 2) return;

    setState(() {
      _cardFlipped[index] = true;
      _selectedIndices.add(index);
    });

    if (_selectedIndices.length == 2) {
      _moves++;
      final idx1 = _selectedIndices[0];
      final idx2 = _selectedIndices[1];

      if (_icons[idx1] == _icons[idx2]) {
        // Match found!
        setState(() {
          _cardMatched[idx1] = true;
          _cardMatched[idx2] = true;
          _matchedPairs++;
          _selectedIndices.clear();
        });

        if (_matchedPairs == 8) {
          _endGame();
        }
      } else {
        // Not a match: flip back after delay
        Timer(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              _cardFlipped[idx1] = false;
              _cardFlipped[idx2] = false;
              _selectedIndices.clear();
            });
          }
        });
      }
    }
  }

  void _endGame() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
    });

    // Score: 100 points baseline, minus 2 points per extra move over 12 moves, min 30
    int score = (100 - (_moves - 8) * 3).clamp(30, 100);

    final telemetry = {
      'durationMs': _elapsedMs,
      'moves': _moves,
      'matchedPairs': _matchedPairs,
    };

    widget.onGameFinished(score, telemetry);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double timeSeconds = _elapsedMs / 1000.0;
    
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.darkBgColor, Color(0xFF0F2027)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: GlassCard(
            blur: 14,
            opacity: 0.08,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statHeader("MOVES", "$_moves"),
                    const Text(
                      "Memory Match",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    _statHeader("TIME", "${timeSeconds.toStringAsFixed(1)}s"),
                  ],
                ),
                const SizedBox(height: 16),
                
                // The Grid of cards
                Flexible(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 16,
                      itemBuilder: (context, index) {
                        final isFlipped = _cardFlipped[index] || _cardMatched[index];
                        return GestureDetector(
                          onTap: () => _onCardTap(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: isFlipped ? AppTheme.darkSurfaceColor : AppTheme.primaryColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isFlipped ? AppTheme.secondaryColor.withOpacity(0.5) : Colors.white24,
                                width: 1.5,
                              ),
                              boxShadow: [
                                if (!isFlipped)
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: Center(
                              child: isFlipped
                                  ? Icon(
                                      _icons[index],
                                      color: _cardMatched[index] ? AppTheme.accentColor : Colors.white,
                                      size: 28,
                                    )
                                  : const Icon(
                                      Icons.help_outline,
                                      color: Colors.white70,
                                      size: 24,
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                if (!_isPlaying)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _startGame,
                    child: Text(
                      _moves == 0 ? "PLAY GAME" : "REPLAY",
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  )
                else
                  Text(
                    "Matches: $_matchedPairs / 8",
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statHeader(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
