import 'package:block_puzzle_game/providers/feedback_providers.dart';
import 'package:block_puzzle_game/providers/settings_notifier.dart' as settings;
import 'package:block_puzzle_game/providers/settings_notifier.dart';
import 'package:block_puzzle_game/screens/store_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:block_puzzle_game/services/revenue_cat_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  //BannerAd? _bannerAd;

  @override
  void dispose() {
    //_bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsData = ref.watch(settings.settingsNotifierProvider);
    final feedbackManager = ref.watch(settingsFeedbackProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return settingsData.when(
      data: (data) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          title: Text(
            'settings'.tr(),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              feedbackManager.playFeedback();
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Theme Mode Selector
                    ListTile(
                      title: Text(
                        'theme_mode'.tr(),
                        style: const TextStyle(
                            color: Colors.blue),
                      ),
                      trailing: DropdownButton<ThemeMode>(
                        value: data.themeMode,
                        style: const TextStyle(
                            color: Colors.blue),
                        dropdownColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        items: [
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text(
                              'light'.tr(),
                              style: const TextStyle(
                                  color: Colors.blue),
                            ),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text(
                              'dark'.tr(),
                              style: const TextStyle(
                                  color: Colors.blue),
                            ),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text(
                              'system'.tr(),
                              style: const TextStyle(
                                  color: Colors.blue),
                            ),
                          ),
                        ],
                        onChanged: (ThemeMode? value) async {
                          await feedbackManager.playFeedback();
                          if (value != null) {
                            await ref
                                .read(settings.settingsNotifierProvider.notifier)
                                .setThemeMode(value);
                          }
                        },
                      ),
                    ),
                    const Divider(),
                    
                    // Haptics Toggle
                    SwitchListTile(
                      title: Text(
                        'enable_haptics'.tr(),
                        style: const TextStyle(
                            color: Colors.blue),
                      ),
                      subtitle: Text(
                        'enable_haptics_description'.tr(),
                        style: const TextStyle(
                            color: Colors.blue),
                      ),
                      value: data.enableHaptics,
                      onChanged: (bool value) async {
                        await feedbackManager.playFeedback();
                        await ref
                            .read(settings.settingsNotifierProvider.notifier)
                            .setEnableHaptics(value);
                      },
                    ),

                    // Sound Toggle
                    SwitchListTile(
                      title: Text(
                        'enable_sound'.tr(),
                        style: const TextStyle(
                            color: Colors.blue),
                      ),
                      subtitle: Text(
                        'enable_sound_description'.tr(),
                        style: const TextStyle(
                            color: Colors.blue),
                      ),
                      value: data.enableSound,
                      onChanged: (bool value) async {
                        await feedbackManager.playFeedback();
                        await ref
                            .read(settings.settingsNotifierProvider.notifier)
                            .setEnableSound(value);
                      },
                    ),

                    // Add space before the About section
                    const SizedBox(height: 40),
                    const Divider(),
                    
                    // About Button
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: Colors.blue),
                      title: Text(
                        'about'.tr(),
                        style: const TextStyle(color: Colors.blue),
                      ),
                      onTap: () async {
                        await feedbackManager.playFeedback();
                        if (!context.mounted) return;
                        Navigator.pushNamed(context, '/about');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  List<DropdownMenuItem<String>> _buildLanguageMenuItems(BuildContext context) {
    return const [
      // DropdownMenuItem(value: 'bg', child: Text('Bulgarian')),
      // DropdownMenuItem(value: 'ca', child: Text('Catalan')),
      // DropdownMenuItem(value: 'cs', child: Text('Czech')),
      // DropdownMenuItem(value: 'cy', child: Text('Welsh')),
      // DropdownMenuItem(value: 'da', child: Text('Danish')),
      // DropdownMenuItem(value: 'de', child: Text('German')),
      // DropdownMenuItem(value: 'el', child: Text('Greek')),
      // DropdownMenuItem(value: 'en', child: Text('English')),
      // DropdownMenuItem(value: 'es', child: Text('Spanish')),
      // DropdownMenuItem(value: 'et', child: Text('Estonian')),
      // DropdownMenuItem(value: 'eu', child: Text('Basque')),
      // DropdownMenuItem(value: 'fa', child: Text('Persian')),
      // DropdownMenuItem(value: 'fr', child: Text('French')),
      // DropdownMenuItem(value: 'gl', child: Text('Galician')),
      // DropdownMenuItem(value: 'hr', child: Text('Croatian')),
      // DropdownMenuItem(value: 'hu', child: Text('Hungarian')),
      // DropdownMenuItem(value: 'hy', child: Text('Armenian')),
      // DropdownMenuItem(value: 'is', child: Text('Icelandic')),
      // DropdownMenuItem(value: 'it', child: Text('Italian')),
      // DropdownMenuItem(value: 'ka', child: Text('Georgian')),
      // DropdownMenuItem(value: 'ko', child: Text('Korean')),
      // DropdownMenuItem(value: 'lt', child: Text('Lithuanian')),
      // DropdownMenuItem(value: 'lv', child: Text('Latvian')),
      // DropdownMenuItem(value: 'mk', child: Text('Macedonian')),
      // DropdownMenuItem(value: 'mn', child: Text('Mongolian')),
      // DropdownMenuItem(value: 'ne', child: Text('Nepali')),
      // DropdownMenuItem(value: 'nl', child: Text('Dutch')),
      // DropdownMenuItem(value: 'pl', child: Text('Polish')),
      // DropdownMenuItem(value: 'pt', child: Text('Portuguese')),
      // DropdownMenuItem(value: 'ro', child: Text('Romanian')),
      // DropdownMenuItem(value: 'ru', child: Text('Russian')),
      // DropdownMenuItem(value: 'sk', child: Text('Slovak')),
      // DropdownMenuItem(value: 'sl', child: Text('Slovenian')),
      // DropdownMenuItem(value: 'sr', child: Text('Serbian')),
      // DropdownMenuItem(value: 'sv', child: Text('Swedish')),
      // DropdownMenuItem(value: 'tr', child: Text('Turkish')),
      // DropdownMenuItem(value: 'uk', child: Text('Ukrainian')),
      // DropdownMenuItem(value: 'vi', child: Text('Vietnamese')),
    ];
  }
}
