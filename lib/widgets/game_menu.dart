import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feedback_providers.dart';

class GameMenu extends ConsumerWidget {
  final VoidCallback onHome;
  final VoidCallback onLeaderboard;
  final VoidCallback onStore;
  final VoidCallback onRate;
  final VoidCallback onSettings;
  final VoidCallback onFeedback;
  final VoidCallback onRestart;
  final VoidCallback onWhatsNew;

  const GameMenu({
    super.key,
    required this.onHome,
    required this.onLeaderboard,
    required this.onStore,
    required this.onRate,
    required this.onSettings,
    required this.onFeedback,
    required this.onRestart,
    required this.onWhatsNew,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: Colors.blue, size: 32),
      onOpened: () {
        ref.read(feedbackManagerProvider).playFeedback();
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'restart',
          child: ListTile(
            leading: Icon(Icons.refresh, color: Colors.blue),
            title: Text('Restart Game'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'home',
          child: ListTile(
            leading: Icon(Icons.home, color: Colors.blue),
            title: Text('Home'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'leaderboard',
          child: ListTile(
            leading: Icon(Icons.leaderboard_outlined, color: Colors.blue),
            title: Text('Leaderboard'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'store',
          child: ListTile(
            leading: Icon(Icons.store, color: Colors.blue),
            title: Text('Store'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'whats_new',
          child: ListTile(
            leading: Icon(Icons.new_releases, color: Colors.blue),
            title: Text('What\'s New?'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'rate',
          child: ListTile(
            leading: Icon(Icons.star_border, color: Colors.blue),
            title: Text('Rate App'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'settings',
          child: ListTile(
            leading: Icon(Icons.settings, color: Colors.blue),
            title: Text('Settings'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      onSelected: (String value) async {
        // Play feedback first
        onFeedback();

        // Then handle the menu selection
        switch (value) {
          case 'restart':
            onRestart();
            break;
          case 'home':
            onHome();
            break;
          case 'leaderboard':
            onLeaderboard();
            break;
          case 'store':
            onStore();
            break;
          case 'whats_new':
            onWhatsNew();
            break;
          case 'rate':
            onRate();
            break;
          case 'settings':
            onSettings();
            break;
        }
      },
    );
  }
}
