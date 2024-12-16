import 'package:block_puzzle_game/providers/settings_notifier.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ThemeModel {
  static ColorScheme getThemeColors(ThemeType type, Brightness brightness) {
    final isLight = brightness == Brightness.light;

    return switch (type) {
      ThemeType.blue => isLight
          ? const ColorScheme.light(
              primary: Colors.blue,
              secondary: Colors.blueAccent,
            )
          : ColorScheme.dark(
              primary: Colors.blue.shade300,
              secondary: Colors.blueAccent.shade200,
            ),
      ThemeType.green => isLight
          ? const ColorScheme.light(
              primary: Colors.green,
              secondary: Colors.greenAccent,
            )
          : ColorScheme.dark(
              primary: Colors.green.shade300,
              secondary: Colors.greenAccent.shade200,
            ),
      ThemeType.purple => isLight
          ? const ColorScheme.light(
              primary: Colors.purple,
              secondary: Colors.purpleAccent,
            )
          : ColorScheme.dark(
              primary: Colors.purple.shade300,
              secondary: Colors.purpleAccent.shade200,
            ),
      ThemeType.orange => isLight
          ? const ColorScheme.light(
              primary: Colors.orange,
              secondary: Colors.orangeAccent,
            )
          : ColorScheme.dark(
              primary: Colors.orange.shade300,
              secondary: Colors.orangeAccent.shade200,
            ),
      ThemeType.red => isLight
          ? const ColorScheme.light(
              primary: Colors.red,
              secondary: Colors.redAccent,
            )
          : ColorScheme.dark(
              primary: Colors.red.shade300,
              secondary: Colors.redAccent.shade200,
            ),
      ThemeType.pink => isLight
          ? const ColorScheme.light(
              primary: Colors.pink,
              secondary: Colors.pinkAccent,
            )
          : ColorScheme.dark(
              primary: Colors.pink.shade300,
              secondary: Colors.pinkAccent.shade200,
            ),
      ThemeType.white => isLight
          ? const ColorScheme.light(
              primary: Colors.white,
              secondary: Colors.white70,
              onPrimary: Colors.black,
            )
          : ColorScheme.dark(
              primary: Colors.white70,
              secondary: Colors.white60,
              onPrimary: Colors.black,
            ),
      ThemeType.black => isLight
          ? const ColorScheme.light(
              primary: Colors.black,
              secondary: Colors.black87,
              onPrimary: Colors.white,
            )
          : const ColorScheme.dark(
              primary: Colors.black,
              secondary: Colors.black87,
              onPrimary: Colors.white,
            ),
      ThemeType.cyan => isLight
          ? const ColorScheme.light(
              primary: Colors.cyan,
              secondary: Colors.cyanAccent,
            )
          : ColorScheme.dark(
              primary: Colors.cyan.shade300,
              secondary: Colors.cyanAccent.shade200,
            ),
    };
  }

  static ThemeData getTheme(ThemeType type, ThemeMode mode) {
    final brightness = switch (mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => WidgetsBinding.instance.window.platformBrightness,
    };

    final colorScheme = getThemeColors(type, brightness);
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? const Color(0xFF202020) : Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Colors.grey.shade800 : colorScheme.primary,
        foregroundColor: type == ThemeType.white ? Colors.black : Colors.white,
      ),
      cardColor: isDark ? const Color(0xFF404040) : Colors.white,
    );
  }

  static String getTranslatedColorName(ThemeType type, BuildContext context) {
    return 'colors.${type.name}'.tr();
  }
}
