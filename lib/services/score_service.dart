import 'package:block_puzzle_game/providers/score_provider.dart';
import 'package:block_puzzle_game/services/analytics_service.dart';
import 'package:block_puzzle_game/services/games_services.dart';

class ScoreService {
  static int _score = 0;
  static int _consecutiveClears = 0;
  
  static int get score => _score;
  static int get consecutiveClears => _consecutiveClears;

  static void reset() {
    _score = 0;
    _consecutiveClears = 0;
  }

  static late ScoreNotifier _scoreNotifier;
  
  static void initialize(ScoreNotifier notifier) {
    _scoreNotifier = notifier;
  }

  static void addBlockScore(int blockSize) {
    _score += blockSize * 10;
    _scoreNotifier.updateScore();
  }

  static void processLineClears(int totalClears) {
    if (totalClears > 0) {
      _consecutiveClears++;
      
      // Calculate multiplier based on consecutive clears
      double streakMultiplier = 1.0;
      if (_consecutiveClears >= 3) {
        streakMultiplier = 2.0;
      } else if (_consecutiveClears == 2) {
        streakMultiplier = 1.5;
      }

      // Calculate multiplier based on number of lines cleared in this move
      double linesMultiplier = totalClears.toDouble() * totalClears.toDouble(); // Square of lines cleared

      final double totalMultiplier = streakMultiplier * linesMultiplier;
      _score += (100 * totalMultiplier).toInt(); // Base score: 100 points per line
      _scoreNotifier.updateScore();
    } else {
      _consecutiveClears = 0;
    }
  }

  static Future<void> submitScore() async {
    await GameServicesService.submitScore(_score);
  }

  static Future<int?> getHighScore() async {
    if (await GameServicesService.isSignedIn()) {
      return GameServicesService.getHighScore();
    }
    return null;
  }
}
