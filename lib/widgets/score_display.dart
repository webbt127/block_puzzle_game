import 'package:flutter/material.dart';
import 'dart:math' as math;

class ScoreDisplay extends StatelessWidget {
  final int score;
  final ValueChanged<int>? onScoreChanged;

  const ScoreDisplay({
    super.key,
    required this.score,
    this.onScoreChanged,
  });

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
              'Score: $score',
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
