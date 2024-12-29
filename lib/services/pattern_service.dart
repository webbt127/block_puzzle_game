import 'package:flutter/material.dart';
import '../grid_system.dart';
import '../block_patterns.dart';

class PatternService {
  static bool canAnyBlockFit({
    required List<List<bool>> gameBoard,
    required GridSystem gridSystem,
    required int rows,
    required int columns,
  }) {
    for (final basePattern in BlockPatterns.allPatterns) {
      final orientations = basePattern.getAllOrientations();
      for (final pattern in orientations) {
        for (int row = 0; row < rows; row++) {
          for (int col = 0; col < columns; col++) {
            if (gridSystem.canPlacePattern(
              pattern,
              GridPosition(row, col),
              gameBoard,
            )) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  static bool canCurrentPatternsfit({
    required List<BlockPattern> availablePatterns,
    required List<List<bool>> gameBoard,
    required GridSystem gridSystem,
    required int rows,
    required int columns,
  }) {
    for (int i = 0; i < availablePatterns.length; i++) {
      final basePattern = availablePatterns[i];
      final orientations = basePattern.getAllOrientations();
      for (final pattern in orientations) {
        for (int row = 0; row < rows; row++) {
          for (int col = 0; col < columns; col++) {
            if (gridSystem.canPlacePattern(
              pattern,
              GridPosition(row, col),
              gameBoard,
            )) {
              availablePatterns[i] = pattern;
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  static List<BlockPattern> generateNewPatterns({
    required bool afterAd,
    required List<List<bool>> gameBoard,
    required GridSystem gridSystem,
    required int rows,
    required int columns,
  }) {
    if (afterAd) {
      final canFit = canAnyBlockFit(
        gameBoard: gameBoard,
        gridSystem: gridSystem,
        rows: rows,
        columns: columns,
      );
      
      if (!canFit) return [];

      int attempts = 0;
      const maxAttempts = 100;
      List<BlockPattern> newPatterns = [];

      while (attempts < maxAttempts) {
        newPatterns = BlockPatterns.getRandomPatterns(3);
        if (canCurrentPatternsfit(
          availablePatterns: newPatterns,
          gameBoard: gameBoard,
          gridSystem: gridSystem,
          rows: rows,
          columns: columns,
        )) {
          return newPatterns;
        }
        attempts++;
      }
      return [];
    } else {
      return BlockPatterns.getRandomPatterns(3);
    }
  }

  static bool isGameOver({
    required List<BlockPattern> availablePatterns,
    required List<List<bool>> gameBoard,
    required GridSystem gridSystem,
    required int rows,
    required int columns,
  }) {
    for (final pattern in availablePatterns) {
      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns; col++) {
          if (gridSystem.canPlacePattern(
            pattern,
            GridPosition(row, col),
            gameBoard,
          )) {
            return false;
          }
        }
      }
    }
    return true;
  }
}
