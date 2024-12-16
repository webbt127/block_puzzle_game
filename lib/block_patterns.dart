import 'dart:math';
import 'package:flutter/material.dart';

class BlockPattern {
  List<List<bool>> shape;
  int width;
  int height;

  BlockPattern({required this.shape})
      : width = shape[0].length,
        height = shape.length;

  // Create a copy of the pattern
  BlockPattern copy() {
    return BlockPattern(
      shape: shape.map((row) => List<bool>.from(row)).toList(),
    );
  }

  // Rotate the pattern 90 degrees clockwise
  BlockPattern rotateClockwise() {
    List<List<bool>> rotated = List.generate(
      width,
      (i) => List.generate(height, (j) => shape[height - 1 - j][i]),
    );
    return BlockPattern(shape: rotated);
  }

  // Get all unique orientations of this pattern
  List<BlockPattern> getAllOrientations() {
    Set<String> uniquePatterns = {};
    List<BlockPattern> orientations = [];
    BlockPattern current = this;

    // Try all 4 rotations
    for (int i = 0; i < 4; i++) {
      String patternString = current.shape.map((row) => row.join()).join();
      if (!uniquePatterns.contains(patternString)) {
        uniquePatterns.add(patternString);
        orientations.add(current.copy());
      }
      current = current.rotateClockwise();
    }

    return orientations;
  }
}

class BlockPatterns {
  static final List<BlockPattern> allPatterns = [
    // Square (1 orientation)
    BlockPattern(shape: [
      [true, true],
      [true, true],
    ]),

    // Line horizontal (2 orientations)
    BlockPattern(shape: [
      [true, true, true, true],
    ]),
    BlockPattern(shape: [
      [true],
      [true],
      [true],
      [true],
    ]),

    // T shape (4 orientations)
    BlockPattern(shape: [
      [true, true, true],
      [false, true, false],
    ]),
    BlockPattern(shape: [
      [true, false],
      [true, true],
      [true, false],
    ]),
    BlockPattern(shape: [
      [false, true, false],
      [true, true, true],
    ]),
    BlockPattern(shape: [
      [false, true],
      [true, true],
      [false, true],
    ]),

    // L shape (4 orientations)
    BlockPattern(shape: [
      [true, false],
      [true, false],
      [true, true],
    ]),
    BlockPattern(shape: [
      [true, true, true],
      [true, false, false],
    ]),
    BlockPattern(shape: [
      [true, true],
      [false, true],
      [false, true],
    ]),
    BlockPattern(shape: [
      [false, false, true],
      [true, true, true],
    ]),

    // Z shape (2 orientations)
    BlockPattern(shape: [
      [true, true, false],
      [false, true, true],
    ]),
    BlockPattern(shape: [
      [false, true],
      [true, true],
      [true, false],
    ]),
  ];

  static List<BlockPattern> getRandomPatterns(int count) {
    final random = Random();
    final patterns = <BlockPattern>[];
    final availablePatterns = List<BlockPattern>.from(allPatterns);
    
    while (patterns.length < count && availablePatterns.isNotEmpty) {
      final index = random.nextInt(availablePatterns.length);
      patterns.add(availablePatterns[index]);
      availablePatterns.removeAt(index);
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
          color: Colors.blue.withOpacity(opacity),
        ),
      ),
    );
  }
}
