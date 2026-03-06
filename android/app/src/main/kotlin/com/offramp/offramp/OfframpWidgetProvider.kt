package com.offramp.offramp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject

// ═════════════════════════════════════════════════════════════════════════════
// HOME SCREEN WIDGET - Shows 4 Things with checkboxes
// Updates from Hive via SharedPreferences bridge
// ═════════════════════════════════════════════════════════════════════════════

class OfframpWidgetProvider : AppWidgetProvider() {

    companion object {
        const val PREFS_NAME = "OfframpWidgetPrefs"
        const val KEY_TASKS = "four_things"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // First widget added
    }

    override fun onDisabled(context: Context) {
        // Last widget removed
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val views = RemoteViews(context.packageName, R.layout.widget_layout)

        // Load data from SharedPreferences (synced from Hive by Flutter)
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val tasksJson = prefs.getString(KEY_TASKS, "[]")

        try {
            val tasks = JSONArray(tasksJson)
            
            // Update widget views
            updateTaskViews(views, tasks)
            
            // Update progress
            val completed = countCompleted(tasks)
            val total = tasks.length()
            val progress = if (total > 0) (completed * 100 / total) else 0
            
            views.setProgressBar(R.id.widget_progress, 100, progress, false)
            views.setTextViewText(R.id.widget_progress_text, "$completed/$total")

            // Set click intent to open app
            val pendingIntent = android.app.PendingIntent.getActivity(
                context,
                0,
                context.packageManager.getLaunchIntentForPackage(context.packageName),
                android.app.PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

        } catch (e: Exception) {
            // Show empty state
            views.setTextViewText(R.id.widget_task_1, "Open Offramp to set your 4 Things")
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun updateTaskViews(views: RemoteViews, tasks: JSONArray) {
        val taskViews = listOf(
            R.id.widget_task_1,
            R.id.widget_task_2,
            R.id.widget_task_3,
            R.id.widget_task_4
        )

        val checkboxViews = listOf(
            R.id.widget_check_1,
            R.id.widget_check_2,
            R.id.widget_check_3,
            R.id.widget_check_4
        )

        for (i in 0 until minOf(tasks.length(), 4)) {
            val task = tasks.getJSONObject(i)
            val text = task.optString("text", "Task ${i + 1}")
            val done = task.optBoolean("done", false)
            val icon = task.optString("icon", "✓")

            views.setTextViewText(taskViews[i], "$icon $text")
            views.setImageViewResource(
                checkboxViews[i],
                if (done) R.drawable.ic_check_checked else R.drawable.ic_check_unchecked
            )
        }
    }

    private fun countCompleted(tasks: JSONArray): Int {
        var count = 0
        for (i in 0 until tasks.length()) {
            if (tasks.getJSONObject(i).optBoolean("done", false)) {
                count++
            }
        }
        return count
    }
}
