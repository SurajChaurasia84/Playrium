import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_coin_counter.dart';
import '../services/firestore_service.dart';
import '../services/admob_service.dart';
import '../theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _leaderboardList = [];
  List<Map<String, dynamic>> _featuredGames = [];
  bool _isLoadingLeaderboard = true;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();

    // Shuffle and pick max 5 games on every screen creation / app open
    final List<Map<String, dynamic>> allGames = [
      {
        'id': 'tap_challenge',
        'name': 'Tap Challenge',
        'gradient': [const Color(0xFF00D1FF), const Color(0xFF00A8FF)],
        'image': 'assets/quiz.png',
      },
      {
        'id': 'reaction_time',
        'name': 'Reaction Time',
        'gradient': [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
        'image': 'assets/streak.png',
      },
      {
        'id': 'memory_match',
        'name': 'Memory Match',
        'gradient': [const Color(0xFF11998E), const Color(0xFF38EF7D)],
        'image': 'assets/memory-match.png',
      },
      {
        'id': 'game_2048',
        'name': '2048 Puzzle',
        'gradient': [const Color(0xFF4568DC), const Color(0xFFB06AB3)],
        'image': 'assets/2048.png',
      },
    ];

    allGames.shuffle();
    _featuredGames = allGames.take(5).toList();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboard() async {
    final list = await _firestoreService.getLeaderboard('target_hit');
    if (mounted) {
      setState(() {
        _leaderboardList = list;
        _isLoadingLeaderboard = false;
      });
    }
  }

  void _claimDailyCheckin() async {
    final notifier = ref.read(userProvider.notifier);
    final success = await notifier.claimTaskReward('daily_checkin');

    if (!mounted) return;

    if (success) {
      // Show snackbar first, then interstitial ad
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 Claimed daily checkin bonus!"),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      AdmobService().showTransitionInterstitial(context, () {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Already claimed today, come back tomorrow!"),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1E2E) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Image.asset(
            'assets/icon.png',
            fit: BoxFit.contain,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "WELCOME BACK,",
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white54 : Colors.black54,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              user.username.toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppTheme.darkBgColor, const Color(0xFF161A26)]
                : [AppTheme.lightBgColor, const Color(0xFFEBEFF8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeController,
          child: RefreshIndicator(
            onRefresh: () async {
              await _loadLeaderboard();
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                // Coin Balance Card
                GlassCard(
                  blur: 16,
                  opacity: isDark ? 0.08 : 0.05,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "CURRENT BALANCE",
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          AnimatedCoinCounter(
                            coins: user.coins,
                            iconSize: 28,
                            textStyle: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppTheme.accentColor : const Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Streak Tracker Card
                GestureDetector(
                  onTap: _claimDailyCheckin,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, Color(0xFF8E2DE2)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "DAILY STREAK: ${user.streak}",
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Tap to claim daily rewards!",
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.flash_on, color: AppTheme.accentColor, size: 18),
                              SizedBox(width: 4),
                              Text(
                                "CLAIM",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Featured Action Items Header with See All button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "FEATURED GAMES",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => context.push('/games-all'),
                      child: const Text(
                        "See All",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Shuffled Horizontal List showing raw image and game name only
                SizedBox(
                  height: 88,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _featuredGames.length,
                    itemBuilder: (context, index) {
                      final game = _featuredGames[index];
                      return GestureDetector(
                        onTap: () => context.go('/games/play/${game['id']}'),
                        child: Container(
                          width: 90,
                          margin: const EdgeInsets.only(right: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                game['image'] as String,
                                width: 56,
                                height: 56,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                game['name'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Leaderboard Preview
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TOP GAMERS",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 18, color: Colors.grey),
                      onPressed: _loadLeaderboard,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                if (_isLoadingLeaderboard)
                  const Center(child: CircularProgressIndicator(strokeWidth: 2))
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _leaderboardList.length.clamp(0, 3),
                    separatorBuilder: (context, index) => Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),
                    itemBuilder: (context, index) {
                      final item = _leaderboardList[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                          child: Text(
                            "#${index + 1}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.secondaryColor),
                          ),
                        ),
                        title: Text(
                          item['username'] ?? 'Anonymous Gamer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        trailing: Text(
                          "${item['score'] ?? 0} pts",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppTheme.secondaryColor : const Color(0xFF0284C7),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
