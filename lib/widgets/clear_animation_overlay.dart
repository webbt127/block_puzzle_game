import 'package:flutter/material.dart';

class ClearAnimationOverlay extends StatefulWidget {
  final List<int> rowsToClear;
  final List<int> columnsToClear;
  final double cellSize;
  final VoidCallback onAnimationComplete;
  final Function(int row, int col) onBlockClear;

  const ClearAnimationOverlay({
    super.key,
    required this.rowsToClear,
    required this.columnsToClear,
    required this.cellSize,
    required this.onAnimationComplete,
    required this.onBlockClear,
  });

  @override
  State<ClearAnimationOverlay> createState() => _ClearAnimationOverlayState();
}

class _ClearAnimationOverlayState extends State<ClearAnimationOverlay>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _opacityAnimations;
  late List<_CellToAnimate> _cellsToAnimate;
  final int rows = 8;
  final int columns = 8;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Calculate total cells to animate
    _cellsToAnimate = <_CellToAnimate>[];
    
    // Add row cells
    for (final row in widget.rowsToClear) {
      for (int col = 0; col < columns; col++) {
        _cellsToAnimate.add(_CellToAnimate(row, col, col * 5)); // 30ms delay between cells
      }
    }
    
    // Add column cells (excluding intersections)
    for (final col in widget.columnsToClear) {
      for (int row = 0; row < rows; row++) {
        if (!widget.rowsToClear.contains(row)) {
          _cellsToAnimate.add(_CellToAnimate(row, col, row * 5)); // 30ms delay between cells
        }
      }
    }

    // Create controllers and animations
    _controllers = _cellsToAnimate.map((cell) {
      return AnimationController(
        duration: const Duration(milliseconds: 100), // Faster animation duration
        vsync: this,
      );
    }).toList();

    _scaleAnimations = _controllers.map((controller) {
      return TweenSequence<double>([
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
      ]).animate(controller);
    }).toList();

    _opacityAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
        ),
      );
    }).toList();
  }

  void _startAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(Duration(milliseconds: (i * 10))); // Match the delay with cell animation
      _controllers[i].forward().then((_) {
        final cell = _cellsToAnimate[i];
        widget.onBlockClear(cell.row, cell.col);
      });
    }

    // Wait for all animations to complete
    await Future.delayed(Duration(
      milliseconds: _controllers.length * 10 + 100, // Updated timing
    ));
    widget.onAnimationComplete();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ClearAnimationPainter(
        rowsToClear: widget.rowsToClear,
        columnsToClear: widget.columnsToClear,
        cellSize: widget.cellSize,
        scaleAnimations: _scaleAnimations,
        opacityAnimations: _opacityAnimations,
      ),
    );
  }
}

class ClearAnimationPainter extends CustomPainter {
  final List<int> rowsToClear;
  final List<int> columnsToClear;
  final double cellSize;
  final List<Animation<double>> scaleAnimations;
  final List<Animation<double>> opacityAnimations;

  ClearAnimationPainter({
    required this.rowsToClear,
    required this.columnsToClear,
    required this.cellSize,
    required this.scaleAnimations,
    required this.opacityAnimations,
  }) : super(repaint: Listenable.merge([...scaleAnimations, ...opacityAnimations]));

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    int animationIndex = 0;

    // Draw row animations
    for (final row in rowsToClear) {
      for (int col = 0; col < 8; col++) {
        final scale = scaleAnimations[animationIndex].value;
        final opacity = opacityAnimations[animationIndex].value;
        
        if (scale > 0 && opacity > 0) {
          paint.color = Colors.white.withOpacity(opacity);
          
          final center = Offset(
            (col + 0.5) * cellSize,
            (row + 0.5) * cellSize,
          );
          
          canvas.save();
          canvas.translate(center.dx, center.dy);
          canvas.scale(scale);
          canvas.translate(-center.dx, -center.dy);
          
          canvas.drawRect(
            Rect.fromLTWH(
              col * cellSize,
              row * cellSize,
              cellSize,
              cellSize,
            ),
            paint,
          );
          
          canvas.restore();
        }
        animationIndex++;
      }
    }

    // Draw column animations (excluding intersections)
    for (final col in columnsToClear) {
      for (int row = 0; row < 8; row++) {
        if (!rowsToClear.contains(row)) {
          final scale = scaleAnimations[animationIndex].value;
          final opacity = opacityAnimations[animationIndex].value;
          
          if (scale > 0 && opacity > 0) {
            paint.color = Colors.white.withOpacity(opacity);
            
            final center = Offset(
              (col + 0.5) * cellSize,
              (row + 0.5) * cellSize,
            );
            
            canvas.save();
            canvas.translate(center.dx, center.dy);
            canvas.scale(scale);
            canvas.translate(-center.dx, -center.dy);
            
            canvas.drawRect(
              Rect.fromLTWH(
                col * cellSize,
                row * cellSize,
                cellSize,
                cellSize,
              ),
              paint,
            );
            
            canvas.restore();
          }
          animationIndex++;
        }
      }
    }
  }

  @override
  bool shouldRepaint(ClearAnimationPainter oldDelegate) {
    return true;
  }
}

class _CellToAnimate {
  final int row;
  final int col;
  final int delay;

  _CellToAnimate(this.row, this.col, this.delay);
}
