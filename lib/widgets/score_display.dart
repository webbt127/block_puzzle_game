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
              'Score: ${ref.watch(scoreProvider)}',
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
