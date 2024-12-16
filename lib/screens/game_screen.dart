import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:math' as math;
import '../grid_system.dart';
import '../block_patterns.dart';
import '../game_over_popup.dart';

const int rows = 10;
const int columns = 10;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GridSystem gridSystem;
  List<BlockPattern> availablePatterns = [];
  List<List<bool>> gameBoard = List.generate(
    rows,
    (i) => List.generate(columns, (j) => false),
  );
  int score = 0;
  GridPosition? previewPosition;
  BlockPattern? previewPattern;

  @override
  void initState() {
    super.initState();
    gridSystem = GridSystem(
      rows: rows,
      cols: columns,
      cellSize: 40,
    );
    _generateNewPatterns();
  }

  @override
  void dispose() {
    GridSystem.dispose();
    super.dispose();
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
              _generateNewPatterns();
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _checkAndClearLines() {
    bool needsUpdate = false;
    
    // Check rows
    for (int row = 0; row < rows; row++) {
      if (gameBoard[row].every((cell) => cell)) {
        gameBoard[row] = List.generate(columns, (j) => false);
        score += columns;
        needsUpdate = true;
      }
    }
    
    // Check columns
    for (int col = 0; col < columns; col++) {
      if (List.generate(rows, (row) => gameBoard[row][col]).every((cell) => cell)) {
        for (int row = 0; row < rows; row++) {
          gameBoard[row][col] = false;
        }
        score += rows;
        needsUpdate = true;
      }
    }
    
    if (needsUpdate) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score: $score',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
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
                        if (GridSystem.videoController?.value.isInitialized ?? false)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: math.max(0, horizontalPadding),
                              vertical: math.max(0, verticalPadding),
                            ),
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: ClipRect(
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: GridSystem.videoController!.value.size.width,
                                    height: GridSystem.videoController!.value.size.height,
                                    child: VideoPlayer(GridSystem.videoController!),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: math.max(0, horizontalPadding),
                            vertical: math.max(0, verticalPadding),
                          ),
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: DragTarget<BlockPattern>(
                              onWillAccept: (data) => true,
                              onAcceptWithDetails: (details) {
                                if (previewPosition != null && previewPattern != null) {
                                  final isValid = gridSystem.canPlacePattern(
                                    previewPattern!,
                                    previewPosition!,
                                    gameBoard,
                                  );
                                  if (isValid) {
                                    // Calculate score before clearing the preview
                                    final blockScore = previewPattern!.shape
                                        .expand((row) => row)
                                        .where((cell) => cell)
                                        .length;
                                    
                                    setState(() {
                                      gridSystem.placeBlockPattern(
                                        previewPattern!,
                                        previewPosition!,
                                        gameBoard,
                                      );
                                      _checkAndClearLines();
                                      score += blockScore;
                                      
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
                                return CustomPaint(
                                  key: gridSystem.gridKey,
                                  painter: GridPainter(
                                    grid: gridSystem,
                                    gameBoard: gameBoard,
                                    gridLineColor: Colors.blue.withOpacity(0.2),
                                    highlightedPosition: previewPosition,
                                    highlightedPattern: previewPattern,
                                    onImageLoad: () {},
                                  ),
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
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, -2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Available Blocks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: gridSystem.cellSize * 3.5,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: availablePatterns.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemBuilder: (context, index) {
                      return Draggable<BlockPattern>(
                        data: availablePatterns[index],
                        feedback: BlockPatternWidget(
                          pattern: availablePatterns[index],
                          cellSize: gridSystem.cellSize * 0.75,
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: BlockPatternWidget(
                            pattern: availablePatterns[index],
                            cellSize: gridSystem.cellSize * 0.75,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: BlockPatternWidget(
                            pattern: availablePatterns[index],
                            cellSize: gridSystem.cellSize * 0.75,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
