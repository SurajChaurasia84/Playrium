import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final Map<String, int> _highScores = {};
  bool _loadingScores = true;

  final List<Map<String, dynamic>> _gamesCatalog = [
    {
      'id': 'target_hit',
      'name': 'Target Hit',
      'description': 'Flame Game Engine visual click speed shooter.',
      'icon': Icons.gps_fixed,
      'gradient': [const Color(0xFF6C5CE7), const Color(0xFF8E2DE2)],
    },
    {
      'id': 'tap_challenge',
      'name': 'Tap Challenge',
      'description': 'Click fast button. Test clicking frequency limits.',
      'icon': Icons.touch_app,
      'gradient': [const Color(0xFF00D1FF), const Color(0xFF00A8FF)],
    },
    {
      'id': 'reaction_time',
      'name': 'Reaction Time',
      'description': 'Tap screen instantly when caution warning turns green.',
      'icon': Icons.flash_on,
      'gradient': [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
    },
    {
      'id': 'memory_match',
      'name': 'Memory Match',
      'description': 'Flip and match hidden card symbols. Test memory bounds.',
      'icon': Icons.extension,
      'gradient': [const Color(0xFF11998E), const Color(0xFF38EF7D)],
    },
    {
      'id': 'color_match',
      'name': 'Color Match',
      'description': 'Cognitive word text matching puzzle (Stroop effect).',
      'icon': Icons.palette,
      'gradient': [const Color(0xFFF12711), const Color(0xFFF5AF19)],
    },
    {
      'id': 'game_2048',
      'name': '2048 Puzzle',
      'description': 'Slide grid tiles. Merge matching values to reach 2048.',
      'icon': Icons.grid_on,
      'gradient': [const Color(0xFF4568DC), const Color(0xFFB06AB3)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadHighScores();
  }

  void _loadHighScores() async {
    final user = ref.read(userProvider);
    if (user != null) {
      for (var game in _gamesCatalog) {
        final id = game['id'] as String;
        final score = await _firestoreService.getGameHighScoreLocal(user.uid, id);
        _highScores[id] = score;
      }
    }
    if (mounted) {
      setState(() {
        _loadingScores = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppTheme.darkBgColor, const Color(0xFF12141C)]
                : [AppTheme.lightBgColor, const Color(0xFFECEFF6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16 + MediaQuery.of(context).padding.top, 20, 8),
              child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PLAY AND EARN",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5),
                    ),
                    Text(
                      "ARCADE LOBBY",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // Game selection grid list
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _gamesCatalog.length,
                  itemBuilder: (context, index) {
                    final game = _gamesCatalog[index];
                    final gameId = game['id'] as String;
                    final gradient = game['gradient'] as List<Color>;
                    final highscore = _highScores[gameId] ?? 0;

                    return GestureDetector(
                      onTap: () {
                        // Navigate to selected gameplay screen
                        context.go('/games/play/$gameId');
                      },
                      child: GlassCard(
                        blur: 10,
                        opacity: isDark ? 0.05 : 0.03,
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Icon Gradient Cap
                            Expanded(
                              flex: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: gradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                child: Center(
                                  child: Icon(game['icon'] as IconData, color: Colors.white, size: 36),
                                ),
                              ),
                            ),
                            // Details Block
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          game['name'] as String,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          game['description'] as String,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "HIGHSCORE:",
                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                                        ),
                                        Text(
                                          _loadingScores ? "..." : "$highscore",
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.secondaryColor),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
  }
}
