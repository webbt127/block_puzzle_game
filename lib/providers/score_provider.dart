import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/score_service.dart';

final scoreProvider = StateNotifierProvider<ScoreNotifier, int>((ref) {
  return ScoreNotifier();
});

class ScoreNotifier extends StateNotifier<int> {
  ScoreNotifier() : super(ScoreService.score) {
    // Initialize with current score
    state = ScoreService.score;
  }

  void updateScore() {
    state = ScoreService.score;
  }
}
