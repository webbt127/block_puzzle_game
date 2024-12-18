import 'dart:io' show Platform;
import 'package:block_puzzle_game/providers/feedback_providers.dart';
import 'package:block_puzzle_game/screens/game_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'settings_screen.dart';
import '../services/games_services.dart';
import 'store_screen.dart';
import '../widgets/waving_text.dart';

class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen> {
  @override
  void dispose() {
    ref.read(feedbackManagerProvider).dispose();
    super.dispose();
  }

  Future<void> _rateApp() async {
    final Uri url = Platform.isIOS
        ? Uri.parse('https://apps.apple.com/app/6739540042')
        : Uri.parse(
            '');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedbackManager = ref.watch(feedbackManagerProvider);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // GIF
                  Image.asset(
                    'assets/bald_eagle_drinking.gif',
                    width: 300,
                    height: 300,
                  ),
                  const SizedBox(height: 20),
                  WavingText(
                    text: 'BLOCK BLAST'.toUpperCase(),
                    fontSize: 40,
                    color: Colors.red[700]!,
                    shadowColor: Colors.blue[900],
                  ),
                  const SizedBox(height: 10),
                  WavingText(
                    text: 'STARS & STRIPES'.toUpperCase(),
                    fontSize: 30,
                    color: Colors.blue[900]!,
                    shadowColor: Colors.red[700],
                  ),
                  const Spacer(),
                  // Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        // Play Button (Larger)
                        SizedBox(
                          width: 200,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () async {
                              await feedbackManager.playFeedback();
                              if (!context.mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const GameScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 2),
                            ),
                            child: Text(
                              'play'.tr(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Secondary Buttons (Smaller)
                        SizedBox(
                          width: 160,
                          child: OutlinedButton(
                            onPressed: () async {
                              await feedbackManager.playFeedback();
                              if (!context.mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              side: BorderSide(color: colorScheme.primary, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'settings'.tr(),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 160,
                          child: OutlinedButton(
                            onPressed: () async {
                              await feedbackManager.playFeedback();
                              await _rateApp();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              side: BorderSide(color: colorScheme.primary, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'rate_us'.tr(),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 160,
                          child: OutlinedButton(
                            onPressed: () async {
                              await feedbackManager.playFeedback();
                              if (!context.mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const StoreScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              side: BorderSide(color: colorScheme.primary, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'store'.tr(),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 160,
                          child: OutlinedButton(
                            onPressed: () async {
                              await feedbackManager.playFeedback();
                              GameServicesService.showLeaderboard();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              side: BorderSide(color: colorScheme.primary, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'leaderboard'.tr(),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // About button positioned absolutely
            Positioned(
              right: 16,
              top: 16,
              child: IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: colorScheme.primary,
                  size: 28,
                ),
                onPressed: () async {
                  await feedbackManager.playFeedback();
                  if (!context.mounted) return;
                  Navigator.pushNamed(context, '/about');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
