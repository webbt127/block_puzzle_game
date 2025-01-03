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
FeedbackManager winFeedback(Ref ref) {
  final settings = ref.watch(settingsNotifierProvider).value;
  return FeedbackManager(
    enableSound: settings?.enableSound ?? true,
    enableHaptics: settings?.enableHaptics ?? true,
    hapticLevel: HapticLevel.medium,
    soundType: SoundType.custom,
    soundAsset: 'sounds/win.mp3',
  );
}

@riverpod
FeedbackManager failFeedback(Ref ref) {
  final settings = ref.watch(settingsNotifierProvider).value;
  return FeedbackManager(
    enableSound: settings?.enableSound ?? true,
    enableHaptics: settings?.enableHaptics ?? true,
    hapticLevel: HapticLevel.medium,
    soundType: SoundType.custom,
    soundAsset: 'sounds/fail.mp3',
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
