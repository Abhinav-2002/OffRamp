import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Syncs task data between Flutter app and Android home widgets.
/// Supports Small (2x2), Medium (4x2), and Large (4x4) widgets.
class WidgetSyncService {
  static const _appGroupId = 'com.offramp.offramp';
  static const _androidWidgetName = 'OfframpWidgetProvider';

  /// Initialize the home widget system.
  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
    // Register callback for widget taps
    HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);
  }

  /// Update widget data with current task states.
  static Future<void> updateWidgetData({
    required List<Map<String, dynamic>> tasks,
    required int completed,
    required int total,
  }) async {
    // Save task data for widget rendering
    await HomeWidget.saveWidgetData('task_count', total);
    await HomeWidget.saveWidgetData('task_done', completed);
    await HomeWidget.saveWidgetData('progress_pct', total > 0 ? ((completed / total) * 100).round() : 0);

    // Save individual task data (up to 4 tasks)
    for (int i = 0; i < 4; i++) {
      if (i < tasks.length) {
        await HomeWidget.saveWidgetData('task_${i}_text', tasks[i]['text'] ?? '');
        await HomeWidget.saveWidgetData('task_${i}_icon', tasks[i]['icon'] ?? '');
        await HomeWidget.saveWidgetData('task_${i}_done', tasks[i]['done'] == true ? '1' : '0');
      } else {
        await HomeWidget.saveWidgetData('task_${i}_text', '');
        await HomeWidget.saveWidgetData('task_${i}_icon', '');
        await HomeWidget.saveWidgetData('task_${i}_done', '0');
      }
    }

    // Signal widgets to update
    await HomeWidget.updateWidget(
      androidName: _androidWidgetName,
    );
  }

  /// Toggle a task's done state from widget interaction.
  static Future<void> toggleTaskFromWidget(int taskIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'task_${taskIndex}_done';
    final current = prefs.getString(key) ?? '0';
    final newValue = current == '1' ? '0' : '1';
    await HomeWidget.saveWidgetData(key, newValue);

    // Recalculate completed count
    int completed = 0;
    final total = prefs.getInt('task_count') ?? 4;
    for (int i = 0; i < total; i++) {
      final done = i == taskIndex ? newValue : (prefs.getString('task_${i}_done') ?? '0');
      if (done == '1') completed++;
    }
    await HomeWidget.saveWidgetData('task_done', completed);
    await HomeWidget.saveWidgetData('progress_pct', total > 0 ? ((completed / total) * 100).round() : 0);

    await HomeWidget.updateWidget(androidName: _androidWidgetName);
  }
}

/// Background callback handling widget interactions.
/// Called when user taps checkboxes directly on the widget.
@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  if (uri == null) return;

  if (uri.host == 'toggle_task') {
    final taskIndex = int.tryParse(uri.pathSegments.firstOrNull ?? '') ?? -1;
    if (taskIndex >= 0 && taskIndex < 4) {
      await WidgetSyncService.toggleTaskFromWidget(taskIndex);
    }
  } else if (uri.host == 'start_focus') {
    // Deep-link into the app's focus mode — handled by the widget provider directly
    // via HomeWidgetLaunchIntent in the Kotlin side
  }
}
