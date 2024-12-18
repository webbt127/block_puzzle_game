import 'package:flutter/material.dart';

class PatrioticContainer extends StatefulWidget {
  final Widget child;
  final double borderRadius;

  const PatrioticContainer({
    super.key,
    required this.child,
    this.borderRadius = 12.0,
  });

  @override
  State<PatrioticContainer> createState() => _PatrioticContainerState();
}

class _PatrioticContainerState extends State<PatrioticContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Color> _patrioticColors = [
    Colors.red[700]!,
    Colors.white,
    Colors.blue[900]!,
    Colors.red[700]!,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

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
        return Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _patrioticColors,
              stops: [
                0.0,
                _animation.value * 0.5,
                _animation.value,
                1.0,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(widget.borderRadius - 4),
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
