import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

import '../widgets/banner_ad_widget.dart';

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdWidget(),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.black.withValues(alpha: 0.6) 
                  : Colors.white.withValues(alpha: 0.8),
              border: Border(
                top: BorderSide(
                  color: isDark 
                      ? Colors.white.withValues(alpha: 0.08) 
                      : Colors.black.withValues(alpha: 0.06),
                  width: 1.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 58,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(context, 0, Icons.home_filled, "Home"),
                    _buildNavItem(context, 1, Icons.assignment_outlined, "Tasks"),
                    _buildNavItem(context, 2, Icons.sports_esports, "Games"),
                    _buildNavItem(context, 3, Icons.person, "You"),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  ),
);
}

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final isSelected = index == navigationShell.currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected 
        ? AppTheme.secondaryColor 
        : (isDark ? Colors.white38 : Colors.black38);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(context, index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 58,
          child: Column(
            children: [
              // Top indicator drop line
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                width: 36,
                height: 3,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.secondaryColor : Colors.transparent,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
                ),
              ),
              const Spacer(),
              // Tab Icon
              Icon(
                icon,
                color: color,
                size: 26,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
