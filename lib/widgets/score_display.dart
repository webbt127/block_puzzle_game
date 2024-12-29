import 'dart:async';

import 'package:block_puzzle_game/services/score_service.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class ScoreDisplay extends StatefulWidget {
  const ScoreDisplay({
    super.key,
  });

  @override
  State<ScoreDisplay> createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends State<ScoreDisplay> {
  late Timer _updateTimer;
  int _displayedScore = 0;

  @override
  void initState() {
    super.initState();
    _displayedScore = ScoreService.score;
    // Update score display every 100ms
    _updateTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_displayedScore != ScoreService.score) {
        setState(() {
          _displayedScore = ScoreService.score;
        });
      }
    });
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      padding: const EdgeInsets.only(right: 16.0),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $_displayedScore',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
