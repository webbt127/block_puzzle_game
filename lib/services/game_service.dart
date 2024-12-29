import 'package:flutter/material.dart';
import '../grid_system.dart';
import '../block_patterns.dart';
import 'pattern_service.dart';
import 'score_service.dart';

class GameService {
  static void placePattern(BlockPattern pattern, GridPosition position, List<List<bool>> gameBoard, GridSystem gridSystem) {
    gridSystem.placeBlockPattern(pattern, position, gameBoard);
    
    // Add score for block placement
    final blockSize = pattern.shape
        .expand((row) => row)
        .where((cell) => cell)
        .length;
    ScoreService.addBlockScore(blockSize);
  }

  static List<int> findFullRows(List<List<bool>> gameBoard, int rows, int columns) {
    List<int> rowsToClear = [];
    for (int i = 0; i < rows; i++) {
      if (gameBoard[i].every((cell) => cell)) {
        rowsToClear.add(i);
      }
    }
    return rowsToClear;
  }

  static List<int> findFullColumns(List<List<bool>> gameBoard, int rows, int columns) {
    List<int> colsToClear = [];
    for (int j = 0; j < columns; j++) {
      bool colFull = true;
      for (int i = 0; i < rows; i++) {
        if (!gameBoard[i][j]) {
          colFull = false;
          break;
        }
      }
      if (colFull) colsToClear.add(j);
    }
    return colsToClear;
  }

  static void clearLines(List<int> rowsToClear, List<int> colsToClear, List<List<bool>> gameBoard, int columns, int rows) {
    // Clear rows
    for (int row in rowsToClear) {
      for (int j = 0; j < columns; j++) {
        gameBoard[row][j] = false;
      }
    }

    // Clear columns
    for (int col in colsToClear) {
      for (int i = 0; i < rows; i++) {
        gameBoard[i][col] = false;
      }
    }

    // Process line clears and update score
    final totalClears = rowsToClear.length + colsToClear.length;
    ScoreService.processLineClears(totalClears);
  }

  static List<List<bool>> createEmptyBoard(int rows, int columns) {
    return List.generate(
      rows,
      (i) => List.generate(columns, (j) => false),
    );
  }
}
