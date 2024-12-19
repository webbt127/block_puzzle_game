import 'package:flutter/material.dart';
import '../block_patterns.dart';

class PatrioticBlockPattern extends StatefulWidget {
  final BlockPattern pattern;
  final double cellSize;

  const PatrioticBlockPattern({
    super.key,
    required this.pattern,
    required this.cellSize,
  });

  @override
  State<PatrioticBlockPattern> createState() => _PatrioticBlockPatternState();
}

class _PatrioticBlockPatternState extends State<PatrioticBlockPattern> {
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
          width: widget.pattern.width * widget.cellSize,
          height: widget.pattern.height * widget.cellSize,
          child: CustomPaint(
            size: Size(
              widget.pattern.width * widget.cellSize,
              widget.pattern.height * widget.cellSize,
            ),
            painter: PatrioticBlockPatternPainter(
              pattern: widget.pattern,
              cellSize: widget.cellSize,
              color: color ?? _currentColor,
            ),
          ),
        );
      },
    );
  }
}

class PatrioticBlockPatternPainter extends CustomPainter {
  final BlockPattern pattern;
  final double cellSize;
  final Color color;

  PatrioticBlockPatternPainter({
    required this.pattern,
    required this.cellSize,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final patternRect = Rect.fromLTWH(
      -pattern.width * cellSize,
      -pattern.height * cellSize,
      pattern.width * cellSize * 3,
      pattern.height * cellSize * 3,
    );

    final gradient = LinearGradient(
      colors: [color, color],
      stops: const [0.0, 1.0],
      begin: const Alignment(-2.0, -2.0),
      end: const Alignment(3.5, 3.5),
    );

    final gradientPaint = Paint()
      ..shader = gradient.createShader(patternRect)
      ..style = PaintingStyle.fill;

    // Draw each cell in the pattern
    for (var y = 0; y < pattern.height; y++) {
      for (var x = 0; x < pattern.width; x++) {
        if (pattern.shape[y][x]) {
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
  bool shouldRepaint(PatrioticBlockPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
