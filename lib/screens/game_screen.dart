import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:block_puzzle_game/providers/score_provider.dart';
import 'package:block_puzzle_game/screens/main_menu_screen.dart';
import 'package:block_puzzle_game/screens/settings_screen.dart';
import 'package:block_puzzle_game/screens/store_screen.dart';
import 'package:block_puzzle_game/services/pattern_service.dart';
import 'package:block_puzzle_game/services/store_service.dart';
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
import '../widgets/block_clear_effect.dart';
import '../pardon_popup.dart';
import '../services/ad_service.dart';
import '../services/games_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:block_puzzle_game/providers/settings_notifier.dart' as settings;
import '../services/analytics_service.dart';
import '../services/score_service.dart';
import '../services/game_save_service.dart';
import '../widgets/game_menu.dart';
import '../widgets/score_display.dart';
import 'package:block_puzzle_game/models/game_state.dart';
import '../widgets/whats_new_dialog.dart';
import 'package:block_puzzle_game/screens/how_to_play_screen.dart';
import '../services/logging_service.dart';

const int rows = 8;
const int columns = 8;

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late GridSystem gridSystem;
  int rerollCount = 0;
  List<List<bool>> gameBoard = List.generate(
    rows,
    (i) => List.generate(columns, (j) => false),
  );
  List<BlockPattern> availablePatterns = [];
  List<List<List<bool>>> patterns = [];
  GridPosition? previewPosition;
  BlockPattern? previewPattern;
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _hideAds = false;  // Track hide ads status
  List<int> potentialRowClears = [];
  List<int> potentialColumnClears = [];
  BlockClearEffect? _activeClearEffect;
  final GlobalKey _gridKey = GlobalKey();
  bool _pardonShownForCurrentStreak = false;

  static Future<void> _log(String message) async {
    await LoggingService.log('[GameScreen] $message');
  }

  @override
  void initState() {
    super.initState();
    _log('initState');
    // Initialize ScoreService with the score notifier
    ScoreService.initialize(ref.read(scoreProvider.notifier));
    _initializeGame();
    _checkHideAdsStatus();
    // Preload rewarded ad
    _log('Creating rewarded ad');
    AdService.loadRewardedAd();
    // Listen for ad availability changes
    AdService.addListener(_onAdAvailabilityChanged);
  }

  @override
  void dispose() {
    AdService.removeListener(_onAdAvailabilityChanged);
    _bannerAd?.dispose();
    //GridSystem.dispose();
    super.dispose();
  }

  void _onAdAvailabilityChanged() {
    _log('Ad availability changed, rebuilding UI');
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeGame() async {
    // Initialize grid system
    gridSystem = GridSystem(
      rows: rows,
      cols: columns,
      cellSize: 40,
    );

    _log('Initializing game...');

    // Try to load saved state
    final savedState = await GameSaveService.loadGame();
    
    if (savedState != null) {
      _log('Loaded saved state with score: ${savedState.score} and remaining rerolls: ${savedState.remainingRerolls}');
      setState(() {
        ScoreService.reset();
        ScoreService.addBlockScore(savedState.score ~/ 10); // Approximate block score
        ScoreService.processLineClears(savedState.consecutiveClears); // Restore consecutive clears
        rerollCount = 3 - savedState.remainingRerolls;
        gameBoard = savedState.gameBoard;
        availablePatterns = BlockPatterns.getPatternsFromSavedState(savedState.patterns);
      });
    } else {
      _log('No saved state found, starting new game');
      setState(() {
        ScoreService.reset();
        rerollCount = 0;
        gameBoard = List.generate(
          rows,
          (i) => List.generate(columns, (j) => false),
        );
        _generateNewPatterns();
      });
    }
  }

  Future<void> _saveGameState() async {
    _log('Saving game state... Score: ${ScoreService.score}, Remaining Rerolls: ${3 - rerollCount}');
    await GameSaveService.saveGame(
      gameBoard: gameBoard,
      availablePatterns: availablePatterns,
      rerollCount: rerollCount,
    );
  }

  void _handlePatternPlacement(BlockPattern pattern, GridPosition position) {
    setState(() {
      GameService.placePattern(pattern, position, gameBoard, gridSystem);
      
      // Remove used pattern
      availablePatterns.remove(pattern);
      if (availablePatterns.isEmpty) {
        _generateNewPatterns();
      }
      
      // Check for line clears
      _checkAndClearLines();
      
      // Check for game over
      if (_isGameOver()) {
        _showGameOverPopup();
      }
    });
    
    // Save state after the setState is complete
    unawaited(_saveGameState());
  }

  void _handleReroll() {
    _log('Handle reroll called');
    _log('hideAds: $_hideAds');
    _log('hasRewardedAd: ${AdService.hasRewardedAd}');
    
    if (_hideAds) {
      _log('User has hideAds, rerolling without ad');
      setState(() {
        rerollCount++;
        _generateNewPatterns(afterAd: true);
      });
      
      // Save state after the setState is complete
      unawaited(_saveGameState());
    } else if (AdService.hasRewardedAd) {
      _log('Showing rewarded ad for reroll');
      AdService.showRewardedAd(
        onUserEarnedReward: (_, __) {
          _log('User earned reward, rerolling');
          setState(() {
            rerollCount++;
            _generateNewPatterns(afterAd: true);
          });
          
          // Save state after the setState is complete
          unawaited(_saveGameState());
        },
      );
    } else {
      _log('No rewarded ad available');
    }
  }

  void _resetGame() {
    // Clear saved state first
    GameSaveService.clearSavedGame();

    // Show interstitial ad if available and ads aren't hidden
    if (!_hideAds) {
      if (AdService.hasInterstitialAd) {
        AdService.showInterstitialAd();
      }
      // Preload next interstitial
      AdService.createInterstitialAd();
    }
    
    setState(() {
      ScoreService.reset();
      rerollCount = 0;
      gameBoard = GameService.createEmptyBoard(rows, columns);
      _generateNewPatterns();
    });
  }

  Future<void> _checkHideAdsStatus() async {
    final hideAdsStatus = await ref.read(hasHideAdsProvider.future);
    setState(() {
      _hideAds = hideAdsStatus;
    });
    
    if (!_hideAds) {
      _loadBannerAd();
      // Show preloaded interstitial ad
      if (AdService.hasInterstitialAd) {
        AdService.showInterstitialAd();
      }
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

  Future<void> _rateApp() async {
    final Uri url = Platform.isIOS
        ? Uri.parse('https://apps.apple.com/app/6739540042')
        : Uri.parse('https://play.google.com/store/apps/details?id=com.apparchitects.blockpuzzle');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }


  void _placePattern(BlockPattern pattern, GridPosition position) {
    setState(() {
      gridSystem.placeBlockPattern(pattern, position, gameBoard);
      _checkAndClearLines();
    });
  }

  void _generateNewPatterns({bool afterAd = false}) {
    _log('Generating new patterns, afterAd: $afterAd');
    
    final newPatterns = PatternService.generateNewPatterns(
      afterAd: afterAd,
      gameBoard: gameBoard,
      gridSystem: gridSystem,
      rows: rows,
      columns: columns,
    );
    
    if (newPatterns.isEmpty && afterAd) {
      _log('No valid patterns found, showing game over');
      _showGameOverPopup();
      return;
    }
    
    setState(() {
      availablePatterns = newPatterns;
    });
  }

  bool _isGameOver() {
    return PatternService.isGameOver(
      availablePatterns: availablePatterns,
      gameBoard: gameBoard,
      gridSystem: gridSystem,
      rows: rows,
      columns: columns,
    );
  }

  void _showGameOverPopup() async {
    // Submit score and get high score
    await ScoreService.submitScore();
    final highScore = await ScoreService.getHighScore();
    
    // Log game over analytics
    AnalyticsService.logEvent('game_over', properties: {
      'score': ScoreService.score,
      'consecutive_clears': ScoreService.consecutiveClears,
    });

    // Add delay before showing popup
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    // Check if rerolls would even help
    final canReroll = PatternService.canAnyBlockFit(
      gameBoard: gameBoard,
      gridSystem: gridSystem,
      rows: rows,
      columns: columns,
    );
    
    showDialog(
      context: context,
      barrierDismissible: kDebugMode, // Allow dismissing in debug mode
      builder: (BuildContext context) {
        return GameOverPopup(
          finalScore: ScoreService.score,
          debugMode: kDebugMode, // Pass debug mode to popup
          initialHighScore: highScore, // Pass the high score
          hideAds: _hideAds,
          rerollsRemaining: canReroll ? 3 - rerollCount : 0,
          onReroll: (canReroll && rerollCount < 3) ? () async {
            if (!AdService.canShowRewardedAd(_hideAds)) {
              // If no ad is loaded, create one and wait a moment
              await AdService.loadRewardedAd();
              await Future.delayed(const Duration(milliseconds: 500));
            }
            if (!_hideAds && AdService.hasRewardedAd) {
              AdService.showRewardedAd(
                onUserEarnedReward: (Ad ad, RewardItem reward) {
                  _log('Reward earned, triggering reroll');
                  setState(() {
                    rerollCount++;
                    _generateNewPatterns(afterAd: true);
                  });
                  Navigator.of(context).pop(); // Dismiss the game over popup
                },
              );
            } else {
              setState(() {
                rerollCount++;
                _generateNewPatterns(afterAd: true);
              });
              Navigator.of(context).pop(); // Dismiss the game over popup
            }
          } : null,
          onRestart: () {
            // Play feedback
            final feedbackManager = ref.read(feedbackManagerProvider);
            //feedbackManager.playButtonPress();
            
            setState(() {
              // Reset game state
              gameBoard = List.generate(
                rows,
                (i) => List.generate(columns, (j) => false),
              );
              ScoreService.reset();
              rerollCount = 0;  // Reset reroll count
              _generateNewPatterns();
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _checkAndClearLines() {
    final rowsToClear = GameService.findFullRows(gameBoard, rows, columns);
    final colsToClear = GameService.findFullColumns(gameBoard, rows, columns);

    if (rowsToClear.isNotEmpty || colsToClear.isNotEmpty) {
      setState(() {
        GameService.clearLines(rowsToClear, colsToClear, gameBoard, columns, rows);

        // Check conditions for showing pardon popup
        final totalClears = rowsToClear.length + colsToClear.length;
        if (!_pardonShownForCurrentStreak && 
            (totalClears > 1 || ScoreService.consecutiveClears >= 3)) {
          _pardonShownForCurrentStreak = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (context) => const PardonPopup(),
            );
          });
        }
      });

      // Show clear effect
      _showClearEffect(rowsToClear, colsToClear);
      
      // Save state after clearing lines
      unawaited(_saveGameState());
    } else {
      ScoreService.processLineClears(0); // Reset consecutive clears
      _pardonShownForCurrentStreak = false;
    }
  }

  void _showClearEffect(List<int> rowsToClear, List<int> colsToClear) {
    if (!mounted) return;
    
    setState(() {
      // The effect will be added to the widget tree in build()
      _activeClearEffect = BlockClearEffect(
        clearedRows: rowsToClear,
        clearedColumns: colsToClear,
        cellSize: gridSystem.cellSize,
        gridPosition: Offset.zero,
        gridPadding: EdgeInsets.zero,
      );
      
      // Remove the effect after animation
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _activeClearEffect = null;
          });
        }
      });
    });
  }

  void _tryPlacePattern(BlockPattern pattern, int row, int col) async {
    if (gridSystem.canPlacePattern(pattern, GridPosition(row, col), gameBoard)) {
      // Log block placement analytics
      AnalyticsService.logEvent('block_placed', properties: {
        'pattern_size': pattern.shape.expand((row) => row).where((cell) => cell).length,
        'row': row,
        'col': col,
        'current_score': ScoreService.score,
      });
      
      setState(() {
        gridSystem.placeBlockPattern(pattern, GridPosition(row, col), gameBoard);
        ScoreService.addBlockScore(pattern.shape.expand((row) => row).where((cell) => cell).length);
        _checkAndClearLines();
        
        availablePatterns.remove(pattern);
        if (availablePatterns.isEmpty) {
          _generateNewPatterns();
        }
      });

      // Start the delayed game over check
      _delayedGameOverCheck();
    }
  }

  Future<void> _delayedGameOverCheck() async {
    // Wait for 5 seconds
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;

    // Check for game over after delay
    if (_isGameOver()) {
      _showGameOverPopup();
    }
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
    
    // Adjust the bounds check to account for the pattern height
    if (row >= -pattern.height && row < rows && col >= 0 && col < columns) {
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

  Widget _buildRerollButton() {
    final bool canReroll = rerollCount < 3 && (_hideAds || AdService.hasRewardedAd);
    
    if (!canReroll) return const SizedBox.shrink();
    
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _handleReroll,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh,
                  size: 36,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 4),
                Text(
                  '(${3 - rerollCount})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (!_hideAds && AdService.hasRewardedAd) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_circle_filled,
                          size: 8,
                        ),
                        SizedBox(width: 1),
                        Text(
                          'AD',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWhatsNew() {
    showDialog(
      context: context,
      builder: (context) => const WhatsNewDialog(),
    );
  }

  void _showHowToPlay() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HowToPlayScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Save state before exiting
        await _saveGameState();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GameMenu(
            onHome: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MainMenuScreen(),
                ),
              );
            },
            onLeaderboard: () {
              GameServicesService.showLeaderboard();
            },
            onStore: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const StoreScreen(),
                ),
              );
            },
            onRate: _rateApp,
            onSettings: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            onFeedback: () {
              ref.read(feedbackManagerProvider).playFeedback();
            },
            onRestart: _resetGame,
            onWhatsNew: _showWhatsNew,
            onHowToPlay: _showHowToPlay,
          ),
          actions: [
            const ScoreDisplay(),
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
                        margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8.0),
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
                            final cellSize = (smallestDimension - 4) / rows;  // 32 for margin
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
                                // Grid and drag target
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: math.max(0, horizontalPadding),
                                    right: math.max(0, horizontalPadding),
                                    top: math.max(0, verticalPadding),
                                    // Remove bottom padding to extend drag area
                                  ),
                                  child: SizedBox(
                                    width: gridSize,
                                    height: gridSize + ref.watch(settings.settingsNotifierProvider).value!.blockPlacementOffset.value,
                                    child: Stack(
                                      children: [
                                        // The grid itself stays square
                                        SizedBox(
                                          width: gridSize,
                                          height: gridSize,
                                          child: Stack(
                                            children: [
                                              CustomPaint(
                                                key: _gridKey,
                                                size: Size(gridSize, gridSize),
                                                painter: GridPainter(
                                                  grid: gridSystem,
                                                  gameBoard: gameBoard,
                                                  gridLineColor: Theme.of(context).brightness == Brightness.dark 
                                                    ? Colors.grey[700]! 
                                                    : const Color(0xFFE0E0E0),
                                                  highlightedPosition: previewPosition,
                                                  highlightedPattern: previewPattern,
                                                  onImageLoad: () {
                                                    if (mounted) setState(() {});
                                                  },
                                                  isDarkMode: Theme.of(context).brightness == Brightness.dark,
                                                ),
                                              ),
                                              GridOverlay(
                                                grid: gridSystem,
                                                gameBoard: gameBoard,
                                                gridLineColor: Theme.of(context).brightness == Brightness.dark 
                                                  ? Colors.grey[700]! 
                                                  : const Color(0xFFE0E0E0),
                                                highlightedPosition: previewPosition,
                                                highlightedPattern: previewPattern,
                                                isDarkMode: Theme.of(context).brightness == Brightness.dark,
                                              ),
                                              if (_activeClearEffect != null)
                                                _activeClearEffect!,
                                            ],
                                          ),
                                        ),
                                        // Wrap everything in a DragTarget that's taller than the grid
                                        DragTarget<BlockPattern>(
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
                                                _handlePatternPlacement(previewPattern!, previewPosition!);
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
                                            return Container(); // Empty container to receive drops
                                          },
                                        ),
                                      ],
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
                    height: 120,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    child: Row(
                      children: [
                        // Reroll button
                        _buildRerollButton(),
                        // Available blocks with original layout
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final itemWidth = (constraints.maxWidth - 32) / 3;
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: availablePatterns.map((pattern) {
                                  final smallCellSize = min(itemWidth / 5, gridSystem.cellSize * 0.4);
                                  final dragCellSize = gridSystem.cellSize * 0.75;
                                  return SizedBox(
                                    width: itemWidth,
                                    child: Center(
                                      child: SizedBox(
                                        width: pattern.width * dragCellSize * 1.2,
                                        height: pattern.height * dragCellSize * 1.2,
                                        child: Draggable<BlockPattern>(
                                          data: pattern,
                                          dragAnchorStrategy: (draggable, context, position) {
                                            final centerX = pattern.width * dragCellSize / 2;
                                            final centerY = pattern.height * dragCellSize / 2;
                                            return Offset(centerX, centerY + ref.watch(settings.settingsNotifierProvider).value!.blockPlacementOffset.value);
                                          },
                                          onDragStarted: () {
                                            ref.read(feedbackManagerProvider).playFeedback();
                                          },
                                          feedback: Transform.scale(
                                            scale: 1.3,
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
                      ],
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
      ),
    );
  }
}
