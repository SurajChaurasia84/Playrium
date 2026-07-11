import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final themeMode = ref.watch(themeModeProvider);
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
                ? [AppTheme.darkBgColor, const Color(0xFF151821)]
                : [AppTheme.lightBgColor, const Color(0xFFEDEFF5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16 + MediaQuery.of(context).padding.top, 20, 100), // extra padding for bottom navigation
          children: [
              // Avatar & Level Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                          backgroundImage: NetworkImage(user.avatarUrl),
                          onBackgroundImageError: (exception, stackTrace) {
                            debugPrint("Failed to load profile image: $exception");
                          },
                          child: const Icon(Icons.person, size: 40, color: Colors.white70),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.secondaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "${user.level}",
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.username,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user.email,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Coin Ledger & Stats
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      blur: 10,
                      opacity: isDark ? 0.05 : 0.03,
                      child: Column(
                        children: [
                          const Text("COINS EARNED", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            "${user.coins}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppTheme.accentColor : const Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GlassCard(
                      blur: 10,
                      opacity: isDark ? 0.05 : 0.03,
                      child: Column(
                        children: [
                          const Text("STREAK SCORE", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("${user.streak} Days", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.secondaryColor)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Achievements rack list
              const Text(
                "ACHIEVEMENT MILestones",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2),
              ),
              const SizedBox(height: 10),
              
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _achievementBadge("First Steps", "Completed Profile Details", Icons.military_tech, user.profileCompleted),
                    _achievementBadge("Streak King", "Achieved 3 days checkin", Icons.workspace_premium, user.streak >= 3),
                    _achievementBadge("Coin Baron", "Acquired 200+ coins", Icons.diamond, user.coins >= 200),
                    _achievementBadge("Gamer Level", "Reached Level 5", Icons.sports_esports, user.level >= 5),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // General preferences options
              const Text(
                "PREFERENCES & SETTINGS",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2),
              ),
              const SizedBox(height: 10),

              GlassCard(
                blur: 10,
                opacity: isDark ? 0.05 : 0.03,
                padding: EdgeInsets.zero,
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // Theme Mode Dropdown
                      ListTile(
                        leading: const Icon(Icons.palette_outlined, color: AppTheme.primaryColor),
                        title: const Text("Theme Layout", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              themeMode == ThemeMode.system
                                  ? "System"
                                  : themeMode == ThemeMode.light
                                      ? "Light"
                                      : "Dark",
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                          ],
                        ),
                        onTap: () {
                          _showThemeSelectionSheet(context, ref, themeMode);
                        },
                      ),
                      Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),
                      
                      // Notification Switches
                      SwitchListTile(
                        secondary: const Icon(Icons.notifications_active_outlined, color: AppTheme.secondaryColor),
                        title: const Text("Alert Push Notifications", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        value: _notificationsEnabled,
                        activeThumbColor: AppTheme.secondaryColor,
                        onChanged: (val) {
                          setState(() {
                            _notificationsEnabled = val;
                          });
                        },
                      ),
                      Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),
  
                      // Log out
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.redAccent),
                        title: const Text("Logout Session", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.redAccent)),
                        onTap: () {
                          _authService.signOut();
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _showThemeSelectionSheet(BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkSurfaceColor : AppTheme.lightSurfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Grabber/Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Choose Theme Mode",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildThemeSheetOption(context, ref, "System Default", ThemeMode.system, currentMode == ThemeMode.system, Icons.brightness_auto_outlined),
              _buildThemeSheetOption(context, ref, "Light Mode", ThemeMode.light, currentMode == ThemeMode.light, Icons.light_mode_outlined),
              _buildThemeSheetOption(context, ref, "Dark Mode", ThemeMode.dark, currentMode == ThemeMode.dark, Icons.dark_mode_outlined),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeSheetOption(BuildContext context, WidgetRef ref, String title, ThemeMode mode, bool isSelected, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primaryColor : (isDark ? Colors.white70 : Colors.black87)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppTheme.primaryColor : (isDark ? Colors.white : Colors.black87),
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.primaryColor) : null,
      onTap: () {
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }

  Widget _achievementBadge(String title, String desc, IconData icon, bool isUnlocked) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: GlassCard(
        blur: 5,
        opacity: isUnlocked ? 0.12 : 0.03,
        padding: const EdgeInsets.all(8),
        border: isUnlocked 
            ? Border.all(color: (isDark ? AppTheme.accentColor : const Color(0xFFD97706)).withValues(alpha: 0.5)) 
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isUnlocked 
                  ? (isDark ? AppTheme.accentColor : const Color(0xFFD97706)) 
                  : Colors.grey.withValues(alpha: 0.4),
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isUnlocked 
                    ? (isDark ? Colors.white : Colors.black87) 
                    : (isDark ? Colors.white30 : Colors.black26),
              ),
            ),
            Text(
              desc,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 8, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
