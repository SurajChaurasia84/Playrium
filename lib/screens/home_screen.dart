import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/xp_progress_ring.dart';
import '../widgets/animated_coin_counter.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _leaderboardList = [];
  bool _isLoadingLeaderboard = true;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
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

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🎉 Claimed 5 Coins & 10 XP daily checkin bonus!"),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Already claimed today, come back tomorrow!"),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
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
          child: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () async {
                await _loadLeaderboard();
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100), // extra padding for nav
                children: [
                  // Animated Greeting & Profile Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "WELCOME BACK,",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white54 : Colors.black45,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.username.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      XpProgressRing(
                        progress: user.xpProgressRatio,
                        level: user.level,
                        size: 58,
                        child: Image.network(
                          user.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppTheme.primaryColor,
                            child: const Icon(Icons.person, color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Coin Balance Card
                  GlassCard(
                    blur: 16,
                    opacity: isDark ? 0.08 : 0.05,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              textStyle: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.accentColor,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "XP PROGRESS: ${(user.xpProgressRatio * 100).toStringAsFixed(0)}%",
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${user.xp} / ${user.xpForNextLevel} XP",
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "DAILY STREAK: ${user.streak} DAYS",
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

                  // Featured Action Items
                  const Text(
                    "FEATURED GAMES",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),
                  
                  // Featured Game Promo Card
                  GestureDetector(
                    onTap: () => context.go('/games/play/target_hit'),
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&w=600&q=80'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Target Hit Component",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              "Flame Engine Shooter Mode. Test coordinate clicks.",
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

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
                    GlassCard(
                      blur: 10,
                      opacity: isDark ? 0.05 : 0.03,
                      padding: EdgeInsets.zero,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _leaderboardList.length.clamp(0, 3),
                        separatorBuilder: (context, index) => Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),
                        itemBuilder: (context, index) {
                          final item = _leaderboardList[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                              child: Text("#${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.secondaryColor)),
                            ),
                            title: Text(
                              item['username'] ?? 'Anonymous Gamer',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            trailing: Text(
                              "${item['score'] ?? 0} pts",
                              style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.secondaryColor),
                            ),
                          );
                        },
                      ),
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
