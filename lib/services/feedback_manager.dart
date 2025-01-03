import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

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
  bool _isAudioReady = false;
  Source? _audioSource;

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
        _audioSource = AssetSource(soundAsset!);
        await _audioPlayer.setSource(_audioSource!);
        await _audioPlayer.setVolume(0.5);
        _isAudioReady = true;
        print('Audio initialized successfully: $soundAsset');
      } catch (e) {
        print('Error initializing audio: $e');
        _isAudioReady = false;
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
          if (soundAsset != null && _audioSource != null) {
            try {
              if (_isAudioReady) {
                await _audioPlayer.stop();
                await _audioPlayer.seek(Duration.zero);
                await _audioPlayer.resume();
                print('Audio playback started');
              } else {
                print('Attempting to reinitialize audio...');
                await _initAudio();
                if (_isAudioReady) {
                  await _audioPlayer.resume();
                }
              }
            } catch (e) {
              print('Error playing audio: $e');
              _isAudioReady = false;
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
