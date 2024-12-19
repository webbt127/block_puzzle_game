import 'package:flutter/material.dart';

class PatrioticGridOverlay extends StatefulWidget {
  final List<List<bool>> gameBoard;
  final double cellSize;
  final bool isDarkMode;

  const PatrioticGridOverlay({
    super.key,
    required this.gameBoard,
    required this.cellSize,
    required this.isDarkMode,
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
    Colors.red[700]!,
    Colors.blue[900]!,
    Colors.blue[700]!,
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
              isDarkMode: widget.isDarkMode,
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
  final bool isDarkMode;

  PatrioticGridOverlayPainter({
    required this.gameBoard,
    required this.cellSize,
    required this.color,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < gameBoard.length; i++) {
      for (int j = 0; j < gameBoard[i].length; j++) {
        if (gameBoard[i][j]) {
          final rect = Rect.fromLTWH(
            j * cellSize,
            i * cellSize,
            cellSize,
            cellSize,
          );

          // Base color with gradient
          final baseGradient = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(1.0),
              color.withOpacity(0.8),
            ],
          );

          canvas.drawRect(
            rect,
            Paint()
              ..shader = baseGradient.createShader(rect)
              ..style = PaintingStyle.fill,
          );

          // Inner shadow at bottom and right
          final innerShadowPath = Path()
            ..moveTo(rect.right, rect.top)
            ..lineTo(rect.right, rect.bottom)
            ..lineTo(rect.left, rect.bottom);

          canvas.drawPath(
            innerShadowPath,
            Paint()
              ..style = PaintingStyle.stroke
              ..color = Colors.black.withOpacity(isDarkMode ? 0.5 : 0.3)
              ..strokeWidth = 3.0,
          );

          // Top highlight
          final highlightPath = Path()
            ..moveTo(rect.left, rect.bottom)
            ..lineTo(rect.left, rect.top)
            ..lineTo(rect.right, rect.top);

          canvas.drawPath(
            highlightPath,
            Paint()
              ..style = PaintingStyle.stroke
              ..color = Colors.white.withOpacity(isDarkMode ? 0.3 : 0.4)
              ..strokeWidth = 2.0,
          );

          // Border
          final borderPaint = Paint()
            ..style = PaintingStyle.stroke
            ..color = isDarkMode 
                ? Colors.grey[900]!.withOpacity(0.5)
                : Colors.white.withOpacity(0.1)
            ..strokeWidth = 1.0;

          canvas.drawRect(rect, borderPaint);

          // Subtle outer glow
          if (!isDarkMode) {
            final glowPaint = Paint()
              ..style = PaintingStyle.stroke
              ..color = color.withOpacity(0.2)
              ..strokeWidth = 1.0
              ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2);

            canvas.drawRect(rect, glowPaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(PatrioticGridOverlayPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isDarkMode != isDarkMode;
  }
}
