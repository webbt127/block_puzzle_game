import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

part 'settings_notifier.g.dart';

enum ThemeType { blue, green, purple, orange, red, pink, white, black, cyan }

class Settings {
  final bool showGrid;
  final String language;
  final bool enableHaptics;
  final bool enableSound;
  final String languageCode;
  final ThemeMode themeMode;
  final ThemeType themeType;

  const Settings({
    this.showGrid = true,
    this.language = 'English',
    this.enableHaptics = true,
    this.enableSound = true,
    this.languageCode = 'en',
    this.themeMode = ThemeMode.system,
    this.themeType = ThemeType.blue,
  });

  Settings copyWith({
    bool? showGrid,
    String? language,
    bool? enableHaptics,
    bool? enableSound,
    String? languageCode,
    ThemeMode? themeMode,
    ThemeType? themeType,
  }) {
    return Settings(
      showGrid: showGrid ?? this.showGrid,
      language: language ?? this.language,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      enableSound: enableSound ?? this.enableSound,
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
      themeType: themeType ?? this.themeType,
    );
  }

  static const Map<String, String> languageNames = {
    // 'bg': 'Български',
    // 'ca': 'Català',
    // 'cs': 'Čeština',
    // 'cy': 'Cymraeg',
    // 'da': 'Dansk',
    // 'de': 'Deutsch',
    // 'el': 'Ελληνικά',
    'en': 'English',
    // 'es': 'Español',
    // 'et': 'Eesti',
    // 'eu': 'Euskara',
    // 'fa': 'فارسی',
    // 'fr': 'Français',
    // 'gl': 'Galego',
    // 'hr': 'Hrvatski',
    // 'hu': 'Magyar',
    // 'hy': 'Հայերեն',
    // 'is': 'Íslenska',
    // 'it': 'Italiano',
    // 'ka': 'ქართული',
    // 'ko': '한국어',
    // 'lt': 'Lietuvių',
    // 'lv': 'Latviešu',
    // 'mk': 'Македонски',
    // 'mn': 'Монгол',
    // 'ne': 'नेपाली',
    // 'nl': 'Nederlands',
    // 'pl': 'Polski',
    // 'pt': 'Português',
    // 'ro': 'Română',
    // 'ru': 'Русский',
    // 'sk': 'Slovenčina',
    // 'sl': 'Slovenščina',
    // 'sr': 'Српски',
    // 'sv': 'Svenska',
    // 'tr': 'Türkçe',
    // 'uk': 'Українська',
    // 'vi': 'Tiếng Việt',
  };

