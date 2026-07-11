import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdmobService {
  // Google AdMob Ad Unit IDs
  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return kReleaseMode
          ? 'ca-app-pub-2209498185642035/4907682052' // Real Banner
          : 'ca-app-pub-3940256099942544/6300978111'; // Test Banner
    } else {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS Test Banner
    }
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return kReleaseMode
          ? 'ca-app-pub-2209498185642035/9867375019' // Real Interstitial
          : 'ca-app-pub-3940256099942544/1033173712'; // Test Interstitial
    } else {
      return 'ca-app-pub-3940256099942544/4411468910'; // iOS Test Interstitial
    }
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return kReleaseMode
          ? 'ca-app-pub-2209498185642035/8282830606' // Real Rewarded
          : 'ca-app-pub-3940256099942544/5224354917'; // Test Rewarded
    } else {
      return 'ca-app-pub-3940256099942544/1712485313'; // iOS Test Rewarded
    }
  }

  static String get appOpenAdUnitId {
    if (kIsWeb) return '';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return kReleaseMode
          ? 'ca-app-pub-2209498185642035/3243246594' // Real App Open
          : 'ca-app-pub-3940256099942544/9257395921'; // Test App Open
    } else {
      return 'ca-app-pub-3940256099942544/9257395921'; // iOS Test App Open fallback
    }
  }

  bool _isAdMobAvailable() {
    // Check if platform is supported
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
  }

  // Load and show Banner Ad
  AdWidget? createBannerAdWidget(VoidCallback onAdLoaded) {
    if (!_isAdMobAvailable()) return null;

    final banner = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          onAdLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    banner.load();
    return AdWidget(ad: banner);
  }

  // Load and show Interstitial Ad during transitions
  void showTransitionInterstitial(BuildContext context, VoidCallback onClosed) {
    if (!_isAdMobAvailable()) {
      debugPrint('[MOCK ADMOB] Simulating interstitial transition ad...');
      onClosed();
      return;
    }

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onClosed();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              onClosed();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          onClosed();
        },
      ),
    );
  }

  // Show Rewarded Ad (strictly optional)
  void showOptionalRewardedAd(
    BuildContext context, {
    required VoidCallback onRewardEarned,
    required VoidCallback onClosed,
    required VoidCallback onLoadingStart,
    required VoidCallback onLoadingEnd,
  }) {
    if (!_isAdMobAvailable()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("AdMob is not supported on this platform."),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      onClosed();
      return;
    }

    onLoadingStart(); // Signal UI to start local loading overlay

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          onLoadingEnd(); // Signal UI to end loading overlay
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onClosed();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              onClosed();
            },
          );

          ad.show(
            onUserEarnedReward: (adWithoutView, reward) {
              onRewardEarned();
            },
          );
        },
        onAdFailedToLoad: (error) {
          onLoadingEnd(); // Signal UI to end loading overlay
          debugPrint('RewardedAd failed to load: $error.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("AdMob load failed: ${error.message} (Code: ${error.code})"),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 4),
            ),
          );
          onClosed();
        },
      ),
    );
  }
}

class AppOpenAdManager {
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  DateTime? _loadTime;

  /// Load an AppOpenAd.
  void loadAd({bool showOnLoad = false}) {
    if (kIsWeb) return;
    final isMobile = defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
    if (!isMobile) return;

    AppOpenAd.load(
      adUnitId: AdmobService.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AppOpenAd loaded.');
          _appOpenAd = ad;
          _loadTime = DateTime.now();
          if (showOnLoad) {
            showAdIfAvailable();
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    if (_appOpenAd == null || _loadTime == null) return false;
    return DateTime.now().difference(_loadTime!).inHours < 4;
  }

  /// Show the ad if one is available.
  void showAdIfAvailable() {
    if (_isShowingAd) {
      debugPrint('AppOpenAd is already showing.');
      return;
    }

    if (!isAdAvailable) {
      debugPrint('AppOpenAd is not available.');
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        debugPrint('AppOpenAd showed full screen content.');
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        debugPrint('AppOpenAd dismissed full screen content.');
        ad.dispose();
        _appOpenAd = null;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        debugPrint('AppOpenAd failed to show: $error');
        ad.dispose();
        _appOpenAd = null;
      },
    );

    _appOpenAd!.show();
  }
}
