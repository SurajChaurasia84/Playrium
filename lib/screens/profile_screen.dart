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
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100), // extra padding for bottom navigation
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
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                          backgroundImage: NetworkImage(user.avatarUrl),
                          onForegroundImageError: (exception, stackTrace) => const Icon(Icons.person, size: 40),
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
                          Text("${user.coins}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.accentColor)),
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
                child: Column(
                  children: [
                    // Theme Mode Dropdown
                    ListTile(
                      leading: const Icon(Icons.palette_outlined, color: AppTheme.primaryColor),
                      title: const Text("Theme Layout", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      trailing: DropdownButton<ThemeMode>(
                        value: themeMode,
                        underline: const SizedBox(),
                        onChanged: (mode) {
                          if (mode != null) {
                            ref.read(themeModeProvider.notifier).setThemeMode(mode);
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: ThemeMode.system, child: Text("System", style: TextStyle(fontSize: 13))),
                          DropdownMenuItem(value: ThemeMode.light, child: Text("Light Theme", style: TextStyle(fontSize: 13))),
                          DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark Theme", style: TextStyle(fontSize: 13))),
                        ],
                      ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _achievementBadge(String title, String desc, IconData icon, bool isUnlocked) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: GlassCard(
        blur: 5,
        opacity: isUnlocked ? 0.12 : 0.03,
        padding: const EdgeInsets.all(8),
        border: isUnlocked ? Border.all(color: AppTheme.accentColor.withOpacity(0.5)) : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isUnlocked ? AppTheme.accentColor : Colors.grey.withOpacity(0.4),
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
                color: isUnlocked ? Colors.white : Colors.white30,
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
