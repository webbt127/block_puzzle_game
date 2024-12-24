import 'package:flutter/material.dart';

class BlockClearEffect extends StatefulWidget {
  final List<int> clearedRows;
  final List<int> clearedColumns;
  final double cellSize;
  final Offset gridPosition;
  final EdgeInsets gridPadding;

  const BlockClearEffect({
    super.key,
    required this.clearedRows,
    required this.clearedColumns,
    required this.cellSize,
    required this.gridPosition,
    required this.gridPadding,
  });

  @override
  State<BlockClearEffect> createState() => _BlockClearEffectState();
}

class _BlockClearEffectState extends State<BlockClearEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 70.0,
      ),
    ]).animate(_controller);

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _BlockClearEffectPainter(
            clearedRows: widget.clearedRows,
            clearedColumns: widget.clearedColumns,
            cellSize: widget.cellSize,
            scale: _scaleAnimation.value,
            opacity: _opacityAnimation.value,
          ),
          size: Size(
            widget.cellSize * 8,
            widget.cellSize * 8,
          ),
        );
      },
    );
  }
}

class _BlockClearEffectPainter extends CustomPainter {
  final List<int> clearedRows;
  final List<int> clearedColumns;
  final double cellSize;
  final double scale;
  final double opacity;

  _BlockClearEffectPainter({
    required this.clearedRows,
    required this.clearedColumns,
    required this.cellSize,
    required this.scale,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    // Draw row effects
    for (final row in clearedRows) {
      for (int col = 0; col < 8; col++) {
        _drawBlock(canvas, row, col, paint);
      }
    }

    // Draw column effects (excluding intersections)
    for (final col in clearedColumns) {
      for (int row = 0; row < 8; row++) {
        if (!clearedRows.contains(row)) {
          _drawBlock(canvas, row, col, paint);
        }
      }
    }
  }

  void _drawBlock(Canvas canvas, int row, int col, Paint paint) {
    final center = Offset(
      (col + 0.5) * cellSize,
      (row + 0.5) * cellSize,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        col * cellSize + 2,
        row * cellSize + 2,
        cellSize - 4,
        cellSize - 4,
      ),
      const Radius.circular(8),
    );

    // Draw shadow
    canvas.drawRRect(
      rect.shift(const Offset(2, 2)),
      Paint()
        ..color = Colors.black.withOpacity(opacity * 0.3)
        ..style = PaintingStyle.fill,
    );

    // Draw block
    canvas.drawRRect(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BlockClearEffectPainter oldDelegate) {
    return scale != oldDelegate.scale || opacity != oldDelegate.opacity;
  }
}
