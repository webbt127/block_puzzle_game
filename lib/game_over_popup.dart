import 'dart:math' as math;
import 'package:block_puzzle_game/services/games_services.dart';
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
    required this.debugMode,
  });

  @override
  State<GameOverPopup> createState() => _GameOverPopupState();
}

class _GameOverPopupState extends State<GameOverPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late int _currentScore;
  bool _isHighScore = false;
  int? _highScore;
  String? selectedMessage;

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

  static const List<String> highScoreMessages = [
    "YOU'RE UNBURDENED\nBY WHAT HAS BEEN!"
  ];

  @override
  void initState() {
    super.initState();
    _currentScore = widget.finalScore;
    _checkHighScore();
    
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

  Future<void> _checkHighScore() async {
    try {
      if (await GameServicesService.isSignedIn()) {
        final highScore = await GameServicesService.getHighScore();
        setState(() {
          _highScore = highScore;
          _isHighScore = widget.finalScore > highScore;
          // Select message based on high score status
          final random = math.Random();
          selectedMessage = _isHighScore 
              ? highScoreMessages[random.nextInt(highScoreMessages.length)]
              : gameOverMessages[random.nextInt(gameOverMessages.length)];
        });
      } else {
        final random = math.Random();
        setState(() {
          selectedMessage = gameOverMessages[random.nextInt(gameOverMessages.length)];
        });
      }
    } catch (e) {
      print('Error checking high score: $e');
      final random = math.Random();
      setState(() {
        selectedMessage = gameOverMessages[random.nextInt(gameOverMessages.length)];
      });
    }
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
              child: Container(
                padding: const EdgeInsets.all(32.0),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            spreadRadius: 5,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              _isHighScore
                                  ? 'assets/high_score.gif'
                                  : 'assets/trump_nobg.gif',
                              width: 180,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 24),
                          PatrioticTitle(
                            text: selectedMessage ?? gameOverMessages[0],
                            fontSize: 24,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'FINAL SCORE',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[900]!.withOpacity(0.7),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$_currentScore',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                ),
                                if (_highScore != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    height: 1,
                                    color: Colors.blue[200]!.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'HIGH SCORE',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[900]!.withOpacity(0.7),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_highScore',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: widget.onRestart,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[900],
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shadowColor: Colors.blue[900]!.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'PLAY AGAIN',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
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
            ),
          ],
        );
      },
    );
  }
}
