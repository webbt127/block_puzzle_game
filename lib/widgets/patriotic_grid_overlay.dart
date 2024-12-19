import 'package:flutter/material.dart';

class PatrioticGridOverlay extends StatefulWidget {
  final List<List<bool>> gameBoard;
  final double cellSize;

  const PatrioticGridOverlay({
    super.key,
    required this.gameBoard,
    required this.cellSize,
  });

  @override
  State<PatrioticGridOverlay> createState() => _PatrioticGridOverlayState();
}

class _PatrioticGridOverlayState extends State<PatrioticGridOverlay> {
  late ColorTween _colorTween;
  late Color _currentColor;
  int _colorIndex = 0;
  final List<Color> _colors = [
    Colors.red[900]!,
    Colors.white.withOpacity(0.5),
    Colors.blue[900]!,
  ];

  @override
  void initState() {
    super.initState();
    _currentColor = _colors[0];
    _updateColorTween();
  }

  void _updateColorTween() {
    final nextColorIndex = (_colorIndex + 1) % _colors.length;
    _colorTween = ColorTween(
      begin: _colors[_colorIndex],
      end: _colors[nextColorIndex],
    );
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: _colorTween,
      duration: const Duration(seconds: 3),
      onEnd: () {
        setState(() {
          _colorIndex = (_colorIndex + 1) % _colors.length;
          _currentColor = _colors[_colorIndex];
          _updateColorTween();
        });
      },
      builder: (context, color, child) {
        return SizedBox(
          width: widget.gameBoard[0].length * widget.cellSize,
          height: widget.gameBoard.length * widget.cellSize,
          child: CustomPaint(
            size: Size(
              widget.gameBoard[0].length * widget.cellSize,
              widget.gameBoard.length * widget.cellSize,
            ),
            painter: PatrioticGridOverlayPainter(
              gameBoard: widget.gameBoard,
              cellSize: widget.cellSize,
              color: color ?? _currentColor,
            ),
          ),
        );
      },
    );
  }
}

class PatrioticGridOverlayPainter extends CustomPainter {
  final List<List<bool>> gameBoard;
  final double cellSize;
  final Color color;

  PatrioticGridOverlayPainter({
    required this.gameBoard,
    required this.cellSize,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridRect = Rect.fromLTWH(
      -size.width * 0.5,
      -size.height * 0.5,
      size.width * 2,
      size.height * 2,
    );

    final gradient = LinearGradient(
      colors: [color, color],
      stops: const [0.0, 1.0],
      begin: const Alignment(-2.0, -2.0),
      end: const Alignment(3.5, 3.5),
    );

    final gradientPaint = Paint()
      ..shader = gradient.createShader(gridRect)
      ..style = PaintingStyle.fill;

    // Draw each cell in the grid
    for (var y = 0; y < gameBoard.length; y++) {
      for (var x = 0; x < gameBoard[y].length; x++) {
        if (gameBoard[y][x]) {
          final rect = Rect.fromLTWH(
            x * cellSize,
            y * cellSize,
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
    return oldDelegate.color != color;
  }
}
