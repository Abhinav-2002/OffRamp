import 'package:flutter/services.dart';

/// Flutter-side service for interacting with the native UsageStatsManager
/// platform channel. Polls the foreground app via EventChannel and exposes
/// methods for permission checking and usage data retrieval.
class UsageStatsService {
  static const _methodChannel = MethodChannel('com.offramp/usage_stats');
  static const _eventChannel = EventChannel('com.offramp/foreground_app_stream');

  /// Check if the app has Usage Access permission granted.
  static Future<bool> hasUsageStatsPermission() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('hasUsageStatsPermission');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Open the system Usage Access settings page.
  static Future<void> requestUsageStatsPermission() async {
    await _methodChannel.invokeMethod('requestUsageStatsPermission');
  }

  /// Check if the app has overlay (draw over apps) permission.
  static Future<bool> hasOverlayPermission() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('hasOverlayPermission');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Open system overlay permission settings.
  static Future<void> requestOverlayPermission() async {
    await _methodChannel.invokeMethod('requestOverlayPermission');
  }

  /// Get the currently foregrounded app package name (one-shot).
  static Future<String?> getForegroundApp() async {
    try {
      final result = await _methodChannel.invokeMethod<String>('getForegroundApp');
      return result;
    } catch (e) {
      return null;
    }
  }

  /// Get app usage statistics for the past [hours] hours.
  /// Returns a list of maps with keys: packageName, totalTimeInForeground, lastTimeUsed.
  static Future<List<Map<String, dynamic>>> getUsageStats({int hours = 24}) async {
    try {
      final result = await _methodChannel.invokeMethod<List>('getUsageStats', {'hours': hours});
      return result?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Stream that emits whenever the foreground app changes.
  /// Each event is a Map with keys: packageName, timestamp.
  /// The native side polls UsageStatsManager every 1 second and only emits
  /// when the foreground app changes.
  static Stream<Map<String, dynamic>> get foregroundAppStream {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event as Map);
    });
  }
}
