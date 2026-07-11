import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppTheme.darkBgColor, const Color(0xFF151821)]
                : [AppTheme.lightBgColor, const Color(0xFFEDEFF5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black87),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "APP INFORMATION",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  children: [
                    // App Logo Mock
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.sports_esports_outlined,
                              size: 64,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Playrium",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                          const Text(
                            "Version 1.0.0 (Build 1)",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // App Description
                    GlassCard(
                      blur: 10,
                      opacity: isDark ? 0.05 : 0.03,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ABOUT PLAYRIUM",
                            style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Playrium is a premium, reward-based gaming platform that brings fun quizzes, interactive minigames, and developer support together in a single polished application.",
                            style: TextStyle(fontSize: 13, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Detailed metadata list
                    GlassCard(
                      blur: 10,
                      opacity: isDark ? 0.05 : 0.03,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _buildInfoRow(context, "Developer team", "Playrium Studios"),
                          Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),
                          _buildInfoRow(context, "Released date", "July 2026"),
                          Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),
                          _buildInfoRow(context, "Supported SDKs", "Flutter 3.x / Firebase"),
                          Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),
                          _buildInfoRow(context, "Category", "Rewarded Arcade & Quiz"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String key, String val) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          Text(
            val,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
