import 'dart:io' show Platform;
import 'package:block_puzzle_game/providers/feedback_providers.dart';
import 'package:block_puzzle_game/screens/game_screen.dart';
import 'package:block_puzzle_game/widgets/patriotic_title.dart';
import 'package:block_puzzle_game/widgets/top_player_showcase.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'settings_screen.dart';
import '../services/games_services.dart';
import 'store_screen.dart';

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
        : Uri.parse('https://play.google.com/store/apps/details?id=com.apparchitects.blockpuzzle');

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
            Positioned(
              top: 10,
              right: 10,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.leaderboard_outlined, color: colorScheme.primary),
                    onPressed: () async {
                      await feedbackManager.playFeedback();
                      GameServicesService.showLeaderboard();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.shopping_bag_outlined, color: colorScheme.primary),
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
                  ),
                  IconButton(
                    icon: Icon(Icons.star_border, color: colorScheme.primary),
                    onPressed: () async {
                      await feedbackManager.playFeedback();
                      await _rateApp();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: colorScheme.primary),
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
                  ),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // GIF
                  Image.asset(
                    'assets/bald_eagle_drinking.gif',
                    width: 300,
                    height: 300,
                  ),
                  //const SizedBox(height: 4),
                  const TopPlayerShowcase(),
                  //const SizedBox(height: 4),
                  const IntrinsicHeight(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        PatrioticTitle(
                          text: 'BLOCK BLAST',
                          fontSize: 40,
                          isSecondary: false,
                        ),
                        SizedBox(height: 0),
                        PatrioticTitle(
                          text: 'STARS & STRIPES',
                          fontSize: 30,
                          isSecondary: true,
                        ),
                      ],
                    ),
                  ),
                  // Play Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