  static const Map<String, String> deviceLocaleMap = {
    // 'bg': 'bg',
    // 'ca': 'ca',
    // 'cs': 'cs',
    // 'cy': 'cy',
    // 'da': 'da',
    // 'de': 'de',
    // 'el': 'el',
    'en': 'en',
    // 'es': 'es',
    // 'et': 'et',
    // 'eu': 'eu',
    // 'fa': 'fa',
    // 'fr': 'fr',
    // 'gl': 'gl',
    // 'hr': 'hr',
    // 'hu': 'hu',
    // 'hy': 'hy',
    // 'is': 'is',
    // 'it': 'it',
    // 'ka': 'ka',
    // 'ko': 'ko',
    // 'lt': 'lt',
    // 'lv': 'lv',
    // 'mk': 'mk',
    // 'mn': 'mn',
    // 'ne': 'ne',
    // 'nl': 'nl',
    // 'pl': 'pl',
    // 'pt': 'pt',
    // 'ro': 'ro',
    // 'ru': 'ru',
    // 'sk': 'sk',
    // 'sl': 'sl',
    // 'sr': 'sr',
    // 'sv': 'sv',
    // 'tr': 'tr',
    // 'uk': 'uk',
    // 'vi': 'vi',
  };

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Colors.blue.shade300,
      secondary: Colors.blueAccent.shade200,
      surface: const Color(0xFF303030),
      onSurface: Colors.white.withOpacity(0.87),
    ),
    scaffoldBackgroundColor: const Color(0xFF202020),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade800,
      foregroundColor: Colors.white,
    ),
    cardColor: const Color(0xFF404040),
  );

  ColorScheme getThemeColor(ThemeType type) {
    switch (type) {
      case ThemeType.blue:
        return const ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        );
      case ThemeType.green:
        return const ColorScheme.light(
          primary: Colors.green,
          secondary: Colors.greenAccent,
        );
      case ThemeType.purple:
        return const ColorScheme.light(
          primary: Colors.purple,
          secondary: Colors.purpleAccent,
        );
      case ThemeType.orange:
        return const ColorScheme.light(
          primary: Colors.orange,
          secondary: Colors.orangeAccent,
        );
      case ThemeType.red:
        return const ColorScheme.light(
          primary: Colors.red,
          secondary: Colors.redAccent,
        );
      case ThemeType.pink:
        return const ColorScheme.light(
          primary: Colors.pink,
          secondary: Colors.pinkAccent,
        );
      case ThemeType.white:
        return const ColorScheme.light(
          primary: Colors.white,
          secondary: Colors.white70,
        );
      case ThemeType.black:
        return const ColorScheme.dark(
          primary: Colors.black,
          secondary: Colors.black87,
        );
      case ThemeType.cyan:
        return const ColorScheme.light(
          primary: Colors.cyan,
          secondary: Colors.cyanAccent,
        );
    }
  }
}

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  late SharedPreferences _prefs;
  static const String _showGridKey = 'show_grid';
  static const String _languageCodeKey = 'language_code';
  static const String _themeModeKey = 'theme_mode';

  @override
  Future<Settings> build() async {
    _prefs = await SharedPreferences.getInstance();

    final isFirstLaunch = _prefs.getBool('is_first_launch') ?? true;
    String languageCode = 'en';
    String language = 'English';

    if (isFirstLaunch) {
      final deviceLocale = Platform.localeName.split('_')[0].toLowerCase();

      if (Settings.deviceLocaleMap.containsKey(deviceLocale)) {
        languageCode = Settings.deviceLocaleMap[deviceLocale]!;
        language = Settings.languageNames[languageCode] ?? 'English';
        await _prefs.setString(_languageCodeKey, languageCode);
      }

      await _prefs.setBool('is_first_launch', false);
    }

    final themeModeIndex =
        _prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;

    return Settings(
      showGrid: _prefs.getBool(_showGridKey) ?? true,
      languageCode: _prefs.getString(_languageCodeKey) ?? languageCode,
      language: Settings.languageNames[languageCode] ?? language,
      enableHaptics: _prefs.getBool('enable_haptics') ?? true,
      enableSound: _prefs.getBool('enable_sound') ?? true,
      themeMode: ThemeMode.values[themeModeIndex],
      themeType:
          ThemeType.values[_prefs.getInt('theme_type') ?? ThemeType.blue.index],
    );
  }

  Future<void> setShowGrid(bool value) async {
    state = await AsyncValue.guard(() async {
      await _prefs.setBool(_showGridKey, value);
      final settings = state.value!;
      return settings.copyWith(showGrid: value);
    });
  }

  Future<void> setLanguage(String languageCode) async {
    state = await AsyncValue.guard(() async {
      await _prefs.setString(_languageCodeKey, languageCode);
      final settings = state.value!;
      return settings.copyWith(
        languageCode: languageCode,
        language: Settings.languageNames[languageCode] ?? 'English',
      );
    });
  }

  Future<void> setEnableHaptics(bool value) async {
    state = await AsyncValue.guard(() async {
      await _prefs.setBool('enable_haptics', value);
      final settings = state.value!;
      return settings.copyWith(enableHaptics: value);
    });
  }

  Future<void> setEnableSound(bool value) async {
    state = await AsyncValue.guard(() async {
      await _prefs.setBool('enable_sound', value);
      final settings = state.value!;
      return settings.copyWith(enableSound: value);
    });
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = await AsyncValue.guard(() async {
      await _prefs.setInt(_themeModeKey, mode.index);
      final settings = state.value!;

      // Determine if we're in light mode (either explicitly or via system settings)
      final isLightMode = mode == ThemeMode.light ||
          (mode == ThemeMode.system &&
              WidgetsBinding.instance.window.platformBrightness ==
                  Brightness.light);

      ThemeType newThemeType = settings.themeType;
      if ((isLightMode && settings.themeType == ThemeType.white) ||
          (!isLightMode && settings.themeType == ThemeType.black)) {
        // Reset to blue theme if current theme is invalid for the new mode
        newThemeType = ThemeType.blue;
        await _prefs.setInt('theme_type', ThemeType.blue.index);
      }

      return settings.copyWith(
        themeMode: mode,
        themeType: newThemeType,
      );
    });
  }

  Future<void> setThemeType(ThemeType type) async {
    state = await AsyncValue.guard(() async {
      final settings = state.value!;
      
      // Check if the requested theme type is valid for current mode
      final isLightMode = settings.themeMode == ThemeMode.light ||
          (settings.themeMode == ThemeMode.system &&
              WidgetsBinding.instance.window.platformBrightness ==
                  Brightness.light);

      // Prevent white theme in light mode and black theme in dark mode
      if ((isLightMode && type == ThemeType.white) ||
          (!isLightMode && type == ThemeType.black)) {
        return settings; // Keep current settings if invalid theme requested
      }

      await _prefs.setInt('theme_type', type.index);
      return settings.copyWith(themeType: type);
    });
  }

  static String getDeviceLanguageCode(BuildContext context) {
    final locale = View.of(context).platformDispatcher.locale;
    final deviceLocale = locale.languageCode.toLowerCase();
    return Settings.deviceLocaleMap[deviceLocale] ?? 'en';
  }

  static bool isLanguageSupported(String languageCode) {
    return Settings.deviceLocaleMap.containsKey(languageCode.toLowerCase());
  }
}
