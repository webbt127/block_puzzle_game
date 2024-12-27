import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'REVENUECAT_API_KEY_ANDROID')
  static const String revenueCatApiKeyAndroid = _Env.revenueCatApiKeyAndroid;
  
  @EnviedField(varName: 'REVENUECAT_API_KEY_IOS')
  static const String revenueCatApiKeyIos = _Env.revenueCatApiKeyIos;

  @EnviedField(varName: 'AMPLITUDE_API_KEY')
  static const String amplitudeApiKey = _Env.amplitudeApiKey;

  // Test Ad Unit IDs
  @EnviedField(varName: 'ADMOB_TEST_BANNER_ANDROID')
  static const String testBannerAdUnitIdAndroid = _Env.testBannerAdUnitIdAndroid;

  @EnviedField(varName: 'ADMOB_TEST_BANNER_IOS')
  static const String testBannerAdUnitIdIos = _Env.testBannerAdUnitIdIos;

  @EnviedField(varName: 'ADMOB_TEST_INTERSTITIAL_ANDROID')
  static const String testInterstitialAdUnitIdAndroid = _Env.testInterstitialAdUnitIdAndroid;

  @EnviedField(varName: 'ADMOB_TEST_INTERSTITIAL_IOS')
  static const String testInterstitialAdUnitIdIos = _Env.testInterstitialAdUnitIdIos;

  @EnviedField(varName: 'ADMOB_TEST_REWARDED_ANDROID')
  static const String testRewardedAdUnitIdAndroid = _Env.testRewardedAdUnitIdAndroid;

  @EnviedField(varName: 'ADMOB_TEST_REWARDED_IOS')
  static const String testRewardedAdUnitIdIos = _Env.testRewardedAdUnitIdIos;

  // Production Ad Unit IDs
  @EnviedField(varName: 'ADMOB_BANNER_ANDROID')
  static const String bannerAdUnitIdAndroid = _Env.bannerAdUnitIdAndroid;

  @EnviedField(varName: 'ADMOB_BANNER_IOS')
  static const String bannerAdUnitIdIos = _Env.bannerAdUnitIdIos;

  @EnviedField(varName: 'ADMOB_INTERSTITIAL_ANDROID')
  static const String interstitialAdUnitIdAndroid = _Env.interstitialAdUnitIdAndroid;

  @EnviedField(varName: 'ADMOB_INTERSTITIAL_IOS')
  static const String interstitialAdUnitIdIos = _Env.interstitialAdUnitIdIos;

  @EnviedField(varName: 'ADMOB_REWARDED_ANDROID')
  static const String rewardedAdUnitIdAndroid = _Env.rewardedAdUnitIdAndroid;

  @EnviedField(varName: 'ADMOB_REWARDED_IOS')
  static const String rewardedAdUnitIdIos = _Env.rewardedAdUnitIdIos;
}