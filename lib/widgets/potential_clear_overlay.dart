import 'package:flutter/material.dart';

class PotentialClearOverlay extends StatefulWidget {
  final double cellSize;
  final List<int> potentialRowClears;
  final List<int> potentialColumnClears;

  const PotentialClearOverlay({
    super.key,
    required this.cellSize,
    required this.potentialRowClears,
    required this.potentialColumnClears,
  });

  @override
  State<PotentialClearOverlay> createState() => _PotentialClearOverlayState();
}

class _PotentialClearOverlayState extends State<PotentialClearOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PotentialClearOverlayPainter(
        cellSize: widget.cellSize,
        glowAnimation: _glowAnimation,
        potentialRowClears: widget.potentialRowClears,
        potentialColumnClears: widget.potentialColumnClears,
      ),
    );
  }
}

class PotentialClearOverlayPainter extends CustomPainter {
  final double cellSize;
  final Animation<double> glowAnimation;
  final List<int> potentialRowClears;
  final List<int> potentialColumnClears;

  PotentialClearOverlayPainter({
    required this.cellSize,
    required this.glowAnimation,
    required this.potentialRowClears,
    required this.potentialColumnClears,
  }) : super(repaint: glowAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3 * glowAnimation.value)
      ..style = PaintingStyle.fill;

    // Draw glowing rows
    for (final rowIndex in potentialRowClears) {
      canvas.drawRect(
        Rect.fromLTWH(0, rowIndex * cellSize, size.width, cellSize),
        paint,
      );
    }

    // Draw glowing columns
    for (final colIndex in potentialColumnClears) {
      canvas.drawRect(
        Rect.fromLTWH(colIndex * cellSize, 0, cellSize, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(PotentialClearOverlayPainter oldDelegate) {
    return oldDelegate.glowAnimation != glowAnimation ||
        oldDelegate.potentialRowClears != potentialRowClears ||
        oldDelegate.potentialColumnClears != potentialColumnClears;
  }
}
