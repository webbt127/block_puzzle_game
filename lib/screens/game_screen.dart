import 'dart:io';

import 'package:block_puzzle_game/screens/store_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:block_puzzle_game/providers/feedback_providers.dart';
import '../grid_system.dart';
import '../block_patterns.dart';
import '../game_over_popup.dart';
import '../widgets/patriotic_block_pattern.dart';
import '../widgets/patriotic_grid_overlay.dart';
import '../pardon_popup.dart';
import '../services/ad_service.dart';
import '../services/games_services.dart';
import '../services/revenue_cat_service.dart';
import 'package:url_launcher/url_launcher.dart';

const int rows = 8;
const int columns = 8;

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late GridSystem gridSystem;
  List<BlockPattern> availablePatterns = [];
  List<List<bool>> gameBoard = List.generate(
    rows,
    (i) => List.generate(columns, (j) => false),
  );
  int score = 0;
  int consecutiveClears = 0;  // Track consecutive clears
  GridPosition? previewPosition;
  BlockPattern? previewPattern;
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _hideAds = false;  // Track hide ads status

  @override
  void initState() {
    super.initState();
    gridSystem = GridSystem(
      rows: rows,
      cols: columns,
      cellSize: 40,
    );
    _generateNewPatterns();
    _checkHideAdsStatus();
  }

  Future<void> _checkHideAdsStatus() async {
    final hideAdsStatus = await ref.read(hasHideAdsProvider.future);
    setState(() {
      _hideAds = hideAdsStatus;
    });
    
    if (!_hideAds) {
      _loadBannerAd();
      // Load and show interstitial ad at game start
      AdService.createInterstitialAd();
      Future.delayed(const Duration(milliseconds: 500), () {
        AdService.showInterstitialAd();
      });
    }
  }

  void _loadBannerAd() {
    if (_hideAds) return;  // Don't load ad if ads are hidden
    
    _bannerAd = AdService.createBannerAd();
    _bannerAd?.load().then((_) {
      setState(() {
        _isAdLoaded = true;
      });
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    //GridSystem.dispose();
    super.dispose();
  }

  Future<void> _rateApp() async {
    final Uri url = Platform.isIOS
        ? Uri.parse('https://apps.apple.com/app/6739540042')
        : Uri.parse('https://play.google.com/store/apps/details?id=com.apparchitects.blockpuzzle');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _generateNewPatterns() {
    setState(() {
      availablePatterns = BlockPatterns.getRandomPatterns(3);
    });
  }

  void _placePattern(BlockPattern pattern, GridPosition position) {
    setState(() {
      gridSystem.placeBlockPattern(pattern, position, gameBoard);
      _checkAndClearLines();
    });
  }

  bool _isGameOver() {
    // Check if any available pattern can be placed anywhere on the board
    for (final pattern in availablePatterns) {
      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns; col++) {
          if (gridSystem.canPlacePattern(
            pattern,
            GridPosition(row, col),
            gameBoard,
          )) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void _showGameOverPopup() {
    // Submit score to Game Center
    GameServicesService.submitScore(score);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GameOverPopup(
          finalScore: score,
          onRestart: () {
            setState(() {
              gameBoard = List.generate(
                rows,
                (i) => List.generate(columns, (j) => false),
              );
              score = 0;
              consecutiveClears = 0;
              _generateNewPatterns();
            });
            
            // Show interstitial ad on replay
            if (!_hideAds) {
              AdService.showInterstitialAd();
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _checkAndClearLines() {
    bool needsUpdate = false;
    int clearedLines = 0;
    
    // Check rows
    for (int row = 0; row < rows; row++) {
      if (gameBoard[row].every((cell) => cell)) {
        gameBoard[row] = List.generate(columns, (j) => false);
        clearedLines++;
        needsUpdate = true;
      }
    }
    
    // Check columns
    for (int col = 0; col < columns; col++) {
      if (List.generate(rows, (row) => gameBoard[row][col]).every((cell) => cell)) {
        for (int row = 0; row < rows; row++) {
          gameBoard[row][col] = false;
        }
        clearedLines++;
        needsUpdate = true;
      }
    }
    
    if (needsUpdate) {
      // Calculate score with multipliers
      int clearScore = 0;
      
      // Base score for cleared lines (100 points per line)
      clearScore = clearedLines * 100;
      
      // Multiple lines cleared multiplier (2x for 2 lines, 3x for 3+ lines)
      if (clearedLines >= 3) {
        clearScore *= 3;
      } else if (clearedLines == 2) {
        clearScore *= 2;
      }
      
      // Consecutive clear multiplier (1.5x for second clear, 2x for third and beyond)
      if (consecutiveClears > 0) {
        clearScore = (clearScore * (consecutiveClears >= 2 ? 2.0 : 1.5)).toInt();
      }
      
      score += clearScore;
      consecutiveClears++;
      
      setState(() {});
      
      // Show pardon popup if 1 or more lines were cleared
      if (clearedLines >= 2 || consecutiveClears >= 2) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const PardonPopup();
          },
        );
      }
    } else {
      // Reset consecutive clears if no lines were cleared
      consecutiveClears = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: Colors.blue, size: 32),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'home',
              child: ListTile(
                leading: const Icon(Icons.home, color: Colors.blue),
                title: const Text('Home'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'leaderboard',
              child: ListTile(
                leading: const Icon(Icons.leaderboard_outlined, color: Colors.blue),
                title: const Text('Leaderboard'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'store',
              child: ListTile(
                leading: const Icon(Icons.shopping_bag_outlined, color: Colors.blue),
                title: const Text('Store'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'rate',
              child: ListTile(
                leading: const Icon(Icons.star_border, color: Colors.blue),
                title: const Text('Rate App'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'settings',
              child: ListTile(
                leading: const Icon(Icons.settings, color: Colors.blue),
                title: const Text('Settings'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          onSelected: (String value) async {
            // Play feedback for all menu interactions
            await ref.read(feedbackManagerProvider).playFeedback();
            if (!context.mounted) return;

            switch (value) {
              case 'home':
                Navigator.of(context).pop();
                break;
              case 'leaderboard':
                GameServicesService.showLeaderboard();
                break;
              case 'store':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StoreScreen(),
                  ),
                );
                break;
              case 'rate':
                await _rateApp();
                break;
              case 'settings':
                Navigator.of(context).pushNamed('/settings');
                break;
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              'Score: $score',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[850]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                            Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Update grid cell size based on available space
                      final smallestDimension = math.min(constraints.maxWidth, constraints.maxHeight);
                      final cellSize = (smallestDimension - 32) / rows;  // 32 for margin
                      final gridSize = cellSize * rows;  // Total grid size
                      
                      // Calculate centering padding
                      final horizontalPadding = (constraints.maxWidth - gridSize) / 2;
                      final verticalPadding = (constraints.maxHeight - gridSize) / 2;
                      
                      gridSystem = GridSystem(
                        rows: rows,
                        cols: columns,
                        cellSize: cellSize,
                      );
                      
                      return Stack(
                        children: [
                          // Patriotic grid overlay for filled cells
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: math.max(0, horizontalPadding),
                              vertical: math.max(0, verticalPadding),
                            ),
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: PatrioticGridOverlay(
                                gameBoard: gameBoard,
                                cellSize: cellSize,
                              ),
                            ),
                          ),
                          // Grid and drag target
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: math.max(0, horizontalPadding),
                              vertical: math.max(0, verticalPadding),
                            ),
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: DragTarget<BlockPattern>(
                                onWillAccept: (data) => true,
                                onAcceptWithDetails: (details) async {
                                  if (previewPosition != null && previewPattern != null) {
                                    final isValid = gridSystem.canPlacePattern(
                                      previewPattern!,
                                      previewPosition!,
                                      gameBoard,
                                    );
                                    if (isValid) {
                                      await ref.read(feedbackManagerProvider).playFeedback();
                                      
                                      // Calculate score before clearing the preview
                                      final blockScore = previewPattern!.shape
                                          .expand((row) => row)
                                          .where((cell) => cell)
                                          .length * 10;  // 10 points per block cell
                                      
                                      setState(() {
                                        gridSystem.placeBlockPattern(
                                          previewPattern!,
                                          previewPosition!,
                                          gameBoard,
                                        );
                                        score += blockScore;  // Add block placement score
                                        _checkAndClearLines();
                                        
                                        // Remove used pattern and check for game over
                                        availablePatterns.remove(previewPattern);
                                        if (availablePatterns.isEmpty) {
                                          _generateNewPatterns();
                                        }
                                        
                                        // Check for game over after pattern placement
                                        if (_isGameOver()) {
                                          _showGameOverPopup();
                                        }
                                      });
                                    }
                                    // Clear preview in all cases
                                    setState(() {
                                      previewPosition = null;
                                      previewPattern = null;
                                    });
                                  }
                                },
                                onLeave: (data) {
                                  setState(() {
                                    previewPosition = null;
                                    previewPattern = null;
                                  });
                                },
                                onMove: (details) {
                                  final position = gridSystem.getCenteredPatternPosition(
                                    details.data,
                                    details.offset,
                                    context,
                                  );
                                  setState(() {
                                    previewPosition = position;
                                    previewPattern = details.data;
                                  });
                                },
                                builder: (context, candidateData, rejectedData) {
                                  return GridOverlay(
                                    grid: gridSystem,
                                    gameBoard: gameBoard,
                                    gridLineColor: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.grey[700]! 
                                      : const Color(0xFFE0E0E0),
                                    highlightedPosition: previewPosition,
                                    highlightedPattern: previewPattern,
                                    isDarkMode: Theme.of(context).brightness == Brightness.dark,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              constraints: const BoxConstraints(maxHeight: 120), 
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[850]
                    : Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                        Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - 32) / 3; 
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: availablePatterns.map((pattern) {
                      final smallCellSize = min(itemWidth / 5, gridSystem.cellSize * 0.4); // Smaller size for available blocks
                      final dragCellSize = gridSystem.cellSize * 0.75; // Larger size when dragging
                      return SizedBox(
                        width: itemWidth,
                        child: Center(
                          child: SizedBox(
                            width: pattern.width * dragCellSize * 1.2,
                            height: pattern.height * dragCellSize * 1.2,
                            child: Draggable<BlockPattern>(
                              data: pattern,
                              dragAnchorStrategy: (draggable, context, position) {
                                // Return the center of the pattern
                                return Offset(
                                  pattern.width * dragCellSize / 2,
                                  pattern.height * dragCellSize / 2
                                );
                              },
                              onDragStarted: () {
                                ref.read(feedbackManagerProvider).playFeedback();
                              },
                              feedback: Transform.scale(
                                scale: 1.3, // Slightly larger when dragging
                                child: PatrioticBlockPattern(
                                  pattern: pattern,
                                  cellSize: dragCellSize,
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: PatrioticBlockPattern(
                                  pattern: pattern,
                                  cellSize: smallCellSize,
                                ),
                              ),
                              child: Container(
                            padding: const EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey[900]
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.blue.withOpacity(0.3)
                                        : Colors.blue.withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: PatrioticBlockPattern(
                                    pattern: pattern,
                                    cellSize: smallCellSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            if (!_hideAds && _bannerAd != null && _isAdLoaded)
              Container(
                alignment: Alignment.bottomCenter,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}
