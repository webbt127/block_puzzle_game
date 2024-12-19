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
import '../widgets/potential_clear_overlay.dart';
import '../widgets/clear_animation_overlay.dart';
import '../pardon_popup.dart';
import '../services/ad_service.dart';
import '../services/games_services.dart';
import '../services/revenue_cat_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

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
  List<int> potentialRowClears = [];
  List<int> potentialColumnClears = [];
  bool isAnimatingClear = false;
  List<int> rowsBeingCleared = [];
  List<int> columnsBeingCleared = [];

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
    final rowsToClear = <int>[];
    final columnsToClear = <int>[];

    // Check rows
    for (int i = 0; i < rows; i++) {
      if (gameBoard[i].every((cell) => cell)) {
        rowsToClear.add(i);
      }
    }

    // Check columns
    for (int j = 0; j < columns; j++) {
      bool fullColumn = true;
      for (int i = 0; i < rows; i++) {
        if (!gameBoard[i][j]) {
          fullColumn = false;
          break;
        }
      }
      if (fullColumn) {
        columnsToClear.add(j);
      }
    }

    if (rowsToClear.isNotEmpty || columnsToClear.isNotEmpty) {
      // Increment consecutive clears if lines were cleared
      consecutiveClears++;
      
      // Show pardon popup for multiple lines or consecutive clears
      if (rowsToClear.length + columnsToClear.length >= 2 || consecutiveClears >= 2) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const PardonPopup();
          },
        );
      }

      setState(() {
        isAnimatingClear = true;
        rowsBeingCleared = rowsToClear;
        columnsBeingCleared = columnsToClear;
      });
    } else {
      // Reset consecutive clears if no lines were cleared
      consecutiveClears = 0;
    }
  }

  void _onClearAnimationComplete() {
    setState(() {
      isAnimatingClear = false;
      rowsBeingCleared = [];
      columnsBeingCleared = [];
    });
  }

  void _updatePotentialClears() {
    if (previewPosition == null || previewPattern == null) {
      setState(() {
        potentialRowClears = [];
        potentialColumnClears = [];
      });
      return;
    }

    // First check if placement is valid
    if (!gridSystem.canPlacePattern(
      previewPattern!,
      GridPosition(previewPosition!.row, previewPosition!.col),
      gameBoard,
    )) {
      setState(() {
        potentialRowClears = [];
        potentialColumnClears = [];
      });
      return;
    }

    final tempBoard = List.generate(
      rows,
      (i) => List<bool>.from(gameBoard[i]),
    );

    // Place preview pattern on temp board
    gridSystem.placeBlockPattern(
      previewPattern!,
      GridPosition(previewPosition!.row, previewPosition!.col),
      tempBoard,
    );

    // Check for potential row clears
    final newRowClears = <int>[];
    for (int i = 0; i < rows; i++) {
      if (tempBoard[i].every((cell) => cell)) {
        newRowClears.add(i);
      }
    }

    // Check for potential column clears
    final newColumnClears = <int>[];
    for (int j = 0; j < columns; j++) {
      bool fullColumn = true;
      for (int i = 0; i < rows; i++) {
        if (!tempBoard[i][j]) {
          fullColumn = false;
          break;
        }
      }
      if (fullColumn) {
        newColumnClears.add(j);
      }
    }

    setState(() {
      potentialRowClears = newRowClears;
      potentialColumnClears = newColumnClears;
    });
  }

  void _onDragUpdate(DragUpdateDetails details, BlockPattern pattern) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    final row = (localPosition.dy / gridSystem.cellSize).floor();
    final col = (localPosition.dx / gridSystem.cellSize).floor();
    
    if (row >= 0 && row < rows && col >= 0 && col < columns) {
      setState(() {
        previewPosition = GridPosition(row, col);
        previewPattern = pattern;
      });
      _updatePotentialClears();
    } else {
      setState(() {
        previewPosition = null;
        previewPattern = null;
      });
      _updatePotentialClears();
    }
  }

  void _onDragEnd(DragEndDetails details, BlockPattern pattern) {
    if (previewPosition != null) {
      _tryPlacePattern(pattern, previewPosition!.row, previewPosition!.col);
    }
    setState(() {
      previewPosition = null;
      previewPattern = null;
    });
    _updatePotentialClears();
  }

  void _tryPlacePattern(BlockPattern pattern, int row, int col) {
    if (gridSystem.canPlacePattern(pattern, GridPosition(row, col), gameBoard)) {
      setState(() {
        gridSystem.placeBlockPattern(pattern, GridPosition(row, col), gameBoard);
        score += pattern.shape.expand((row) => row).where((cell) => cell).length * 10;  // 10 points per block cell
        _checkAndClearLines();
        
        // Remove used pattern and check for game over
        availablePatterns.remove(pattern);
        if (availablePatterns.isEmpty) {
          _generateNewPatterns();
        }
        
        // Check for game over after pattern placement
        if (_isGameOver()) {
          _showGameOverPopup();
        }
      });
    }
  }

  void _onBlockClear(int row, int col) {
    setState(() {
      gameBoard[row][col] = false;
      
      // Add points for the cleared block
      if (rowsBeingCleared.contains(row)) {
        score += 10; // Points for row clear
      }
      if (columnsBeingCleared.contains(col) && !rowsBeingCleared.contains(row)) {
        score += 10; // Points for column clear (if not already counted in row)
      }
    });
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
        child: Stack(
          children: [
            Column(
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
                                    isDarkMode: Theme.of(context).brightness == Brightness.dark,
                                  ),
                                ),
                              ),
                              // Potential clear overlay
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: math.max(0, horizontalPadding),
                                  vertical: math.max(0, verticalPadding),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: PotentialClearOverlay(
                                    potentialRowClears: potentialRowClears,
                                    potentialColumnClears: potentialColumnClears,
                                    cellSize: cellSize,
                                  ),
                                ),
                              ),
                              if (isAnimatingClear)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: math.max(0, horizontalPadding),
                                    vertical: math.max(0, verticalPadding),
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 1.0,
                                    child: ClearAnimationOverlay(
                                      rowsToClear: rowsBeingCleared,
                                      columnsToClear: columnsBeingCleared,
                                      cellSize: cellSize,
                                      onAnimationComplete: _onClearAnimationComplete,
                                      onBlockClear: _onBlockClear,
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
                                        _updatePotentialClears();
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
                                      isDarkMode: Theme.of(context).brightness == Brightness.dark,
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.5,
                                    child: PatrioticBlockPattern(
                                      pattern: pattern,
                                      cellSize: dragCellSize,
                                      isDarkMode: Theme.of(context).brightness == Brightness.dark,
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
                                        isDarkMode: Theme.of(context).brightness == Brightness.dark,
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
            if (kDebugMode)
              Positioned(
                bottom: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      heroTag: 'game_over_debug',
                      onPressed: () => _showGameOverPopup(),
                      child: const Icon(Icons.close),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: 'pardon_debug',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const PardonPopup(),
                        );
                      },
                      child: const Icon(Icons.bug_report),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
