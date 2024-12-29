import 'dart:async';

import 'package:block_puzzle_game/providers/score_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class ScoreDisplay extends ConsumerWidget {
  const ScoreDisplay({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
