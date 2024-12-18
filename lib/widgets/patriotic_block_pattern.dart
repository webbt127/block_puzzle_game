import 'package:flutter/material.dart';
import '../block_patterns.dart';

class PatrioticBlockPatternPainter extends CustomPainter {
  final BlockPattern pattern;
  final double cellSize;
  final double animationValue;

  PatrioticBlockPatternPainter({
    required this.pattern,
    required this.cellSize,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final redColor = Colors.red[700]!;
    final blueColor = Colors.blue[900]!;
    final whiteColor = Colors.white.withOpacity(0.7); // Reduce white intensity

    // Calculate smooth color transitions
    final progress = animationValue;
    final List<Color> patrioticColors;
    final List<double> colorStops;

    if (progress < 0.5) {
      // First half: Red -> White -> Blue
      final t = progress * 2; // Scale to 0-1 range
      final midPoint = 0.1 + (t * 0.4); // White position
      patrioticColors = [
        redColor,
        redColor.withOpacity(0.9),   // Fade to white
        whiteColor,
        blueColor.withOpacity(0.9),  // Fade from white
        blueColor,
      ];
      colorStops = [
        0.0,
        midPoint - 0.1,              // Start fading to white
        midPoint,                    // Peak white
        midPoint + 0.1,              // Start fading to blue
        1.0,
      ];
    } else {
      // Second half: Blue -> White -> Red
      final t = (progress - 0.5) * 2; // Scale to 0-1 range
      final midPoint = 0.1 + (t * 0.4);
      patrioticColors = [
        blueColor,
        blueColor.withOpacity(0.9),  // Fade to white
        whiteColor,
        redColor.withOpacity(0.9),   // Fade from white
        redColor,
      ];
      colorStops = [
        0.0,
        midPoint - 0.1,              // Start fading to white
        midPoint,                    // Peak white
        midPoint + 0.1,              // Start fading to red
        1.0,
      ];
    }

    // Create a single gradient for the entire pattern
    final patternRect = Rect.fromLTWH(
      -pattern.width * cellSize,
      -pattern.height * cellSize,
      pattern.width * cellSize * 3.5,   // Extend further
      pattern.height * cellSize * 3.5,
    );

    final gradient = LinearGradient(
      colors: patrioticColors,
      stops: colorStops,
      begin: const Alignment(-2.0, -2.0),  // Start from further out
      end: const Alignment(3.5, 3.5),      // End further out
    );

    final gradientPaint = Paint()
      ..shader = gradient.createShader(patternRect)
      ..style = PaintingStyle.fill;

    // Draw each cell using the same gradient paint
    for (int row = 0; row < pattern.height; row++) {
      for (int col = 0; col < pattern.width; col++) {
        if (pattern.shape[row][col]) {
          final rect = Rect.fromLTWH(
            col * cellSize,
            row * cellSize,
            cellSize,
            cellSize,
          );
          canvas.drawRect(rect, gradientPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(PatrioticBlockPatternPainter oldDelegate) {
    return oldDelegate.pattern != pattern ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.animationValue != animationValue;
  }
}

class PatrioticBlockPatternWidget extends StatefulWidget {
  final BlockPattern pattern;
  final double cellSize;
  final double opacity;

  const PatrioticBlockPatternWidget({
    Key? key,
    required this.pattern,
    required this.cellSize,
    this.opacity = 1.0,
  }) : super(key: key);

  @override
  State<PatrioticBlockPatternWidget> createState() =>
      _PatrioticBlockPatternWidgetState();
}

class _PatrioticBlockPatternWidgetState extends State<PatrioticBlockPatternWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: false);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // Smoother acceleration and deceleration
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.pattern.width * widget.cellSize,
          height: widget.pattern.height * widget.cellSize,
          child: CustomPaint(
            painter: PatrioticBlockPatternPainter(
              pattern: widget.pattern,
              cellSize: widget.cellSize,
              animationValue: _animation.value,
            ),
          ),
        );
      },
    );
  }
}
