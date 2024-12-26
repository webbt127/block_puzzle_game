import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'dart:math' as math;

class ScoreDisplay extends StatelessWidget {
  final int score;
  final bool showDebugControls;
  final ValueChanged<int>? onScoreChanged;

  const ScoreDisplay({
    super.key,
    required this.score,
    this.showDebugControls = kDebugMode,
    this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDebugControls) ...[
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  onScoreChanged?.call(math.max(0, score - 1000));
                },
              ),
            ],
            Text(
              'Score: $score',
              style: TextStyle(
                fontSize: showDebugControls ? 16 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            if (showDebugControls) ...[
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  onScoreChanged?.call(score + 1000);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
