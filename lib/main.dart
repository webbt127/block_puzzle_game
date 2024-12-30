import 'dart:io';
import 'dart:async';
import 'package:block_puzzle_game/screens/main_menu_screen.dart';
import 'package:block_puzzle_game/services/ad_service.dart';
import 'package:block_puzzle_game/services/analytics_service.dart';
import 'package:block_puzzle_game/services/store_service.dart';
import 'package:flutter/material.dart';
import 'screens/game_screen.dart';
import 'package:block_puzzle_game/env/env.dart';
import 'package:block_puzzle_game/providers/settings_notifier.dart' as settings;
import 'package:block_puzzle_game/services/games_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:block_puzzle_game/screens/main_menu_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:block_puzzle_game/constants/supported_locales.dart';
import 'package:block_puzzle_game/models/theme.dart';
import 'package:block_puzzle_game/screens/settings_screen.dart';
import 'package:block_puzzle_game/screens/about_screen.dart';

Future<void> initializeApp() async {
  await EasyLocalization.ensureInitialized();

  final container = ProviderContainer();
  final settingsProvider =
      await container.read(settings.settingsNotifierProvider.future);

  // Initialize all services first
  await Future.wait([
    AnalyticsService.initialize(),
    AdService.initialize(),
    container.read(initializeStoreProvider.future),
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

  //return settingsProvider;
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize error tracking
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      AnalyticsService.logError(
        'flutter_error',
        details.exception,
        details.stack,
      );
    };

    final settingsProvider = await initializeApp();
    
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
  }, (error, stack) {
    print('Uncaught error: $error');
    AnalyticsService.logError('uncaught_error', error, stack);
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
