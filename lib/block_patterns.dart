import 'dart:math';
import 'package:flutter/material.dart';

class BlockPattern {
  final List<List<bool>> shape;
  final Color color;

  BlockPattern({
    required this.shape,
    required this.color,
  });

  int get width => shape[0].length;
  int get height => shape.length;
}

class BlockPatternGenerator {
  static final Random _random = Random();
  
  // Base patterns without rotation
  static final List<List<List<bool>>> _basePatterns = [
    // 2x2 square
    [
      [true, true],
      [true, true],
    ],
    // L shape
    [
      [true, false],
      [true, false],
      [true, true],
    ],
    // T shape
    [
      [true, true, true],
      [false, true, false],
    ],
    // Z shape
    [
      [true, true, false],
      [false, true, true],
    ],
    // Line shape
    [
      [true],
      [true],
      [true],
      [true],
    ],
  ];

  static final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  // Rotate a pattern matrix 90 degrees clockwise
  static List<List<bool>> _rotatePattern(List<List<bool>> pattern) {
    final int rows = pattern.length;
    final int cols = pattern[0].length;
    
    // Create a new matrix with swapped dimensions
    List<List<bool>> rotated = List.generate(
      cols,
      (i) => List.generate(rows, (j) => false),
    );
    
    // Fill the rotated matrix
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        rotated[j][rows - 1 - i] = pattern[i][j];
      }
    }
    
    return rotated;
  }

  // Get a random pattern with random rotation
  static BlockPattern getRandomPattern() {
    final basePattern = _basePatterns[_random.nextInt(_basePatterns.length)];
    final color = _colors[_random.nextInt(_colors.length)];
    
    // Randomly rotate the pattern 0-3 times
    var rotatedPattern = List<List<bool>>.from(basePattern);
    final rotations = _random.nextInt(4); // 0-3 rotations
    
    for (int i = 0; i < rotations; i++) {
      rotatedPattern = _rotatePattern(rotatedPattern);
    }
    
    return BlockPattern(
      shape: rotatedPattern,
      color: color,
    );
  }

  static List<BlockPattern> generateRandomPatterns(int count) {
    final List<BlockPattern> patterns = [];
    final List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];

    for (int i = 0; i < count; i++) {
      // Randomly select a base pattern
      final List<List<bool>> selectedShape = _basePatterns[_random.nextInt(_basePatterns.length)];
      
      // Randomly select a color
      final Color selectedColor = colors[_random.nextInt(colors.length)];

      patterns.add(BlockPattern(
        shape: selectedShape,
        color: selectedColor,
      ));
    }

    return patterns;
  }
}

class BlockPatternPainter extends CustomPainter {
  final BlockPattern pattern;
  final double cellSize;
  final Color color;

  BlockPatternPainter({
    required this.pattern,
    required this.cellSize,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int row = 0; row < pattern.height; row++) {
      for (int col = 0; col < pattern.width; col++) {
        if (pattern.shape[row][col]) {
          final rect = Rect.fromLTWH(
            col * cellSize,
            row * cellSize,
            cellSize,
            cellSize,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(BlockPatternPainter oldDelegate) {
    return oldDelegate.pattern != pattern ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.color != color;
  }
}

class BlockPatternWidget extends StatelessWidget {
  final BlockPattern pattern;
  final double cellSize;
  final double opacity;

  const BlockPatternWidget({
    Key? key,
    required this.pattern,
    required this.cellSize,
    this.opacity = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: pattern.width * cellSize,
      height: pattern.height * cellSize,
      child: CustomPaint(
        painter: BlockPatternPainter(
          pattern: pattern,
          cellSize: cellSize,
          color: pattern.color.withOpacity(opacity),
        ),
      ),
    );
  }
}
