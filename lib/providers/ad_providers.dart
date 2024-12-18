// import 'package:block_puzzle_game/services/ad_service.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// part 'ad_providers.g.dart';

// @riverpod
// class GameBannerAdNotifier extends _$GameBannerAdNotifier {
//   @override
//   BannerAd? build() {
//     final ad = AdService.createBannerAd()..load();
//     ref.onDispose(() => ad.dispose());
//     return ad;
//   }
// }

// @riverpod
// class SettingsBannerAdNotifier extends _$SettingsBannerAdNotifier {
//   @override
//   BannerAd? build() {
//     final ad = AdService.createBannerAd()..load();
//     ref.onDispose(() => ad.dispose());
//     return ad;
//   }
// }

// @riverpod
// class DifficultyBannerAdNotifier extends _$DifficultyBannerAdNotifier {
//   @override
//   BannerAd? build() {
//     final ad = AdService.createBannerAd()..load();
//     ref.onDispose(() => ad.dispose());
//     return ad;
//   }
// }

// @riverpod
// class GameInterstitialAdNotifier extends _$GameInterstitialAdNotifier {
//   @override
//   InterstitialAd? build() {
//     InterstitialAd? ad;
//     AdService.createInterstitialAd();
//     if (AdService.interstitialAd != null) {
//       ad = AdService.interstitialAd;
//       ref.onDispose(() => ad!.dispose());
//     }
//     return ad;
//   }
// }
