import 'package:flutter/material.dart';
import 'block_patterns.dart';

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

  GridSystem({
    required this.rows,
    required this.cols,
    required this.cellSize,
    this.padding = const EdgeInsets.all(16.0),
  });

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
}

class GridOverlay extends StatelessWidget {
  final GridSystem grid;
  final List<List<bool>> gameBoard;
  final Color filledColor;
  final Color gridLineColor;
  final GridPosition? highlightedPosition;
  final BlockPattern? highlightedPattern;

  const GridOverlay({
    super.key,
    required this.grid,
    required this.gameBoard,
    this.filledColor = Colors.blue,
    this.gridLineColor = const Color(0xFFE0E0E0),
    this.highlightedPosition,
    this.highlightedPattern,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: grid.gridKey,
      decoration: BoxDecoration(
        border: Border.all(color: gridLineColor),
      ),
      child: CustomPaint(
        painter: GridPainter(
          grid: grid,
          gameBoard: gameBoard,
          filledColor: filledColor,
          gridLineColor: gridLineColor,
          highlightedPosition: highlightedPosition,
          highlightedPattern: highlightedPattern,
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final GridSystem grid;
  final List<List<bool>> gameBoard;
  final Color filledColor;
  final Color gridLineColor;
  final GridPosition? highlightedPosition;
  final BlockPattern? highlightedPattern;

  GridPainter({
    required this.grid,
    required this.gameBoard,
    required this.filledColor,
    required this.gridLineColor,
    this.highlightedPosition,
    this.highlightedPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final fillPaint = Paint()
      ..color = filledColor
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final invalidPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw cells
    for (int row = 0; row < grid.rows; row++) {
      for (int col = 0; col < grid.cols; col++) {
        final rect = Rect.fromLTWH(
          col * grid.cellSize,
          row * grid.cellSize,
          grid.cellSize,
          grid.cellSize,
        );

        // Draw filled cells
        if (gameBoard[row][col]) {
          canvas.drawRect(rect, fillPaint);
        }

        // Draw grid lines
        canvas.drawRect(rect, paint);
      }
    }

    // Draw highlighted position if available
    if (highlightedPosition != null && highlightedPattern != null) {
      final isValid = grid.canPlacePattern(
        highlightedPattern!,
        highlightedPosition!,
        gameBoard,
      );

      for (int i = 0; i < highlightedPattern!.height; i++) {
        for (int j = 0; j < highlightedPattern!.width; j++) {
          if (highlightedPattern!.shape[i][j]) {
            final row = highlightedPosition!.row + i;
            final col = highlightedPosition!.col + j;
            
            if (row >= 0 && row < grid.rows && col >= 0 && col < grid.cols) {
              final rect = Rect.fromLTWH(
                col * grid.cellSize,
                row * grid.cellSize,
                grid.cellSize,
                grid.cellSize,
              );
              canvas.drawRect(rect, isValid ? highlightPaint : invalidPaint);
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return true;
  }
}
