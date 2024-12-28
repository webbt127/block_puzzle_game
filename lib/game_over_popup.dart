import 'dart:math' as math;
import 'package:block_puzzle_game/services/games_services.dart';
import 'package:block_puzzle_game/services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'widgets/patriotic_title.dart';

class GameOverPopup extends StatefulWidget {
  final int finalScore;
  final VoidCallback onRestart;
  final bool debugMode;
  final int? initialHighScore;
  final int rerollsRemaining;
  final VoidCallback? onReroll;
  final bool hideAds;

  const GameOverPopup({
    super.key,
    required this.finalScore,
    required this.onRestart,
    required this.debugMode,
    required this.hideAds,
    this.initialHighScore,
    this.rerollsRemaining = 0,
    this.onReroll,
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
    foundation.debugPrint('[GameOverPopup] initState');
    _currentScore = widget.finalScore;
    _highScore = widget.initialHighScore;
    _isHighScore = _highScore != null && widget.finalScore > _highScore!;
    
    // Select message based on high score status
    final random = math.Random();
    selectedMessage = _isHighScore 
        ? highScoreMessages[random.nextInt(highScoreMessages.length)]
        : gameOverMessages[random.nextInt(gameOverMessages.length)];
    
    // Preload rewarded ad if rerolls are available
    if (widget.rerollsRemaining > 0 && widget.onReroll != null) {
      foundation.debugPrint('[GameOverPopup] Creating rewarded ad');
      AdService.loadRewardedAd();
    }
    
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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
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
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.85,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
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
                        child: SingleChildScrollView(
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
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 16),
                              PatrioticTitle(
                                text: selectedMessage ?? gameOverMessages[0],
                                fontSize: 20,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'FINAL SCORE',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue[900]!.withOpacity(0.7),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$_currentScore',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                    if (_highScore != null) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        height: 1,
                                        color: Colors.blue[200]!.withOpacity(0.3),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'HIGH SCORE',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue[900]!.withOpacity(0.7),
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$_highScore',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: _isHighScore ? Colors.green[700] : Colors.blue[900],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Show reroll button if:
                              // 1. Rerolls are remaining
                              // 2. onReroll callback is provided
                              // 3. If ads not hidden: rewarded ad must be available
                              if (widget.rerollsRemaining > 0 && 
                                  widget.onReroll != null &&
                                  (widget.hideAds || AdService.hasRewardedAd)) ...[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                                    ),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 44,
                                      child: ElevatedButton(
                                        onPressed: widget.onReroll,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[700],
                                          foregroundColor: Colors.white,
                                          elevation: 3,
                                          shadowColor: Colors.green[700]!.withOpacity(0.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: !widget.hideAds ? 8 : 12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.refresh_rounded,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'REROLL (${widget.rerollsRemaining})',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (!widget.hideAds) ...[
                                              const SizedBox(width: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 3,
                                                  vertical: 1,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.play_circle_filled,
                                                      size: 10,
                                                    ),
                                                    SizedBox(width: 1),
                                                    Text(
                                                      'AD',
                                                      style: TextStyle(
                                                        fontSize: 8,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Show interstitial ad if available
                                      if (AdService.hasInterstitialAd && !widget.hideAds) {
                                        AdService.showInterstitialAd();
                                      }
                                      widget.onRestart();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[900],
                                      foregroundColor: Colors.white,
                                      elevation: 3,
                                      shadowColor: Colors.blue[900]!.withOpacity(0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow_rounded,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'PLAY AGAIN',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
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
              ),
            ],
          );
        },
      ),
    );
  }
}
