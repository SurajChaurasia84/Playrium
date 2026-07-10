import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class Game2048Screen extends StatefulWidget {
  final Function(int score, Map<String, dynamic> telemetry) onGameFinished;

  const Game2048Screen({super.key, required this.onGameFinished});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  late List<List<int>> _grid;
  int _score = 0;
  int _moves = 0;
  bool _isPlaying = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    _grid = List.generate(4, (_) => List.generate(4, (_) => 0));
    _score = 0;
    _moves = 0;
    _isPlaying = false;
  }

  void _startGame() {
    _resetGame();
    setState(() {
      _isPlaying = true;
      _spawnTile();
      _spawnTile();
    });
  }

  void _spawnTile() {
    List<Point<int>> emptyCells = [];
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        if (_grid[r][c] == 0) {
          emptyCells.add(Point(r, c));
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      final cell = emptyCells[_random.nextInt(emptyCells.length)];
      _grid[cell.x][cell.y] = _random.nextDouble() < 0.9 ? 2 : 4;
    }
  }

  // Merging mechanics

  void _move(int dx, int dy) {
    bool moved = false;
    int pointsEarned = 0;

    // Up: dy = -1, Down: dy = 1, Left: dx = -1, Right: dx = 1
    if (dx != 0) {
      for (int r = 0; r < 4; r++) {
        List<int> line = List.from(_grid[r]);
        if (dx == 1) line = line.reversed.toList();
        
        // Filter out zeros
        List<int> filtered = line.where((val) => val != 0).toList();
        List<int> merged = [];
        
        int i = 0;
        while (i < filtered.length) {
          if (i + 1 < filtered.length && filtered[i] == filtered[i + 1]) {
            merged.add(filtered[i] * 2);
            pointsEarned += filtered[i] * 2;
            i += 2;
            moved = true;
          } else {
            merged.add(filtered[i]);
            i++;
          }
        }
        
        // Pad remaining with zeros
        while (merged.length < 4) {
          merged.add(0);
        }

        if (dx == 1) merged = merged.reversed.toList();

        // Check if actually modified
        for (int c = 0; c < 4; c++) {
          if (_grid[r][c] != merged[c]) moved = true;
          _grid[r][c] = merged[c];
        }
      }
    } else if (dy != 0) {
      for (int c = 0; c < 4; c++) {
        List<int> line = [];
        for (int r = 0; r < 4; r++) {
          line.add(_grid[r][c]);
        }
        if (dy == 1) line = line.reversed.toList();

        List<int> filtered = line.where((val) => val != 0).toList();
        List<int> merged = [];

        int i = 0;
        while (i < filtered.length) {
          if (i + 1 < filtered.length && filtered[i] == filtered[i + 1]) {
            merged.add(filtered[i] * 2);
            pointsEarned += filtered[i] * 2;
            i += 2;
            moved = true;
          } else {
            merged.add(filtered[i]);
            i++;
          }
        }

        while (merged.length < 4) {
          merged.add(0);
        }

        if (dy == 1) merged = merged.reversed.toList();

        for (int r = 0; r < 4; r++) {
          if (_grid[r][c] != merged[r]) moved = true;
          _grid[r][c] = merged[r];
        }
      }
    }

    if (moved) {
      setState(() {
        _score += pointsEarned;
        _moves++;
        _spawnTile();
      });

      if (_isGameOver()) {
        _endGame();
      }
    }
  }

  bool _isGameOver() {
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        if (_grid[r][c] == 0) return false;
        if (r + 1 < 4 && _grid[r][c] == _grid[r + 1][c]) return false;
        if (c + 1 < 4 && _grid[r][c] == _grid[r][c + 1]) return false;
      }
    }
    return true;
  }

  void _endGame() {
    setState(() {
      _isPlaying = false;
    });

    final telemetry = {
      'score': _score,
      'moves': _moves,
    };

    widget.onGameFinished(_score, telemetry);
  }

  Color _getTileColor(int val) {
    switch (val) {
      case 2: return const Color(0xFFEEE4DA);
      case 4: return const Color(0xFFEDE0C8);
      case 8: return const Color(0xFFF2B179);
      case 16: return const Color(0xFFF59563);
      case 32: return const Color(0xFFF67C5F);
      case 64: return const Color(0xFFF65E3B);
      case 128: return const Color(0xFFEDCF72);
      case 256: return const Color(0xFFEDCC61);
      case 512: return const Color(0xFFEDC850);
      case 1024: return const Color(0xFFEDC53F);
      case 2048: return AppTheme.secondaryColor;
      default: return Colors.blueGrey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.darkBgColor, Color(0xFF11131A)],
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
                      "2048 Puzzle",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    _statHeader("SCORE", "$_score"),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Swipeable Game board
                Flexible(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: GestureDetector(
                      onVerticalDragEnd: (details) {
                        final v = details.primaryVelocity ?? 0;
                        if (v > 150) _move(0, 1);  // Down
                        if (v < -150) _move(0, -1); // Up
                      },
                      onHorizontalDragEnd: (details) {
                        final v = details.primaryVelocity ?? 0;
                        if (v > 150) _move(1, 0);  // Right
                        if (v < -150) _move(-1, 0); // Left
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: 16,
                          itemBuilder: (context, index) {
                            final r = index ~/ 4;
                            final c = index % 4;
                            final val = _grid[r][c];
                            return Container(
                              decoration: BoxDecoration(
                                color: val == 0 ? Colors.white.withValues(alpha: 0.04) : _getTileColor(val),
                                borderRadius: BorderRadius.circular(8),
                                border: val == 2048 
                                    ? Border.all(color: AppTheme.accentColor, width: 2) 
                                    : null,
                              ),
                              child: Center(
                                child: val == 0
                                    ? null
                                    : Text(
                                        val.toString(),
                                        style: TextStyle(
                                          color: val <= 4 ? Colors.black87 : Colors.white,
                                          fontSize: val >= 1000 ? 16 : 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                if (!_isPlaying)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _startGame,
                    child: Text(
                      _moves == 0 ? "PLAY 2048" : "REPLAY",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  )
                else
                  const Text(
                    "Swipe UP, DOWN, LEFT or RIGHT inside board to merge tiles",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white30, fontSize: 11),
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
