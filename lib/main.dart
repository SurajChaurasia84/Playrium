import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'navigation/app_router.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'services/admob_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();
  debugPrint("Firebase initialized successfully.");

  // Robust initialization of AdMob Mobile Ads SDK
  try {
    await MobileAds.instance.initialize();
    debugPrint("AdMob Mobile Ads initialized successfully.");
  } catch (e) {
    debugPrint("⚠️ AdMob failed to initialize. Ads are running in mock/simulator mode. Reason: $e");
  }

  runApp(
    const ProviderScope(
      child: PlayriumApp(),
    ),
  );
}

class PlayriumApp extends ConsumerStatefulWidget {
  const PlayriumApp({super.key});

  @override
  ConsumerState<PlayriumApp> createState() => _PlayriumAppState();
}

class _PlayriumAppState extends ConsumerState<PlayriumApp> {
  late final AppOpenAdManager _appOpenAdManager;

  @override
  void initState() {
    super.initState();
    _appOpenAdManager = AppOpenAdManager();
    // Load and show automatically on fresh start
    _appOpenAdManager.loadAd(showOnLoad: true);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Playrium',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
