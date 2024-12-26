import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../enums/block_placement_offset.dart';

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences prefs;

  SettingsNotifier(this.prefs)
      : super(SettingsState(
          blockPlacementOffset: BlockPlacementOffset.fromString(
            prefs.getString('blockPlacementOffset') ?? 'medium',
          ),
        ));

  void setBlockPlacementOffset(BlockPlacementOffset offset) {
    prefs.setString('blockPlacementOffset', offset.name);
    state = state.copyWith(blockPlacementOffset: offset);
  }
}

class SettingsState {
  final BlockPlacementOffset blockPlacementOffset;

  SettingsState({
    required this.blockPlacementOffset,
  });

  SettingsState copyWith({
    BlockPlacementOffset? blockPlacementOffset,
  }) {
    return SettingsState(
      blockPlacementOffset: blockPlacementOffset ?? this.blockPlacementOffset,
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  throw UnimplementedError(
      'Initialize this provider in your app with the SharedPreferences instance');
});
