import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/foundation.dart';
import '../env/env.dart';

class AnalyticsService {
  static Amplitude? _amplitude;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      _amplitude = Amplitude.getInstance();
      await _amplitude!.init(Env.amplitudeApiKey);
      
      // Enable debug logging in debug mode
      if (kDebugMode) {
        await _amplitude!.enableCoppaControl();
      }

      // Start tracking session
      await _amplitude!.trackingSessionEvents(true);
      
      _initialized = true;
    } catch (e) {
      debugPrint('Failed to initialize Amplitude: $e');
    }
  }

  static Future<void> logEvent(String eventName, {Map<String, dynamic>? properties}) async {
    if (!_initialized) {
      debugPrint('Amplitude not initialized');
      return;
    }

    try {
      await _amplitude!.logEvent(
        eventName,
        eventProperties: properties,
      );
    } catch (e) {
      debugPrint('Failed to log Amplitude event: $e');
    }
  }

  static Future<void> logError(String errorName, dynamic error, StackTrace? stackTrace) async {
    final properties = {
      'error_message': error.toString(),
      'stack_trace': stackTrace?.toString(),
    };

    await logEvent('app_error', properties: properties);
  }

  static Future<void> setUserProperty(String propertyName, dynamic value) async {
    if (!_initialized) {
      debugPrint('Amplitude not initialized');
      return;
    }

    try {
      await _amplitude!.setUserProperties({propertyName: value});
    } catch (e) {
      debugPrint('Failed to set user property: $e');
    }
  }

  static Future<void> setUserId(String userId) async {
    if (!_initialized) {
      debugPrint('Amplitude not initialized');
      return;
    }

    try {
      await _amplitude!.setUserId(userId);
    } catch (e) {
      debugPrint('Failed to set user ID: $e');
    }
  }
}
