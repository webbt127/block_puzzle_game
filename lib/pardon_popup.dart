import 'package:flutter/material.dart';

class PardonPopup extends StatefulWidget {
  const PardonPopup({super.key});

  @override
  State<PardonPopup> createState() => _PardonPopupState();
}

class _PardonPopupState extends State<PardonPopup> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );

    _scaleController.forward();

    // Auto dismiss after 2 seconds
    Future.delayed(const Duration(milliseconds: 5800), () {
      if (mounted) {
        _scaleController.reverse().then((_) {
          Navigator.of(context).pop();
        });
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          _scaleController.reverse().then((_) {
            Navigator.of(context).pop();
          });
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 300,
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Thanks Jack,\nyou\'re pardoned!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 150,
                  height: 150,
                  child: Image.asset(
                    'assets/biden_nobg.gif',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
