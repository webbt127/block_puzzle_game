import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/feedback_manager.dart';
import 'settings_notifier.dart';

part 'feedback_providers.g.dart';

@riverpod
FeedbackManager feedbackManager(Ref ref) {
  final settings = ref.watch(settingsNotifierProvider).value;
  return FeedbackManager(
    enableSound: settings?.enableSound ?? true,
    enableHaptics: settings?.enableHaptics ?? true,
    hapticLevel: HapticLevel.selection,
    soundType: SoundType.systemClick,
  );
}

@riverpod
FeedbackManager wordFoundFeedback(Ref ref) {
  final settings = ref.watch(settingsNotifierProvider).value;
  return FeedbackManager(
    enableSound: settings?.enableSound ?? true,
    enableHaptics: settings?.enableHaptics ?? true,
    hapticLevel: HapticLevel.heavy,
    soundType: SoundType.custom,
    soundAsset: 'assets/sounds/word_found.mp3',
  );
}

@riverpod
FeedbackManager timeUpFeedback(Ref ref) {
  final settings = ref.watch(settingsNotifierProvider).value;
  return FeedbackManager(
    enableSound: settings?.enableSound ?? true,
    enableHaptics: settings?.enableHaptics ?? true,
    hapticLevel: HapticLevel.light,
    soundType: SoundType.custom,
    soundAsset: 'assets/sounds/fail.mp3',
  );
}

@riverpod
FeedbackManager winFeedback(Ref ref) {
  final settings = ref.watch(settingsNotifierProvider).value;
  return FeedbackManager(
    enableSound: settings?.enableSound ?? true,
    enableHaptics: settings?.enableHaptics ?? true,
    hapticLevel: HapticLevel.medium,
    soundType: SoundType.custom,
    soundAsset: 'assets/sounds/win.mp3',
  );
}

@riverpod
FeedbackManager settingsFeedback(Ref ref) {
  final settings = ref.watch(settingsNotifierProvider).value;
  return FeedbackManager(
    enableSound: settings?.enableSound ?? true,
    enableHaptics: settings?.enableHaptics ?? true,
    hapticLevel: HapticLevel.selection,
    soundType: SoundType.systemClick,
  );
}
