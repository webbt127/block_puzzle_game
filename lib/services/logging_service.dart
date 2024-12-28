import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LoggingService {
  static Future<void> log(String message) async {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $message';
    debugPrint(logMessage); // Print to developer console
    
    final file = await _getLogFile();
    await file.writeAsString('$logMessage\n', mode: FileMode.append);
  }

  static Future<String> getLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/app.log');
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      // Silently fail in production
    }
    return '';
  }

  static Future<void> clearLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/app.log');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Silently fail in production
    }
  }

  static Future<File> _getLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/app.log');
  }
}
