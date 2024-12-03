import 'package:flutter/material.dart';

class BlockPattern {
  final List<List<bool>> shape;
  final Color color;

  const BlockPattern({
    required this.shape,
    required this.color,
  });

  int get width => shape[0].length;
  int get height => shape.length;
}

class BlockPatternGenerator {
  static final List<BlockPattern> _patterns = [
    // 2x2 square
    BlockPattern(
      shape: [
        [true, true],
        [true, true],
      ],
      color: Colors.red,
    ),
    // L shape
    BlockPattern(
      shape: [
        [true, false],
        [true, false],
        [true, true],
      ],
      color: Colors.green,
    ),
    // T shape
    BlockPattern(
      shape: [
        [true, true, true],
        [false, true, false],
      ],
      color: Colors.orange,
    ),
    // Line shape
    BlockPattern(
      shape: [
        [true],
        [true],
        [true],
      ],
      color: Colors.purple,
    ),
  ];

  static List<BlockPattern> generateRandomPatterns(int count) {
    final patterns = List<BlockPattern>.from(_patterns)..shuffle();
    return patterns.take(count).toList();
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
    super.key,
    required this.pattern,
    required this.cellSize,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var row in pattern.shape)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var cell in row)
                    Container(
                      width: cellSize,
                      height: cellSize,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: cell ? Colors.grey[600]! : Colors.transparent,
                          width: cell ? 1 : 0,
                        ),
                        color: cell ? pattern.color : Colors.transparent,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
