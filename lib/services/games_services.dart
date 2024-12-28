import 'package:games_services/games_services.dart';

class GameServicesConstants {
  static const String androidLeaderboardID = 'CgkIi_-A4twQEAIQAQ';
  static const String iosLeaderboardID = '3F2734099F8448F28E609463FAABAB9D';
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
        // Wait a bit for sign-in to complete
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Double check sign in was successful
        if (!(await isSignedIn())) {
          print('Failed to sign in, cannot show leaderboard');
          return;
        }
      }

      // Try to show leaderboard
      try {
        await Leaderboards.showLeaderboards(
          androidLeaderboardID: GameServicesConstants.androidLeaderboardID,
          iOSLeaderboardID: GameServicesConstants.iosLeaderboardID,
        );
      } catch (e) {
        // If first attempt fails, try signing in again and retry
        print('First attempt to show leaderboard failed, retrying with fresh sign-in');
        await signIn();
        await Future.delayed(const Duration(milliseconds: 500));
        await Leaderboards.showLeaderboards(
          androidLeaderboardID: GameServicesConstants.androidLeaderboardID,
          iOSLeaderboardID: GameServicesConstants.iosLeaderboardID,
        );
      }
    } catch (e, stackTrace) {
      print('Error showing leaderboard: $e');
      print('Stack trace: $stackTrace');
    }
  }

  static Future<void> signIn() async {
    try {
      if (!(await isSignedIn())) {
        await GameAuth.signIn();
        print('GameAuth.isSignedIn: ${await GameAuth.isSignedIn}');
      }
    } catch (e) {
      print('Error signing in: $e');
    }
  }

  static Future<bool> isSignedIn() async {
    try {
      final signedIn = await GamesServices.isSignedIn;
      print('isSignedIn: $signedIn');
      return signedIn;
    } catch (e) {
      print('Error checking sign in status: $e');
      return false;
    }
  }

  static Future<int> getHighScore() async {
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

  static Future<List<LeaderboardScoreData>?> loadTopScores() async {
    try {
      if (!(await isSignedIn())) {
        await signIn();
      }
      return await Leaderboards.loadLeaderboardScores(
        androidLeaderboardID: GameServicesConstants.androidLeaderboardID,
        iOSLeaderboardID: GameServicesConstants.iosLeaderboardID,
        scope: PlayerScope.global,
        timeScope: TimeScope.allTime,
        maxResults: 3,
      );
    } catch (e) {
      print('Error loading top scores: $e');
      return null;
    }
  }
}
