import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:block_puzzle_game/screens/game_screen.dart';
import 'package:block_puzzle_game/grid_system.dart';
import 'package:block_puzzle_game/block_patterns.dart';
import 'package:block_puzzle_game/services/games_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // // Mock game services
  // GameServicesService.submitScore = (int score) async {
  //   print('Mock: Submitting score $score');
  // };
  // GameServicesService.showLeaderboard = () async {
  //   print('Mock: Showing leaderboard');
  // };
  // GameServicesService.showLeaderboard();

  testWidgets('Game should eventually reach game over state', (WidgetTester tester) async {
    // Build our game screen with mocked providers
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: GameScreen(),
        ),
      ),
    );
    
    // Wait for initial frame
    await tester.pump();

    // Find the game screen state
    final gameScreenFinder = find.byType(GameScreen);
    final state = tester.state(gameScreenFinder);
    
    // Verify we have access to required state properties
    expect(state, isNotNull);
    expect((state as dynamic).gameBoard, isA<List<List<bool>>>());
    expect((state as dynamic).gridSystem, isA<GridSystem>());
    expect((state as dynamic).availablePatterns, isA<List<BlockPattern>>());
    
    bool isGameOver = false;
    int moveCount = 0;
    const maxMoves = 1000; // Prevent infinite loop
    
    while (!isGameOver && moveCount < maxMoves) {
      try {
        // Try to place each available pattern
        final patterns = List<BlockPattern>.from((state as dynamic).availablePatterns);
        bool placedPattern = false;
        
        // Print current board state
        print('\nMove $moveCount:');
        print('Current score: ${(state as dynamic).score}');
        print('Board state:');
        for (var row in (state as dynamic).gameBoard) {
          print(row.map((cell) => cell ? '■' : '□').join(''));
        }
        print('\nAvailable patterns:');
        for (var pattern in patterns) {
          print('Pattern shape:');
          for (var row in pattern.shape) {
            print(row.map((cell) => cell ? '■' : '□').join(''));
          }
          print('');
        }
        
        for (final pattern in patterns) {
          // Try every position on the board
          for (int row = 0; row < rows; row++) {
            for (int col = 0; col < columns; col++) {
              if ((state as dynamic).gridSystem.canPlacePattern(
                pattern,
                GridPosition(row, col),
                (state as dynamic).gameBoard,
              )) {
                print('Placing pattern at position ($row, $col)');
                
                // Place the pattern using test method
                (state as dynamic).testPlacePattern(pattern, row, col);
                await tester.pump(const Duration(milliseconds: 500)); // Slower animation
                
                // Wait for any clear animations to complete
                while ((state as dynamic).isAnimatingClear) {
                  print('Clearing lines...');
                  await tester.pump(const Duration(milliseconds: 200));
                }
                
                placedPattern = true;
                break;
              }
            }
            if (placedPattern) break;
          }
          if (placedPattern) break;
        }
        
        // Check if game is over using test property
        isGameOver = (state as dynamic).isGameOver;
        
        // If we're in game over state, print debug info
        if (isGameOver) {
          print('\nGAME OVER!');
          print('Final score: ${(state as dynamic).score}');
          print('Final board state:');
          for (var row in (state as dynamic).gameBoard) {
            print(row.map((cell) => cell ? '■' : '□').join(''));
          }
          
          // Call testCheckGameOver to show popup
          (state as dynamic).testCheckGameOver();
          
          // Wait for popup animation
          await tester.pump(const Duration(milliseconds: 500));
          
          // Dismiss any other dialogs that might be showing
          while (find.byType(Dialog).evaluate().length > 1) {
            print('Dismissing extra dialog');
            await tester.tapAt(const Offset(0, 0)); // Tap outside dialog to dismiss
            await tester.pump(const Duration(milliseconds: 200));
          }
        }
        
        moveCount++;
        await tester.pump(const Duration(milliseconds: 200));
        
      } catch (e, stackTrace) {
        print('Error during move $moveCount:');
        print('Error: $e');
        print('Stack trace: $stackTrace');
        break;
      }
    }

    // Verify game over state
    expect(isGameOver, true, reason: 'Game should have reached game over state');
    expect(moveCount, lessThan(maxMoves), reason: 'Game should end before max moves');
    
    // Verify game over popup is shown
    expect(find.byType(Dialog), findsOneWidget, reason: 'Game over popup should be shown');
    
    // Print final game state
    print('\nGame ended after $moveCount moves');
    print('Final score: ${(state as dynamic).score}');
  });
}
