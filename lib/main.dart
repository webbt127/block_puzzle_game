import 'package:flutter/material.dart';
import 'block_patterns.dart';
import 'grid_system.dart';
import 'dart:math' as math;

void main() {
  runApp(const BlockPuzzleGame());
}

class BlockPuzzleGame extends StatelessWidget {
  const BlockPuzzleGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Block Puzzle Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int rows = 10;
  static const int columns = 10;
  late List<List<bool>> gameBoard;
  late List<BlockPattern> availablePatterns;
  late GridSystem gridSystem;
  GridPosition? previewPosition;
  BlockPattern? previewPattern;
  int score = 0;

  @override
  void initState() {
    super.initState();
    gameBoard = List.generate(
      rows,
      (i) => List.generate(columns, (j) => false),
    );
    _generateNewPatterns();
  }

  void _generateNewPatterns() {
    availablePatterns = BlockPatternGenerator.generateRandomPatterns(3);
    setState(() {});
  }

  void _placePattern(BlockPattern pattern, GridPosition position) {
    if (!gridSystem.canPlacePattern(pattern, position, gameBoard)) return;

    setState(() {
      for (int i = 0; i < pattern.height; i++) {
        for (int j = 0; j < pattern.width; j++) {
          if (pattern.shape[i][j]) {
            gameBoard[position.row + i][position.col + j] = true;
          }
        }
      }
      availablePatterns.remove(pattern);
      if (availablePatterns.isEmpty) {
        _generateNewPatterns();
      }
      _checkAndClearLines();
    });
  }

  void _checkAndClearLines() {
    bool needsUpdate = false;
    
    // Check rows
    for (int i = 0; i < rows; i++) {
      if (gameBoard[i].every((cell) => cell)) {
        gameBoard[i] = List.generate(columns, (j) => false);
        score += 100;
        needsUpdate = true;
      }
    }

    // Check columns
    for (int j = 0; j < columns; j++) {
      if (List.generate(rows, (i) => gameBoard[i][j]).every((cell) => cell)) {
        for (int i = 0; i < rows; i++) {
          gameBoard[i][j] = false;
        }
        score += 100;
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
      appBar: AppBar(
        title: const Text('Block Puzzle'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Score: $score',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate sizes based on available space
          final availableHeight = constraints.maxHeight;
          final availableWidth = constraints.maxWidth;
          
          // Reserve space for the block bank (20% of height)
          final blockBankHeight = availableHeight * 0.2;
          
          // Calculate grid size to fit in remaining space
          final maxGridSize = math.min(
            availableWidth - 32, // Account for horizontal padding
            availableHeight - blockBankHeight - 32, // Account for vertical padding
          );
          
          final cellSize = (maxGridSize / columns).floorToDouble();
          final actualGridSize = cellSize * columns;
          
          gridSystem = GridSystem(
            rows: rows,
            cols: columns,
            cellSize: cellSize,
          );

          return Column(
            children: [
              // Grid section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: SizedBox(
                    width: actualGridSize,
                    height: actualGridSize,
                    child: DragTarget<BlockPattern>(
                      onWillAccept: (pattern) => true,
                      onAcceptWithDetails: (details) {
                        if (previewPosition != null && previewPattern != null) {
                          _placePattern(previewPattern!, previewPosition!);
                        }
                        setState(() {
                          previewPosition = null;
                          previewPattern = null;
                        });
                      },
                      onMove: (details) {
                        final RenderBox? gridBox = gridSystem.gridKey.currentContext?.findRenderObject() as RenderBox?;
                        if (gridBox != null) {
                          final localPosition = gridBox.globalToLocal(details.offset);
                          
                          // Only update if the position is within the grid bounds
                          if (localPosition.dx >= 0 && 
                              localPosition.dx <= gridBox.size.width &&
                              localPosition.dy >= 0 && 
                              localPosition.dy <= gridBox.size.height) {
                            
                            final newPosition = gridSystem.getCenteredPatternPosition(
                              details.data,
                              details.offset,
                              context,
                            );
                            
                            setState(() {
                              previewPosition = newPosition;
                              previewPattern = details.data;
                            });
                          }
                        }
                      },
                      onLeave: (data) {
                        setState(() {
                          previewPosition = null;
                          previewPattern = null;
                        });
                      },
                      builder: (context, candidateData, rejectedData) {
                        return GridOverlay(
                          grid: gridSystem,
                          gameBoard: gameBoard,
                          highlightedPosition: previewPosition,
                          highlightedPattern: previewPattern,
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Block bank section
              Container(
                height: blockBankHeight,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: availablePatterns.map((pattern) {
                      return Center(
                        child: Draggable<BlockPattern>(
                          data: pattern,
                          feedback: Container(
                            width: pattern.width * gridSystem.cellSize,
                            height: pattern.height * gridSystem.cellSize,
                            child: CustomPaint(
                              painter: BlockPatternPainter(
                                pattern: pattern,
                                cellSize: gridSystem.cellSize,
                                color: pattern.color.withOpacity(0.7),
                              ),
                            ),
                          ),
                          feedbackOffset: Offset(
                            -pattern.width * gridSystem.cellSize / 2,
                            -pattern.height * gridSystem.cellSize / 2,
                          ),
                          childWhenDragging: Container(
                            width: pattern.width * gridSystem.cellSize,
                            height: pattern.height * gridSystem.cellSize,
                            child: CustomPaint(
                              painter: BlockPatternPainter(
                                pattern: pattern,
                                cellSize: gridSystem.cellSize,
                                color: pattern.color.withOpacity(0.3),
                              ),
                            ),
                          ),
                          child: Container(
                            width: pattern.width * gridSystem.cellSize,
                            height: pattern.height * gridSystem.cellSize,
                            child: CustomPaint(
                              painter: BlockPatternPainter(
                                pattern: pattern,
                                cellSize: gridSystem.cellSize,
                                color: pattern.color,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
