import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service for scheduling and managing local notifications.
/// Used for human buffer reminders, sleep mode triggers, morning releases.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap — navigate to specific screen based on payload
  }

  /// Show an immediate notification (e.g. "Proud of you!" after resisting urge).
  static Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'offramp_general',
        'Offramp',
        channelDescription: 'General notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );
    await _plugin.show(id, title, body, details, payload: payload);
  }

  /// Schedule a notification at a specific time.
  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    // For simplicity, use a delayed show. For production, use zonedSchedule.
    final delay = scheduledTime.difference(DateTime.now());
    if (delay.isNegative) return;

    Future.delayed(delay, () {
      showNow(id: id, title: title, body: body, payload: payload);
    });
  }

  /// Cancel a specific notification by ID.
  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancel all notifications.
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
