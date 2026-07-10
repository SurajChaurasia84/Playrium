import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'navigation/app_router.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Robust initialization of Firebase
  try {
    await Firebase.initializeApp();
    debugPrint("Firebase initialized successfully.");
  } catch (e) {
    debugPrint("⚠️ Firebase core failed to initialize. Client is running in mock/simulator mode. Reason: $e");
  }

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

class PlayriumApp extends ConsumerWidget {
  const PlayriumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
