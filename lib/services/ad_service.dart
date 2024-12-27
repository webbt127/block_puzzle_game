import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:block_puzzle_game/env/env.dart';

class AdService {
  static String get bannerAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return Env.testBannerAdUnitIdAndroid;
      } else if (Platform.isIOS) {
        return Env.testBannerAdUnitIdIos;
      }
    } else {
      if (Platform.isAndroid) {
        return Env.bannerAdUnitIdAndroid;
      } else if (Platform.isIOS) {
        return Env.bannerAdUnitIdIos;
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return Env.testInterstitialAdUnitIdAndroid;
      } else if (Platform.isIOS) {
        return Env.testInterstitialAdUnitIdIos;
      }
    } else {
      if (Platform.isAndroid) {
        return Env.interstitialAdUnitIdAndroid;
      } else if (Platform.isIOS) {
        return Env.interstitialAdUnitIdIos;
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return Env.testRewardedAdUnitIdAndroid;
      } else if (Platform.isIOS) {
        return Env.testRewardedAdUnitIdIos;
      }
    } else {
      if (Platform.isAndroid) {
        return Env.rewardedAdUnitIdAndroid;
      } else if (Platform.isIOS) {
        return Env.rewardedAdUnitIdIos;
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
