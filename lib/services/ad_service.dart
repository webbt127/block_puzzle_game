import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static String get bannerAdUnitId {
    if (kDebugMode) {
      // Test ad unit IDs
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      }
    } else {
      // Production ad unit IDs
      if (Platform.isAndroid) {
        return 'ca-app-pub-2505538993380432/5207541366';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-2505538993380432/5746892568';
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      // Test ad unit IDs
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910';
      }
    } else {
      // Production ad unit IDs
      if (Platform.isAndroid) {
        return 'ca-app-pub-2505538993380432/7451427297';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-2505538993380432/7989912521';
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedAdUnitId {
    if (kDebugMode) {
      // Test ad unit IDs
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/5224354917';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/1712485313';
      }
    } else {
      // Production ad unit IDs
      if (Platform.isAndroid) {
        return 'ca-app-pub-2505538993380432/5048301836';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-2505538993380432/4667090086';
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  static InterstitialAd? _interstitialAd;
  static int _numInterstitialLoadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;

  static RewardedAd? _rewardedAd;
  static int _numRewardedLoadAttempts = 0;

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => {},
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
  }

  static void createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;
          if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
            createInterstitialAd();
          }
        },
      ),
    );
  }

  static InterstitialAd? get interstitialAd => _interstitialAd;

  static void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          createInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  static RewardedAd? get rewardedAd => _rewardedAd;

  static void createRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _numRewardedLoadAttempts += 1;
          _rewardedAd = null;
          if (_numRewardedLoadAttempts <= maxFailedLoadAttempts) {
            createRewardedAd();
          }
        },
      ),
    );
  }

  static void showRewardedAd({
    required OnUserEarnedRewardCallback onUserEarnedReward,
  }) {
    if (_rewardedAd == null) {
      createRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        createRewardedAd();
      },
    );
    _rewardedAd!.show(onUserEarnedReward: onUserEarnedReward);
    _rewardedAd = null;
  }
}
