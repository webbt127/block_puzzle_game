import 'package:block_puzzle_game/providers/settings_notifier.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ThemeModel {
  static ColorScheme getThemeColors(ThemeType type, Brightness brightness) {
    final isLight = brightness == Brightness.light;

    // Use patriotic colors regardless of theme type
    return isLight
        ? const ColorScheme.light(
            primary: Colors.blue,
            secondary: Colors.red,
            tertiary: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
          )
        : const ColorScheme.dark(
            primary: Colors.blue,
            secondary: Colors.red,
            tertiary: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
          );
  }

  static ThemeData getTheme(ThemeType type, ThemeMode mode) {
    final brightness = switch (mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => WidgetsBinding.instance.window.platformBrightness,
    };

    final colorScheme = getThemeColors(type, brightness);
    final isLight = brightness == Brightness.light;

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isLight ? Colors.white : Colors.black87,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: colorScheme.primary),
        bodyMedium: TextStyle(color: colorScheme.primary),
      ),
    );
  }

  static String getTranslatedColorName(ThemeType type, BuildContext context) {
    return 'colors.${type.name}'.tr();
  }
}

enum ThemeType {
  blue;

  String get displayName => toString().split('.').last.tr();
}
