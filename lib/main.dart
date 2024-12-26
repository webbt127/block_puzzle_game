import 'dart:io';
import 'dart:async';
import 'package:block_puzzle_game/screens/main_menu_screen.dart';
import 'package:block_puzzle_game/services/ad_service.dart';
import 'package:block_puzzle_game/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'screens/game_screen.dart';
import 'package:block_puzzle_game/env/env.dart';
import 'package:block_puzzle_game/providers/settings_notifier.dart' as settings;
import 'package:block_puzzle_game/services/revenue_cat_service.dart';
import 'package:block_puzzle_game/services/games_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:block_puzzle_game/screens/main_menu_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:block_puzzle_game/constants/supported_locales.dart';
import 'package:block_puzzle_game/models/theme.dart';
import 'package:block_puzzle_game/screens/settings_screen.dart';
import 'package:block_puzzle_game/screens/about_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize error tracking
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AnalyticsService.logError(
      'flutter_error',
      details.exception,
      details.stack,
    );
  };

  // Handle errors that occur during zone execution
  runZonedGuarded(() async {
    final container = ProviderContainer();
    final settingsProvider =
        await container.read(settings.settingsNotifierProvider.future);

    // Initialize services
    await Future.wait([
      AnalyticsService.initialize(),
      AdService.initialize(),
      container.read(revenueCatServiceProvider).init(Platform.isAndroid
          ? Env.revenueCatApiKeyAndroid
          : Env.revenueCatApiKeyIos),
    ]);

    // Check if ads should be hidden
    final hideAds = await container.read(hasHideAdsProvider.future);
    if (!hideAds) {
      // Preload interstitial ad
      AdService.createInterstitialAd();
    }

    // Initialize game services and sign in
    try {
      await GameServicesService.signIn();
    } catch (e) {
      print('Error signing into Game Services: $e');
      AnalyticsService.logError('game_services_signin_error', e, null);
    }

    runApp(
      ProviderScope(
        child: EasyLocalization(
          supportedLocales: supportedLocales,
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          startLocale: Locale(settingsProvider.languageCode),
          child: const MyApp(),
        ),
      ),
    );
  }, (error, stackTrace) {
    AnalyticsService.logError('uncaught_error', error, stackTrace);
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsValue = ref.watch(settings.settingsNotifierProvider);

    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'Block Blast - Stars & Stripes',
      theme: ThemeModel.getTheme(ThemeType.blue, ThemeMode.light),
      darkTheme: ThemeModel.getTheme(ThemeType.blue, ThemeMode.dark),
      themeMode: settingsValue.value?.themeMode ?? ThemeMode.system,
      home: const MainMenuScreen(),
      routes: {
        '/settings': (context) => const SettingsScreen(),
        '/about': (context) => const AboutScreen(),
      },
    );
  }
}
