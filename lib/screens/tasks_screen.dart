import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';
import '../services/admob_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final AdmobService _admobService = AdmobService();
  int _adsWatchedToday = 0; // Simple local state tracker for visual limit checking
  bool _loadingAd = false;

  void _watchRewardedAd() {
    if (_adsWatchedToday >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You have reached your daily rewarded ad limit (5/day). Try again tomorrow!"),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    _admobService.showOptionalRewardedAd(
      context,
      onRewardEarned: () async {
        final success = await ref.read(userProvider.notifier).claimRewardedAdCoins();
        if (mounted && success) {
          setState(() {
            _adsWatchedToday++;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("🎉 Claimed 5 Coins ad viewing bonus!"),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        }
      },
      onClosed: () {},
      onLoadingStart: () {
        if (mounted) {
          setState(() {
            _loadingAd = true;
          });
        }
      },
      onLoadingEnd: () {
        if (mounted) {
          setState(() {
            _loadingAd = false;
          });
        }
      },
    );
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

    // List of tasks matching standard rewards schema
    final tasksList = [
      _TaskItem(
        id: 'daily_checkin',
        title: 'Daily Check-in',
        description: 'Log in and claim your daily reward.',
        rewardCoins: 5,
        icon: Icons.calendar_today,
        isCompleted: user.lastCheckInDate == DateTime.now().toIso8601String().split('T')[0],
        onAction: () async {
          final success = await ref.read(userProvider.notifier).claimTaskReward('daily_checkin');
          if (context.mounted) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Claimed daily checkin!"), backgroundColor: AppTheme.primaryColor),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Already claimed today."), backgroundColor: Colors.orangeAccent),
              );
            }
          }
        },
        actionLabel: 'CLAIM',
      ),
      _TaskItem(
        id: 'take_quiz',
        title: 'Take Quiz',
        description: 'Answer trivia questions to earn rewards.',
        rewardCoins: 15,
        icon: Icons.quiz_outlined,
        isCompleted: false,
        onAction: () => context.go('/tasks/quiz'),
        actionLabel: 'PLAY QUIZ',
      ),
      _TaskItem(
        id: 'rewarded_ad',
        title: 'Watch Optional Ad',
        description: 'Watch video (Max 5/day).',
        rewardCoins: 5,
        icon: Icons.ondemand_video_outlined,
        isCompleted: _adsWatchedToday >= 5,
        onAction: _watchRewardedAd,
        actionLabel: 'WATCH ($_adsWatchedToday/5)',
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppTheme.darkBgColor, const Color(0xFF13111C)]
                    : [AppTheme.lightBgColor, const Color(0xFFECEEF5)],
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
                      "QUEST ZONE",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5),
                    ),
                    Text(
                      "TASKS & MISSION BOARD",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              // Tasks list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: tasksList.length,
                  itemBuilder: (context, index) {
                    final task = tasksList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GlassCard(
                        blur: 10,
                        opacity: isDark ? 0.05 : 0.04,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(task.icon, color: AppTheme.secondaryColor, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    task.description,
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.monetization_on, color: AppTheme.accentColor, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        "+${task.rewardCoins} Coins",
                                        style: const TextStyle(color: AppTheme.accentColor, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (task.isCompleted)
                              const Icon(Icons.check_circle, color: Colors.greenAccent, size: 28)
                            else
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  minimumSize: const Size(60, 36),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                onPressed: task.onAction,
                                child: Text(
                                  task.actionLabel,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              )
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
          if (_loadingAd)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.75),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor)),
                      SizedBox(height: 16),
                      Text(
                        "Loading Ad...",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

}

class _TaskItem {
  final String id;
  final String title;
  final String description;
  final int rewardCoins;
  final IconData icon;
  final bool isCompleted;
  final VoidCallback onAction;
  final String actionLabel;

  _TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardCoins,
    required this.icon,
    required this.isCompleted,
    required this.onAction,
    required this.actionLabel,
  });
}
