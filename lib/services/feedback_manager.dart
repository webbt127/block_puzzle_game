import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

enum HapticLevel {
  light,
  medium,
  heavy,
  selection,
}

enum SoundType {
  systemClick,
  systemAlert,
  custom,
}

class FeedbackManager {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool enableSound;
  bool enableHaptics;
  final HapticLevel hapticLevel;
  final SoundType soundType;
  final String? soundAsset;

  FeedbackManager({
    required this.enableSound,
    required this.enableHaptics,
    required this.hapticLevel,
    required this.soundType,
    this.soundAsset,
  }) {
    if (soundType == SoundType.custom && soundAsset != null) {
      _initAudio();
    }
  }

  Future<void> _initAudio() async {
    if (enableSound && soundType == SoundType.custom && soundAsset != null) {
      try {
        await _audioPlayer.setAsset(soundAsset!);
        await _audioPlayer.setVolume(0.5);
      } catch (e) {
        print('Error initializing audio: $e');
      }
    }
  }

  Future<void> playFeedback() async {
    if (enableHaptics) {
      switch (hapticLevel) {
        case HapticLevel.light:
          await HapticFeedback.lightImpact();
        case HapticLevel.medium:
          await HapticFeedback.mediumImpact();
        case HapticLevel.heavy:
          await HapticFeedback.heavyImpact();
        case HapticLevel.selection:
          await HapticFeedback.selectionClick();
      }
    }

    if (enableSound) {
      switch (soundType) {
        case SoundType.systemClick:
          await SystemSound.play(SystemSoundType.click);
        case SoundType.systemAlert:
          await SystemSound.play(SystemSoundType.alert);
        case SoundType.custom:
          if (soundAsset != null) {
            try {
              if (_audioPlayer.playing) {
                await _audioPlayer.stop();
              }
              await _audioPlayer.seek(Duration.zero);
              await _audioPlayer.play();
            } catch (e) {
              print('Error playing audio: $e');
            }
          }
      }
    }
  }

  void dispose() {
    if (soundType == SoundType.custom) {
      _audioPlayer.dispose();
    }
  }

  void updateSettings({bool? enableSound, bool? enableHaptics}) {
    if (enableSound != null) this.enableSound = enableSound;
    if (enableHaptics != null) this.enableHaptics = enableHaptics;
  }
}
