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
  }) {
    if (!_isAdMobAvailable()) {
      _showMockRewardedAdDialog(context, onRewardEarned, onClosed);
      return;
    }

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          Navigator.of(context).pop(); // Dismiss loading overlay
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onClosed();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              Navigator.of(context).pop(); // Ensure dismiss
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
          Navigator.of(context).pop(); // Dismiss loading overlay
          debugPrint('RewardedAd failed to load: $error. Running mock simulation.');
          _showMockRewardedAdDialog(context, onRewardEarned, onClosed);
        },
      ),
    );
  }

  // Beautiful UI simulation of a Rewarded Ad when offline/in simulator
  void _showMockRewardedAdDialog(
    BuildContext context,
    VoidCallback onRewardEarned,
    VoidCallback onClosed,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _MockAdScreen(
          onCompleted: () {
            Navigator.of(dialogContext).pop();
            onRewardEarned();
            onClosed();
          },
          onCancelled: () {
            Navigator.of(dialogContext).pop();
            onClosed();
          },
        );
      },
    );
  }
}

// Simulated Video Ad dialog player
class _MockAdScreen extends StatefulWidget {
  final VoidCallback onCompleted;
  final VoidCallback onCancelled;

  const _MockAdScreen({required this.onCompleted, required this.onCancelled});

  @override
  State<_MockAdScreen> createState() => _MockAdScreenState();
}

class _MockAdScreenState extends State<_MockAdScreen> {
  int _secondsLeft = 5; // Standard short test ad duration
  late double _progress = 1.0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _secondsLeft--;
        _progress = _secondsLeft / 5.0;
      });
      if (_secondsLeft <= 0) {
        widget.onCompleted();
        return false;
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F1117),
      insetPadding: const EdgeInsets.all(0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background content mimicking ad visual
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF0F1117)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_circle_filled, size: 80, color: Color(0xFF00D1FF)),
                  const SizedBox(height: 16),
                  const Text(
                    "Playrium Sponsor Video",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Reward: 5 Coins + 10 XP",
                    style: TextStyle(color: Colors.amberAccent.shade100, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: _progress,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D1FF)),
                      backgroundColor: Colors.white10,
                      strokeWidth: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Timer counter
          Positioned(
            top: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Ad ends in ${_secondsLeft}s",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          // Skip / Close Button
          Positioned(
            top: 24,
            left: 24,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: widget.onCancelled,
            ),
          )
        ],
      ),
    );
  }
}
