import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'block_patterns.dart';
import 'dart:math';
import 'dart:ui' as ui;

class GridPosition {
  final int row;
  final int col;

  const GridPosition(this.row, this.col);

  @override
  String toString() => 'GridPosition(row: $row, col: $col)';
}

class GridSystem {
  final int rows;
  final int cols;
  final double cellSize;
  final EdgeInsets padding;
  final GlobalKey gridKey = GlobalKey();
  static VideoPlayerController? videoController;

  GridSystem({
    required this.rows,
    required this.cols,
    required this.cellSize,
    this.padding = const EdgeInsets.all(16.0),
  }) {
    _initializeVideo();
  }

  void _initializeVideo() async {
    videoController ??= VideoPlayerController.asset('assets/flag_wave.mp4')
        ..setLooping(true)
        ..initialize().then((_) {
          videoController?.play();
        });
  }

  static void dispose() {
    videoController?.dispose();
    videoController = null;
  }

  // Helper method to get grid box
  RenderBox? _getGridRenderBox() {
    return gridKey.currentContext?.findRenderObject() as RenderBox?;
  }

  // Helper method to clamp a value between min and max
  int _clampInt(int value, int min, int max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  double _clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  // Convert screen coordinates to grid position
  GridPosition getGridPosition(Offset screenPosition, BuildContext context) {
    final RenderBox? gridBox = _getGridRenderBox();
    if (gridBox == null) return const GridPosition(0, 0);

    // Convert global position to position relative to grid
    final localPosition = gridBox.globalToLocal(screenPosition);
    
    // Calculate row and column
    final row = localPosition.dy / cellSize;
    final col = localPosition.dx / cellSize;

    // Return floored values
    return GridPosition(row.floor(), col.floor());
  }

  GridPosition getCenteredPatternPosition(BlockPattern pattern, Offset screenPosition, BuildContext context) {
    final RenderBox? gridBox = _getGridRenderBox();
    if (gridBox == null) return const GridPosition(0, 0);

    final localPosition = gridBox.globalToLocal(screenPosition);
    print('Local position: $localPosition');
    print('Grid size: ${gridBox.size}');
    
    // Add a margin of half a cell size for better edge detection
    final margin = cellSize * 0.5;
    
    // Calculate grid position based on cell size first
    final exactRow = localPosition.dy / cellSize;
    final exactCol = localPosition.dx / cellSize;
    print('Exact position before clamping: ($exactRow, $exactCol)');

    // Clamp the grid position to valid coordinates, including margin
    final rowPosition = _clampInt(
      exactRow.round(),
      -1,  // Allow one cell outside
      rows
    );
    final colPosition = _clampInt(
      exactCol.round(),
      -1,  // Allow one cell outside
      cols
    );
    print('Position after first clamp: ($rowPosition, $colPosition)');

    // Final clamp to ensure the entire pattern fits within the grid
    final finalRow = _clampInt(rowPosition, 0, rows - pattern.height);
    final finalCol = _clampInt(colPosition, 0, cols - pattern.width);
    print('Final position: ($finalRow, $finalCol)');
    
    return GridPosition(finalRow, finalCol);
  }

  // Check if a position is within grid bounds
  bool isValidPosition(GridPosition position) {
    return position.row >= 0 &&
        position.row < rows &&
        position.col >= 0 &&
        position.col < cols;
  }

  // Check if a pattern can be placed at a position
  bool canPlacePattern(BlockPattern pattern, GridPosition position, List<List<bool>> gameBoard) {
    // Check if the pattern would go out of bounds
    if (position.row < 0 ||
        position.col < 0 ||
        position.row + pattern.height > rows ||
        position.col + pattern.width > cols) {
      return false;
    }

    // Check if pattern overlaps with existing blocks
    for (int i = 0; i < pattern.height; i++) {
      for (int j = 0; j < pattern.width; j++) {
        if (pattern.shape[i][j] && gameBoard[position.row + i][position.col + j]) {
          return false;
        }
      }
    }

    return true;
  }

  // Convert grid position to screen coordinates
  Offset getScreenPosition(GridPosition position) {
    final RenderBox? gridBox = _getGridRenderBox();
    if (gridBox == null) return Offset.zero;

    return Offset(
      position.col * cellSize,
      position.row * cellSize,
    );
  }

  // Place a pattern on the game board
  void placeBlockPattern(BlockPattern pattern, GridPosition position, List<List<bool>> gameBoard) {
    for (int i = 0; i < pattern.height; i++) {
      for (int j = 0; j < pattern.width; j++) {
        if (pattern.shape[i][j]) {
          gameBoard[position.row + i][position.col + j] = true;
        }
      }
    }
  }
}

class GridOverlay extends StatelessWidget {
  final GridSystem grid;
  final List<List<bool>> gameBoard;
  final Color filledColor;
  final Color gridLineColor;
  final GridPosition? highlightedPosition;
  final BlockPattern? highlightedPattern;
  final bool isDarkMode;

