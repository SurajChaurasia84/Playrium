import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../navigation/app_router.dart';
import 'package:share_plus/share_plus.dart';
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
              // Avatar Section
              Center(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(46),
                      child: Container(
                        width: 92,
                        height: 92,
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        child: user.avatarUrl.isNotEmpty
                            ? Image.network(
                                user.avatarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white70,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white70,
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.username,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    if (user.uid != 'offline_guest') ...[
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
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
                        title: const Text("Theme", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
                      // App Info
                      ListTile(
                        leading: const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                        title: const Text("App Info", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                        onTap: () => context.push('/profile/info'),
                      ),
                      Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),

                      // Share App
                      ListTile(
                        leading: const Icon(Icons.share_outlined, color: AppTheme.primaryColor),
                        title: const Text("Share App", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                        onTap: () async {
                          try {
                            await SharePlus.instance.share(
                              ShareParams(
                                text: "Hey! Check out Playrium - a premium rewarded arcade and quiz gaming app. Download now on Google Play Store: https://play.google.com/store/apps/details?id=com.playrium.tasks.app",
                                subject: "Playrium App",
                              ),
                            );
                          } catch (e) {
                            debugPrint("Error sharing: $e");
                          }
                        },
                      ),
                      Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),

                      // Help & Support (direct open email with subject)
                      ListTile(
                        leading: const Icon(Icons.help_outline, color: AppTheme.primaryColor),
                        title: const Text("Help & Support", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                        onTap: () async {
                          final Uri emailUri = Uri(
                            scheme: 'mailto',
                            path: 'contact.appsinfo@gmail.com',
                            query: 'subject=Playrium Help & Support Inquiry',
                          );
                          try {
                            if (await canLaunchUrl(emailUri)) {
                              await launchUrl(emailUri);
                            } else {
                              throw 'Could not launch $emailUri';
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Could not open email. mailto: contact.appsinfo@gmail.com"),
                                  backgroundColor: Colors.orangeAccent,
                                ),
                              );
                            }
                          }
                        },
                      ),
                      Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),

                      // Privacy Policy (direct open dummy link)
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined, color: AppTheme.primaryColor),
                        title: const Text("Privacy Policy", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                        onTap: () async {
                          final Uri url = Uri.parse("https://playrium.com/privacy-policy");
                          try {
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } else {
                              throw 'Could not launch $url';
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Could not open privacy policy link."),
                                  backgroundColor: Colors.orangeAccent,
                                ),
                              );
                            }
                          }
                        },
                      ),
                      Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),
  
                      // Log out
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.redAccent),
                        title: const Text("Logout", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.redAccent)),
                        onTap: () {
                          ref.read(isGuestModeProvider.notifier).setGuestMode(false);
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


}
