class ChangelogEntry {
  final String version;
  final String buildNumber;
  final List<String> changes;

  const ChangelogEntry({
    required this.version,
    required this.buildNumber,
    required this.changes,
  });
}

const List<ChangelogEntry> changelog = [
  ChangelogEntry(
    version: '1.0.6',
    buildNumber: '25',
    changes: [
      'Add game saves',
      'Modify reroll button',
      'Bug fixes and performance improvements',
      'Add How To Play section',

    ],
  ),
  ChangelogEntry(
    version: '1.0.5',
    buildNumber: '20',
    changes: [
      'Update GIF pool',
      'Add reroll blocks button',
      'Bug fixes and performance improvements',
    ],
  ),
  ChangelogEntry(
    version: '1.0.4',
    buildNumber: '18',
    changes: [
      'Added block placement offset setting to adjust block drop position',
      'Enhanced game over popup design and added high score celebration',
      'Added What\'s New section',
      'Improved About screen design',
      'Champion showcase on main menu',
    ],
  ),
  ChangelogEntry(
    version: '1.0.3',
    buildNumber: '17',
    changes: [
      'Improved game over messages',
      'Enhanced UI responsiveness',
      'Bug fixes and performance improvements',
    ],
  ),
];
