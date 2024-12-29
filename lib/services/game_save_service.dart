import 'package:block_puzzle_game/models/game_state.dart';
import 'package:block_puzzle_game/services/score_service.dart';
import 'package:block_puzzle_game/block_patterns.dart';

class GameSaveService {
  static Future<void> saveGame({
    required List<List<bool>> gameBoard,
    required List<BlockPattern> availablePatterns,
    required int rerollCount,
  }) async {
    final state = GameState(
      score: ScoreService.score,
      rerollCount: rerollCount,
      consecutiveClears: ScoreService.consecutiveClears,
      gameBoard: gameBoard,
      patterns: BlockPatterns.getSavedStateFromPatterns(availablePatterns),
      remainingRerolls: 3 - rerollCount,
    );
    await state.save();
  }

  static Future<GameState?> loadGame() async {
    return await GameState.load();
  }

  static Future<void> clearSavedGame() async {
    await GameState.clear();
  }
}
