import 'package:flutter/material.dart';

class GameMenu extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onLeaderboard;
  final VoidCallback onStore;
  final VoidCallback onRate;
  final VoidCallback onSettings;
  final VoidCallback onFeedback;

  const GameMenu({
    super.key,
    required this.onHome,
    required this.onLeaderboard,
    required this.onStore,
    required this.onRate,
    required this.onSettings,
    required this.onFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: Colors.blue, size: 32),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
            leading: Icon(Icons.shopping_bag_outlined, color: Colors.blue),
            title: Text('Store'),
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
          case 'home':
            onHome();
            break;
          case 'leaderboard':
            onLeaderboard();
            break;
          case 'store':
            onStore();
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
