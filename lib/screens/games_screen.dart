import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  final List<Map<String, dynamic>> _gamesCatalog = [
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
      'id': 'game_2048',
      'name': '2048 Puzzle',
      'description': 'Slide grid tiles. Merge matching values to reach 2048.',
      'icon': Icons.grid_on,
      'gradient': [const Color(0xFF4568DC), const Color(0xFFB06AB3)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Mini Games",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
            SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + 8),
            // Game selection grid list
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                itemCount: _gamesCatalog.length,
                itemBuilder: (context, index) {
                  final game = _gamesCatalog[index];
                  final gameId = game['id'] as String;
                  final gradient = game['gradient'] as List<Color>;

                  return GestureDetector(
                    onTap: () {
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
                            flex: 5,
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
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    game['name'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    game['description'] as String,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
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
