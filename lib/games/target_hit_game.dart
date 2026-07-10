import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TargetHitGameScreen extends StatefulWidget {
  final Function(int score, Map<String, dynamic> telemetry) onGameFinished;

  const TargetHitGameScreen({super.key, required this.onGameFinished});

  @override
  State<TargetHitGameScreen> createState() => _TargetHitGameScreenState();
}

class _TargetHitGameScreenState extends State<TargetHitGameScreen> {
  late TargetHitFlameGame _game;
  bool _isPlaying = false;
  bool _isFinished = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _game = TargetHitFlameGame(
      onScoreUpdated: (newScore) {
        setState(() {
          _score = newScore;
        });
      },
      onGameEnded: (score, telemetry) {
        setState(() {
          _isFinished = true;
          _isPlaying = false;
        });
        widget.onGameFinished(score, telemetry);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBgColor,
      body: Stack(
        children: [
          // The Flame Game Widget
          if (_isPlaying)
            Positioned.fill(
              child: GameWidget(game: _game),
            ),

          // Intro UI overlay
          if (!_isPlaying && !_isFinished)
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurfaceColor.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.gps_fixed, size: 64, color: AppTheme.secondaryColor),
                    const SizedBox(height: 16),
                    const Text(
                      "Target Hit",
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Rapidly tap target dots as they appear. Smaller targets are worth more points! Game runs for 15 seconds.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPlaying = true;
                        });
                        _game.startGame();
                      },
                      child: const Text("START MISSION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),

          // Stats HUD at top
          if (_isPlaying)
            Positioned(
              top: 48,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      "SCORE: $_score",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: _game.timeLeftNotifier,
                    builder: (context, timeLeft, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                        ),
                        child: Text(
                          "TIME: ${timeLeft}s",
                          style: TextStyle(
                            color: timeLeft <= 5 ? Colors.redAccent : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Flame Game Engine Implementation
class TargetHitFlameGame extends FlameGame with HasPerformanceTracker, TapCallbacks {
  final Function(int) onScoreUpdated;
  final Function(int, Map<String, dynamic>) onGameEnded;

  TargetHitFlameGame({required this.onScoreUpdated, required this.onGameEnded});

  int score = 0;
  final timeLeftNotifier = ValueNotifier<int>(15);
  late Timer _gameTimer;
  late Timer _spawnTimer;
  final List<double> _hitIntervalTelemetry = [];
  final List<Map<String, dynamic>> _hitsDetail = [];
  int _lastHitTime = 0;
  final Random _random = Random();
  bool _isGameRunning = false;

  void startGame() {
    _isGameRunning = true;
    score = 0;
    _hitIntervalTelemetry.clear();
    _hitsDetail.clear();
    _lastHitTime = DateTime.now().millisecondsSinceEpoch;
    timeLeftNotifier.value = 15;

    // Game end timer
    _gameTimer = Timer(1.0, repeat: true, onTick: () {
      if (timeLeftNotifier.value > 0) {
        timeLeftNotifier.value--;
        if (timeLeftNotifier.value == 0) {
          endGame();
        }
      }
    });

    // Spawning targets timer
    _spawnTimer = Timer(0.55, repeat: true, onTick: () {
      if (_isGameRunning) {
        _spawnTarget();
      }
    });
  }

  void _spawnTarget() {
    final size = canvasSize;
    if (size.x == 0 || size.y == 0) return;

    // Random coordinates keeping margins
    final radius = _random.nextDouble() * 20 + 15; // 15 to 35 radius
    final x = _random.nextDouble() * (size.x - radius * 2) + radius;
    final y = _random.nextDouble() * (size.y - radius * 4) + radius * 2; // Keep away from top HUD

    final color = _random.nextBool() ? AppTheme.secondaryColor : AppTheme.accentColor;

    add(
      TargetComponent(
        position: Vector2(x, y),
        radius: radius,
        color: color,
        onTap: (targetRadius) {
          _registerHit(targetRadius);
        },
      ),
    );
  }

  void _registerHit(double targetRadius) {
    if (!_isGameRunning) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final interval = now - _lastHitTime;
    _lastHitTime = now;

    // Small targets give more score
    int pointsEarned = 10;
    if (targetRadius < 20) {
      pointsEarned = 25;
    } else if (targetRadius < 28) {
      pointsEarned = 15;
    }

    score += pointsEarned;
    onScoreUpdated(score);

    // Save telemetry logs for backend verification
    _hitIntervalTelemetry.add(interval.toDouble());
    _hitsDetail.add({
      'timestamp': now,
      'intervalMs': interval,
      'radius': targetRadius,
      'points': pointsEarned
    });
  }

  void endGame() {
    _isGameRunning = false;
    _gameTimer.stop();
    _spawnTimer.stop();
    
    // Remove all remaining targets
    children.whereType<TargetComponent>().forEach((target) => target.removeFromParent());

    // Payload telemetry
    final telemetry = {
      'score': score,
      'durationMs': 15000,
      'hitsCount': _hitsDetail.length,
      'hits': _hitIntervalTelemetry,
      'detailedHits': _hitsDetail,
    };

    onGameEnded(score, telemetry);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isGameRunning) {
      _gameTimer.update(dt);
      _spawnTimer.update(dt);
    }
  }
}

// Flame Component for the Tappable Target
class TargetComponent extends CircleComponent with TapCallbacks {
  final Function(double) onTap;
  final Color color;
  double lifeTime = 0.0;
  final double maxLifeTime = 1.1; // Targets disappear after 1.1 seconds if not tapped

  TargetComponent({
    required Vector2 position,
    required double radius,
    required this.color,
    required this.onTap,
  }) : super(
          position: position,
          radius: radius,
          anchor: Anchor.center,
        );

  @override
  void onMount() {
    super.onMount();
    paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4); // Glowing effect
  }

  @override
  void update(double dt) {
    super.update(dt);
    lifeTime += dt;
    // Shrink target over time as an indicator of disappearing
    scale = Vector2.all(1.0 - (lifeTime / maxLifeTime).clamp(0.0, 1.0));
    
    if (lifeTime >= maxLifeTime) {
      removeFromParent();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap(radius);
    removeFromParent();
  }
}
mixin HasPerformanceTracker on FlameGame {}
