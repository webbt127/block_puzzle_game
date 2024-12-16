import 'package:flutter/material.dart';

class PardonPopup extends StatefulWidget {
  final Offset position;

  const PardonPopup({
    super.key,
    required this.position,
  });

  @override
  State<PardonPopup> createState() => _PardonPopupState();
}

class _PardonPopupState extends State<PardonPopup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Scale animation: pop in quickly, then slowly scale up
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60.0,
      ),
    ]).animate(_controller);

    // Opacity animation: fade in quickly, stay visible, then fade out
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 10.0,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 70.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 20.0,
      ),
    ]).animate(_controller);

    _controller.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
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
        return Positioned(
          left: widget.position.dx - 100, // Center the popup
          top: widget.position.dy - 100,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Speech bubble tail
                    Positioned(
                      bottom: -20,
                      left: 80,
                      child: CustomPaint(
                        size: const Size(40, 20),
                        painter: SpeechBubbleTailPainter(),
                      ),
                    ),
                    // Biden cartoon face
                    Positioned(
                      top: 20,
                      left: 50,
                      child: CustomPaint(
                        size: const Size(100, 100),
                        painter: BidenCartoonPainter(),
                      ),
                    ),
                    // Text
                    const Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Text(
                        "You're Pardoned!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontFamily: 'Comic Sans MS',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SpeechBubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    // Add shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BidenCartoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw simplified cartoon face
    // Head shape
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.8,
        height: size.height,
      ),
      paint,
    );

    // Signature smile
    final smilePath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.8,
        size.width * 0.7,
        size.height * 0.6,
      );
    canvas.drawPath(smilePath, paint);

    // Eyes
    final eyePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.4),
      size.width * 0.08,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.4),
      size.width * 0.08,
      eyePaint,
    );

    // Iconic aviator sunglasses
    final glassesPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Left lens
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.35, size.height * 0.4),
        width: size.width * 0.25,
        height: size.height * 0.2,
      ),
      glassesPaint,
    );

    // Right lens
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.65, size.height * 0.4),
        width: size.width * 0.25,
        height: size.height * 0.2,
      ),
      glassesPaint,
    );

    // Bridge of glasses
    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.4),
      Offset(size.width * 0.55, size.height * 0.4),
      glassesPaint,
    );

    // Hair
    final hairPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < 8; i++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.2),
          width: size.width * (0.6 + i * 0.05),
          height: size.height * 0.4,
        ),
        3.14,
        3.14,
        false,
        hairPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