  const GridOverlay({
    super.key,
    required this.grid,
    required this.gameBoard,
    this.filledColor = Colors.blue,
    this.gridLineColor = const Color(0xFFE0E0E0),
    this.highlightedPosition,
    this.highlightedPattern,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: grid.gridKey,
      decoration: BoxDecoration(
        border: Border.all(color: gridLineColor),
      ),
      child: GridWidget(
        grid: grid,
        gameBoard: gameBoard,
        gridLineColor: gridLineColor,
        highlightedPosition: highlightedPosition,
        highlightedPattern: highlightedPattern,
        isDarkMode: isDarkMode,
      ),
    );
  }
}

class GridWidget extends StatefulWidget {
  final GridSystem grid;
  final List<List<bool>> gameBoard;
  final Color gridLineColor;
  final GridPosition? highlightedPosition;
  final BlockPattern? highlightedPattern;
  final bool isDarkMode;

  const GridWidget({
    Key? key,
    required this.grid,
    required this.gameBoard,
    required this.gridLineColor,
    this.highlightedPosition,
    this.highlightedPattern,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> {
  Key _painterKey = UniqueKey();

  void _handleImageLoad() {
    setState(() {
      // Force rebuild of CustomPaint by changing its key
      _painterKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      key: _painterKey,
      painter: GridPainter(
        grid: widget.grid,
        gameBoard: widget.gameBoard,
        gridLineColor: widget.gridLineColor,
        highlightedPosition: widget.highlightedPosition,
        highlightedPattern: widget.highlightedPattern,
        onImageLoad: _handleImageLoad,
        isDarkMode: widget.isDarkMode,
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final GridSystem grid;
  final List<List<bool>> gameBoard;
  final Color gridLineColor;
  final GridPosition? highlightedPosition;
  final BlockPattern? highlightedPattern;
  final Function onImageLoad;
  final bool isDarkMode;

  GridPainter({
    required this.grid,
    required this.gameBoard,
    required this.gridLineColor,
    this.highlightedPosition,
    this.highlightedPattern,
    required this.onImageLoad,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridWidth = grid.cellSize * grid.cols;
    final gridHeight = grid.cellSize * grid.rows;

    // Draw background squares over empty cells
    final emptyPaint = Paint()
      ..color = isDarkMode ? Colors.grey[900]! : Colors.white
      ..style = PaintingStyle.fill;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = gridLineColor.withOpacity(isDarkMode ? 0.4 : 0.8)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int row = 0; row < grid.rows; row++) {
      for (int col = 0; col < grid.cols; col++) {
        final rect = Rect.fromLTWH(
          col * grid.cellSize,
          row * grid.cellSize,
          grid.cellSize,
          grid.cellSize,
        );

        // If cell is empty, cover it with background color
        if (!gameBoard[row][col]) {
          canvas.drawRect(rect, emptyPaint);
        }
        
        // Draw grid lines for all cells
        canvas.drawRect(rect, gridPaint);
      }
    }

    // Draw preview if available
    if (highlightedPosition != null && highlightedPattern != null) {
      final pattern = highlightedPattern!;
      final position = highlightedPosition!;
      
      final previewPaint = Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      for (int row = 0; row < pattern.shape.length; row++) {
        for (int col = 0; col < pattern.shape[row].length; col++) {
          if (pattern.shape[row][col]) {
            final previewRect = Rect.fromLTWH(
              (position.col + col) * grid.cellSize,
              (position.row + row) * grid.cellSize,
              grid.cellSize,
              grid.cellSize,
            );
            canvas.drawRect(previewRect, previewPaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
