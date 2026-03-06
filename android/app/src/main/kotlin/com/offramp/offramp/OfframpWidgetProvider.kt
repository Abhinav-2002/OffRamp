package com.offramp.offramp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.app.PendingIntent
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class OfframpWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_medium)

            // Read task data from SharedPreferences
            val taskDone = widgetData.getInt("task_done", 0)
            val taskCount = widgetData.getInt("task_count", 4)
            val progressPct = widgetData.getInt("progress_pct", 0)

            // Set header text
            views.setTextViewText(R.id.widget_title, "Today's 4 Things")
            views.setTextViewText(R.id.widget_progress, "$taskDone/$taskCount · $progressPct%")

            // Set progress bar
            views.setProgressBar(R.id.widget_progress_bar, 100, progressPct, false)

            // Set individual task items
            for (i in 0..3) {
                val text = widgetData.getString("task_${i}_text", "") ?: ""
                val icon = widgetData.getString("task_${i}_icon", "") ?: ""
                val done = widgetData.getString("task_${i}_done", "0") == "1"

                val textViewId = getTaskTextResId(i)
                val checkViewId = getTaskCheckResId(i)
                val rowViewId = getTaskRowResId(i)

                if (textViewId != 0 && checkViewId != 0 && rowViewId != 0) {
                    views.setTextViewText(textViewId, "$icon $text")

                    // Set checkmark and strike-through appearance
                    if (done) {
                        views.setTextViewText(checkViewId, "✓")
                        views.setInt(checkViewId, "setBackgroundResource", R.drawable.check_done)
                    } else {
                        views.setTextViewText(checkViewId, "")
                        views.setInt(checkViewId, "setBackgroundResource", R.drawable.check_empty)
                    }

                    // Set click intent for toggle
                    val toggleIntent = HomeWidgetBackgroundIntent.getBroadcast(
                        context,
                        Uri.parse("offrampwidget://toggle_task/$i")
                    )
                    views.setOnClickPendingIntent(rowViewId, toggleIntent)
                }
            }

            // Launch app intent on title tap
            val launchIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java
            )
            views.setOnClickPendingIntent(R.id.widget_title, launchIntent)

            // Start Focus button (large widget)
            val focusIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("offrampwidget://start_focus/")
            )
            views.setOnClickPendingIntent(R.id.widget_focus_btn, focusIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun getTaskTextResId(index: Int): Int {
        return when (index) {
            0 -> R.id.task_0_text
            1 -> R.id.task_1_text
            2 -> R.id.task_2_text
            3 -> R.id.task_3_text
            else -> 0
        }
    }

    private fun getTaskCheckResId(index: Int): Int {
        return when (index) {
            0 -> R.id.task_0_check
            1 -> R.id.task_1_check
            2 -> R.id.task_2_check
            3 -> R.id.task_3_check
            else -> 0
        }
    }

    private fun getTaskRowResId(index: Int): Int {
        return when (index) {
            0 -> R.id.task_0_row
            1 -> R.id.task_1_row
            2 -> R.id.task_2_row
            3 -> R.id.task_3_row
            else -> 0
        }
    }
}
