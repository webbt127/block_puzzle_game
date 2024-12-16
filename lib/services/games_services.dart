import 'package:games_services/games_services.dart';

class GameServicesConstants {
  static const String androidLeaderboardID = '';
  static const String iosLeaderboardID = '';
}

class GameServicesService {
  static Future<void> submitScore(int value) async {
    try {
      if (!(await isSignedIn())) {
        await signIn();
      }
      final score = Score(
        androidLeaderboardID: GameServicesConstants.androidLeaderboardID,
        iOSLeaderboardID: GameServicesConstants.iosLeaderboardID,
        value: value,
      );

      await Leaderboards.submitScore(score: score);
    } catch (e) {
      print('Error submitting score: $e');
    }
  }

  static Future<void> showLeaderboard() async {
    try {
      if (!(await isSignedIn())) {
        await signIn();
      }
      await Leaderboards.showLeaderboards(
        androidLeaderboardID: GameServicesConstants.androidLeaderboardID,
        iOSLeaderboardID: GameServicesConstants.iosLeaderboardID,
      );
    } catch (e) {
      print('Error showing leaderboard: $e');
    }
  }

  static Future<void> signIn() async {
    try {
      await GameAuth.signIn();
      print('GameAuth.isSignedIn: ${await GameAuth.isSignedIn}');
    } catch (e) {
      print('Error signing in: $e');
    }
  }

  static Future<bool> isSignedIn() async {
    print('isSignedIn: ${await GamesServices.isSignedIn}');
    return await GamesServices.isSignedIn;
  }

  // Add method to get high score
  Future<int> getHighScore() async {
    try {
      if (!(await isSignedIn())) {
        await signIn();
      }
      return await Player.getPlayerScore(
        androidLeaderboardID: GameServicesConstants.androidLeaderboardID,
        iOSLeaderboardID: GameServicesConstants.iosLeaderboardID,
      ) ?? 0;
    } catch (e) {
      print('Error getting high score: $e');
      return 0;
    }
  }
}
