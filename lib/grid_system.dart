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
    
    // Calculate grid position with floating-point precision
    final exactRow = localPosition.dy / cellSize;
    final exactCol = localPosition.dx / cellSize;
    
    // Round to nearest grid position
    final roundedRow = exactRow.round();
    final roundedCol = exactCol.round();
    
    // Calculate the distance to the rounded position
    final rowDist = (exactRow - roundedRow).abs();
    final colDist = (exactCol - roundedCol).abs();
    
    // Use threshold for snapping - if we're very close to a grid position, snap to it
    const snapThreshold = 0.2; // Adjust this value to control snapping sensitivity
    
    // Determine final position with snapping
    final finalRow = rowDist < snapThreshold ? roundedRow : exactRow.floor();
    final finalCol = colDist < snapThreshold ? roundedCol : exactCol.floor();
    
    // Clamp the position to ensure the pattern stays within grid bounds
    // Allow positions beyond the bottom to compensate for the upward offset
    return GridPosition(
      _clampInt(finalRow, -pattern.height, rows),
      _clampInt(finalCol, 0, cols - pattern.width),
    );
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
    // Check if any filled cell would be outside the grid bounds
    for (int i = 0; i < pattern.height; i++) {
      final boardRow = position.row + i;
      for (int j = 0; j < pattern.width; j++) {
        if (pattern.shape[i][j]) {
          // If this cell is filled, it must be within grid bounds
          if (boardRow < 0 || boardRow >= rows ||
              position.col + j < 0 || position.col + j >= cols) {
            return false;
          }
        }
      }
    }

    // Check for collisions with existing blocks
    for (int i = 0; i < pattern.height; i++) {
      final boardRow = position.row + i;
      if (boardRow >= 0 && boardRow < rows) {
        for (int j = 0; j < pattern.width; j++) {
          if (pattern.shape[i][j] && gameBoard[boardRow][position.col + j]) {
            return false;
          }
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
      final boardRow = position.row + i;
      // Skip rows that are outside the grid
      if (boardRow < 0 || boardRow >= rows) continue;
      
      for (int j = 0; j < pattern.width; j++) {
        final boardCol = position.col + j;
        // Skip columns that are outside the grid
        if (boardCol < 0 || boardCol >= cols) continue;
        
        if (pattern.shape[i][j]) {
          gameBoard[boardRow][boardCol] = true;
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
      
      // Check if placement is valid
      final isValid = grid.canPlacePattern(pattern, position, gameBoard);
      
      // Use green for valid placement, red for invalid
      final previewPaint = Paint()
        ..color = (isValid ? Colors.green : Colors.red).withOpacity(0.3)
        ..style = PaintingStyle.fill;

      // Draw preview squares
      for (int row = 0; row < pattern.shape.length; row++) {
        for (int col = 0; col < pattern.shape[row].length; col++) {
          if (pattern.shape[row][col]) {
            final gridRow = position.row + row;
            final gridCol = position.col + col;
            
            // Only draw if within grid bounds
            if (gridRow >= 0 && gridRow < grid.rows && 
                gridCol >= 0 && gridCol < grid.cols) {
              final previewRect = Rect.fromLTWH(
                gridCol * grid.cellSize,
                gridRow * grid.cellSize,
                grid.cellSize,
                grid.cellSize,
              );
              canvas.drawRect(previewRect, previewPaint);
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
