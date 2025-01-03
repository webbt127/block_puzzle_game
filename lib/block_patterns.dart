import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class BlockPattern {
  List<List<bool>> shape;
  int width;
  int height;

  BlockPattern({required this.shape})
      : width = shape[0].length,
        height = shape.length;

  // Create a copy of the pattern
  BlockPattern copy() {
    return BlockPattern(
      shape: shape.map((row) => List<bool>.from(row)).toList(),
    );
  }

  // Rotate the pattern 90 degrees clockwise
  BlockPattern rotateClockwise() {
    List<List<bool>> rotated = List.generate(
      width,
      (i) => List.generate(height, (j) => shape[height - 1 - j][i]),
    );
    return BlockPattern(shape: rotated);
  }

  // Flip the pattern horizontally
  BlockPattern flipHorizontal() {
    List<List<bool>> flipped = shape.map((row) => row.reversed.toList()).toList();
    return BlockPattern(shape: flipped);
  }

  // Flip the pattern vertically
  BlockPattern flipVertical() {
    List<List<bool>> flipped = shape.reversed.map((row) => List<bool>.from(row)).toList();
    return BlockPattern(shape: flipped);
  }

  // Get all unique orientations of this pattern
  List<BlockPattern> getAllOrientations() {
    Set<String> uniquePatterns = {};
    List<BlockPattern> orientations = [];
    
    // Get the base pattern and its flipped versions
    List<BlockPattern> basePatterns = [
      this,
      flipHorizontal(),
      flipVertical(),
      flipHorizontal().flipVertical(),
    ];

    // For each base pattern, try all 4 rotations
    for (final basePattern in basePatterns) {
      BlockPattern current = basePattern;
      for (int i = 0; i < 4; i++) {
        String patternString = current.shape.map((row) => row.join()).join();
        if (!uniquePatterns.contains(patternString)) {
          uniquePatterns.add(patternString);
          orientations.add(current.copy());
        }
        current = current.rotateClockwise();
      }
    }

    return orientations;
  }
}

class BlockPatterns {
  static final List<BlockPattern> allPatterns = [
    // Square (1 orientation)
    BlockPattern(shape: [
      [true, true],
      [true, true],
    ]),

    // Line horizontal (2 orientations)
    BlockPattern(shape: [
      [true, true, true, true],
    ]),
    BlockPattern(shape: [
      [true],
      [true],
      [true],
      [true],
    ]),

    // T shape (4 orientations)
    BlockPattern(shape: [
      [true, true, true],
      [false, true, false],
    ]),
    BlockPattern(shape: [
      [true, false],
      [true, true],
      [true, false],
    ]),
    BlockPattern(shape: [
      [false, true, false],
      [true, true, true],
    ]),
    BlockPattern(shape: [
      [false, true],
      [true, true],
      [false, true],
    ]),

    // L shape (4 orientations)
    BlockPattern(shape: [
      [true, false],
      [true, false],
      [true, true],
    ]),
    BlockPattern(shape: [
      [true, true, true],
      [true, false, false],
    ]),
    BlockPattern(shape: [
      [true, true],
      [false, true],
      [false, true],
    ]),
    BlockPattern(shape: [
      [false, false, true],
      [true, true, true],
    ]),
    // Z shape (2 orientations)
    BlockPattern(shape: [
      [true, true, false],
      [false, true, true],
    ]),
    BlockPattern(shape: [
      [false, true],
      [true, true],
      [true, false],
    ]),
  ];

  static List<BlockPattern> getRandomPatterns(int count) {
    final random = Random();
    final patterns = <BlockPattern>[];
    final availablePatterns = List<BlockPattern>.from(allPatterns);
    
    while (patterns.length < count && availablePatterns.isNotEmpty) {
      final index = random.nextInt(availablePatterns.length);
      patterns.add(availablePatterns[index]);
      availablePatterns.removeAt(index);
    }
    
    return patterns;
  }

  // Convert patterns to a format suitable for saving
  static List<List<List<bool>>> getSavedStateFromPatterns(List<BlockPattern> patterns) {
    developer.log('Converting ${patterns.length} patterns to saved state');
    return patterns.map((pattern) => pattern.shape).toList();
  }

  // Convert saved state back to patterns
  static List<BlockPattern> getPatternsFromSavedState(List<List<List<bool>>> patterns) {
    developer.log('Converting saved state to ${patterns.length} patterns');
    return patterns.map((shape) => BlockPattern(shape: shape)).toList();
  }
}

class BlockPatternWidget extends StatelessWidget {
  final BlockPattern pattern;
  final double cellSize;
  final double opacity;

  const BlockPatternWidget({
    super.key,
    required this.pattern,
    required this.cellSize,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return buildWidget(context);
  }

  Widget buildWidget(BuildContext context, {bool isPreview = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cellSize = isPreview ? 24.0 : 40.0;
    final padding = isPreview ? 2.0 : 4.0;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: pattern.shape.asMap().entries.map((rowEntry) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: rowEntry.value.asMap().entries.map((colEntry) {
              return Container(
                width: cellSize,
                height: cellSize,
                margin: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: colEntry.value
                      ? (isDarkMode ? Colors.blue[700] : Colors.blue)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
