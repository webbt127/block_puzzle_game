import 'dart:math' as math;
import 'package:flutter/material.dart';

class WavingText extends StatefulWidget {
  final String text;
  final double fontSize;
  final Color color;
  final Color? shadowColor;

  const WavingText({
    super.key,
    required this.text,
    this.fontSize = 20,
    required this.color,
    this.shadowColor,
  });

  @override
  State<WavingText> createState() => _WavingTextState();
}

class _WavingTextState extends State<WavingText> with TickerProviderStateMixin {
  late AnimationController _controller;
  final double _waveSpeed = 2.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
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
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.text.length, (index) {
            // Calculate phase shift based on letter position
            final phaseShift = index * 0.3;
            
            // Calculate vertical offset using a sine wave
            final sineValue = math.sin(
              (_controller.value * 2 * math.pi * _waveSpeed + phaseShift)
            );
            
            // Reduce the amplitude and add slight horizontal movement
            final verticalOffset = sineValue * 4.0;
            final horizontalOffset = sineValue * 1.0;

            return Transform.translate(
              offset: Offset(horizontalOffset, verticalOffset),
              child: Text(
                widget.text[index],
                style: TextStyle(
                  fontFamily: 'AlfaSlabOne',
                  fontSize: widget.fontSize,
                  color: widget.color,
                  shadows: widget.shadowColor != null
                      ? [
                          Shadow(
                            color: widget.shadowColor!,
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
