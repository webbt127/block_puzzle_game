import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class GameState {
  final int score;
  final int rerollCount;
  final int consecutiveClears;
  final List<List<bool>> gameBoard;
  final List<List<List<bool>>> patterns;
  final int remainingRerolls;

  GameState({
    required this.score,
    required this.rerollCount,
    required this.consecutiveClears,
    required this.gameBoard,
    required this.patterns,
    required this.remainingRerolls,
  });

  Map<String, dynamic> toJson() => {
    'score': score,
    'rerollCount': rerollCount,
    'consecutiveClears': consecutiveClears,
    'gameBoard': gameBoard.map((row) => row.map((cell) => cell ? 1 : 0).toList()).toList(),
    'patterns': patterns.map((pattern) => 
      pattern.map((row) => 
        row.map((cell) => cell ? 1 : 0).toList()
      ).toList()
    ).toList(),
    'remainingRerolls': remainingRerolls,
  };

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      score: json['score'] as int,
      rerollCount: json['rerollCount'] as int,
      consecutiveClears: json['consecutiveClears'] as int,
      gameBoard: (json['gameBoard'] as List).map((row) => 
        (row as List).map((cell) => cell == 1).toList()
      ).toList(),
      patterns: (json['patterns'] as List).map((pattern) => 
        (pattern as List).map((row) => 
          (row as List).map((cell) => cell == 1).toList()
        ).toList()
      ).toList(),
      remainingRerolls: json['remainingRerolls'] as int,
    );
  }

  static const String _storageKey = 'game_state';

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(toJson());
      await prefs.setString(_storageKey, jsonString);
      developer.log('Game state saved: $jsonString');
    } catch (e) {
      developer.log('Error saving game state: $e');
    }
  }

  static Future<GameState?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      developer.log('Loaded game state string: $jsonString');
      
      if (jsonString == null) {
        developer.log('No saved game state found');
        return null;
      }
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final state = GameState.fromJson(json);
      developer.log('Successfully loaded game state with score: ${state.score} and remaining rerolls: ${state.remainingRerolls}');
      return state;
    } catch (e) {
      developer.log('Error loading game state: $e');
      return null;
    }
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      developer.log('Game state cleared');
    } catch (e) {
      developer.log('Error clearing game state: $e');
    }
  }
}
