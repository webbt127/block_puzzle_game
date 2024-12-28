import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:block_puzzle_game/env/env.dart';
import 'package:block_puzzle_game/services/logging_service.dart';

class AdService {
  static Future<void> _log(String message) async {
    await LoggingService.log('[AdService] $message');
  }

  static String get bannerAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return Env.testBannerAdUnitIdAndroid;
      } else {
        return Env.testBannerAdUnitIdIos;
      }
    } else {
      if (Platform.isAndroid) {
        return Env.bannerAdUnitIdAndroid;
      } else {
        return Env.bannerAdUnitIdIos;
      }
    }
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return Env.testInterstitialAdUnitIdAndroid;
      } else {
        return Env.testInterstitialAdUnitIdIos;
      }
    } else {
      if (Platform.isAndroid) {
        return Env.interstitialAdUnitIdAndroid;
      } else {
        return Env.interstitialAdUnitIdIos;
      }
    }
  }

  static String get rewardedAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return Env.testRewardedAdUnitIdAndroid;
      } else {
        return Env.testRewardedAdUnitIdIos;
      }
    } else {
      if (Platform.isAndroid) {
        return Env.rewardedAdUnitIdAndroid;
      } else {
        return Env.rewardedAdUnitIdIos;
      }
    }
  }

  static InterstitialAd? _interstitialAd;
  static int _numInterstitialLoadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;

  static RewardedAd? _rewardedAd;
  static int _numRewardedLoadAttempts = 0;

  static final List<String> _testDevices = [
    '609D579E-7B9B-43CB-83D7-D3D042815711', // Todd's iPhone - simplified format
    'GADSimulatorID', // For iOS Simulator
  ];

  static AdRequest get _adRequest => const AdRequest(
    nonPersonalizedAds: true,
  );

  static final List<void Function()> _listeners = [];

  static void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  static void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  static void notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  static Future<void> initialize() async {
    _log('Initializing AdService');
    _log('Debug mode: ${kDebugMode ? 'ON' : 'OFF'}');
    _log('Platform: ${Platform.isAndroid ? 'Android' : 'iOS'}');
    _log('Test devices: $_testDevices');
    _log('Banner ad unit ID: $bannerAdUnitId');
    _log('Interstitial ad unit ID: $interstitialAdUnitId');
    _log('Rewarded ad unit ID: $rewardedAdUnitId');
    
    // Initialize test devices first
    _log('Configuring test devices...');
    final RequestConfiguration config = RequestConfiguration(
      testDeviceIds: _testDevices,
    );
    
    try {
      await MobileAds.instance.updateRequestConfiguration(config);
      _log('Test device configuration updated successfully');
    } catch (e) {
      _log('Failed to update test device configuration: $e');
    }
    
    try {
      await MobileAds.instance.initialize();
      _log('MobileAds initialized successfully');
    } catch (e) {
      _log('Failed to initialize MobileAds: $e');
    }

    // Verify configuration
    final deviceId = await MobileAds.instance.getRequestConfiguration()
        .then((config) => config.testDeviceIds?.join(', ') ?? 'none');
    _log('Current test devices: $deviceId');
  }

  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: _adRequest,
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
      request: _adRequest,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          notifyListeners();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;
          if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
            createInterstitialAd();
          }
          notifyListeners();
        },
      ),
    );
  }

  static void showInterstitialAd() {
    if (_interstitialAd == null) {
      return;
    }

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

  static Future<void> loadRewardedAd() async {
    if (_rewardedAd != null) {
      _log('Rewarded ad already loaded');
      return;
    }

    _log('Loading rewarded ad...');
    _log('Using ad unit ID: $rewardedAdUnitId');
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: _adRequest,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _log('Rewarded ad loaded successfully');
          _rewardedAd = ad;
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _log('Rewarded ad showed full screen content');
            },
            onAdDismissedFullScreenContent: (ad) {
              _log('Rewarded ad was dismissed');
              ad.dispose();
              _rewardedAd = null;
              notifyListeners();
              loadRewardedAd(); // Load the next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _log('Rewarded ad failed to show: $error');
              ad.dispose();
              _rewardedAd = null;
              notifyListeners();
              loadRewardedAd(); // Try loading another ad
            },
          );
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          _log('Failed to load rewarded ad: ${error.message}');
          _log('Error code: ${error.code}');
          _log('Error domain: ${error.domain}');
          _rewardedAd = null;
          notifyListeners();
        },
      ),
    );
  }

  static Future<bool> showRewardedAd({
    required Function(Ad, RewardItem) onUserEarnedReward,
  }) async {
    if (_rewardedAd == null) {
      _log('Attempted to show rewarded ad but none was loaded');
      return false;
    }

    _log('Showing rewarded ad');
    final completer = Completer<bool>();
    
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        _log('User earned reward: ${reward.amount} ${reward.type}');
        onUserEarnedReward(ad, reward);
        completer.complete(true);
      },
    );

    return completer.future;
  }

  static bool get hasInterstitialAd => _interstitialAd != null;
  static bool get hasRewardedAd => _rewardedAd != null;
  static bool get canShowAd => !kDebugMode;

  static bool canShowRewardedAd(bool hideAds) {
    return !hideAds && hasRewardedAd;
  }

  static bool canShowInterstitialAd(bool hideAds) {
    return !hideAds && hasInterstitialAd;
  }

  static bool get hasrewardedAd => _rewardedAd != null;

  static Future<String> getLogs() async {
    return LoggingService.getLogs();
  }

  static Future<void> clearLogs() async {
    return LoggingService.clearLogs();
  }
}
