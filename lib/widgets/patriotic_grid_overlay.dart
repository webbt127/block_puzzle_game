import 'package:flutter/material.dart';

class PatrioticGridOverlayPainter extends CustomPainter {
  final List<List<bool>> gameBoard;
  final double cellSize;
  final double animationValue;

  PatrioticGridOverlayPainter({
    required this.gameBoard,
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

    // Create a single gradient for the entire grid
    final gridRect = Rect.fromLTWH(
      -size.width * 0.5,  // Start gradient outside the grid
      -size.height * 0.5,
      size.width * 2,     // Make gradient larger than the grid
      size.height * 2,
    );

    final gradient = LinearGradient(
      colors: patrioticColors,
      stops: colorStops,
      begin: const Alignment(-2.0, -2.0),
      end: const Alignment(3.5, 3.5),
    );

    final gradientPaint = Paint()
      ..shader = gradient.createShader(gridRect)
      ..style = PaintingStyle.fill;

    // Draw only the filled cells using the gradient
    for (int row = 0; row < gameBoard.length; row++) {
      for (int col = 0; col < gameBoard[row].length; col++) {
        if (gameBoard[row][col]) {
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
  bool shouldRepaint(PatrioticGridOverlayPainter oldDelegate) {
    return oldDelegate.gameBoard != gameBoard ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.animationValue != animationValue;
  }
}

class PatrioticGridOverlay extends StatefulWidget {
  final List<List<bool>> gameBoard;
  final double cellSize;
  final double opacity;

  const PatrioticGridOverlay({
    Key? key,
    required this.gameBoard,
    required this.cellSize,
    this.opacity = 1.0,
  }) : super(key: key);

  @override
  State<PatrioticGridOverlay> createState() => _PatrioticGridOverlayState();
}

class _PatrioticGridOverlayState extends State<PatrioticGridOverlay>
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
      curve: Curves.easeInOut,
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
        return CustomPaint(
          painter: PatrioticGridOverlayPainter(
            gameBoard: widget.gameBoard,
            cellSize: widget.cellSize,
            animationValue: _animation.value,
          ),
        );
      },
    );
  }
}
