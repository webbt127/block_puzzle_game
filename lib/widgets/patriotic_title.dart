import 'package:flutter/material.dart';
import 'dart:math' show pi, cos, sin;

class PatrioticTitle extends StatefulWidget {
  final String text;
  final double fontSize;
  final bool isSecondary;

  const PatrioticTitle({
    super.key,
    required this.text,
    required this.fontSize,
    this.isSecondary = false,
  });

  @override
  State<PatrioticTitle> createState() => _PatrioticTitleState();
}

class _PatrioticTitleState extends State<PatrioticTitle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSecondary ? Colors.blue[900]! : Colors.red[900]!;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Create outline effect with multiple offset copies
              for (var i = 0; i < 360; i += 45)
                Transform.translate(
                  offset: Offset(
                    2.5 * cos(i * pi / 180),
                    2.5 * sin(i * pi / 180),
                  ),
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      fontFamily: 'Impact',
                      letterSpacing: 1,
                      height: 1,
                      color: color,
                    ),
                  ),
                ),
              // White fill layer
              Text(
                widget.text,
                textAlign: TextAlign.center,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontFamily: 'Impact',
                  letterSpacing: 1,
                  height: 1,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: const Offset(2.0, 2.0),
                      blurRadius: 0,
                      color: color,
                    ),
                    Shadow(
                      offset: const Offset(3.0, 3.0),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
