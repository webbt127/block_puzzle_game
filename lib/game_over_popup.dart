import 'dart:math';
import 'package:flutter/material.dart';
import 'widgets/patriotic_title.dart';

class GameOverPopup extends StatefulWidget {
  final int finalScore;
  final VoidCallback onRestart;
  final bool debugMode;

  const GameOverPopup({
    super.key,
    required this.finalScore,
    required this.onRestart,
    this.debugMode = false,
  });

  @override
  State<GameOverPopup> createState() => _GameOverPopupState();
}

class _GameOverPopupState extends State<GameOverPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  static const List<String> gameOverMessages = [
    "YOU'RE FIRED!",
    "TOTAL\nDISASTER!",
    "SAD!",
    "FAKE\nMOVES!",
    "LOW ENERGY\nGAME!",
    "NOT A\nWINNER!",
    "TREMENDOUS\nFAILURE!",
    "BIGLY\nDISAPPOINTED!",
    "NO DEAL!",
    "GAME OVER,\nFOLKS!",
  ];

  late final String selectedMessage;

  @override
  void initState() {
    super.initState();
    final random = Random();
    selectedMessage = gameOverMessages[random.nextInt(gameOverMessages.length)];

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40.0,
      ),
    ]).animate(_controller);

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _controller.forward();
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
        return Stack(
          children: [
            if (widget.debugMode)
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            Center(
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PatrioticTitle(
                          text: selectedMessage,
                          fontSize: 20,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 200,
                          height: 200,
                          child: Image.asset(
                            'assets/trump_nobg.gif',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        PatrioticTitle(
                          text: 'FINAL SCORE',
                          fontSize: 20,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${widget.finalScore}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 200,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: widget.onRestart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 2),
                            ),
                            child: const Center(
                              child: Text(
                                'PLAY AGAIN',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
