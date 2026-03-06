package com.offramp.offramp

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL = "com.offramp/usage_stats"
    private val EVENT_CHANNEL = "com.offramp/foreground_app_stream"

    private var pollingHandler: Handler? = null
    private var pollingRunnable: Runnable? = null
    private var isPolling = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ─── METHOD CHANNEL ─────────────────────────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasUsageStatsPermission" -> {
                    result.success(hasUsageStatsPermission())
                }
                "requestUsageStatsPermission" -> {
                    val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }
                "hasOverlayPermission" -> {
                    result.success(Settings.canDrawOverlays(this))
                }
                "requestOverlayPermission" -> {
                    val intent = Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        android.net.Uri.parse("package:$packageName")
                    )
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }
                "getForegroundApp" -> {
                    val foregroundApp = getForegroundAppPackage()
                    result.success(foregroundApp)
                }
                "getUsageStats" -> {
                    val hours = call.argument<Int>("hours") ?: 24
                    val stats = getUsageStatsData(hours)
                    result.success(stats)
                }
                else -> result.notImplemented()
            }
        }

        // ─── EVENT CHANNEL (polling stream) ─────────────────────────
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    startPolling(events)
                }

                override fun onCancel(arguments: Any?) {
                    stopPolling()
                }
            }
        )
    }

    /**
     * Check if we have usage stats permission via AppOpsManager.
     */
    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    /**
     * Polls UsageStatsManager every 1 second and returns the currently
     * foregrounded app package name.
     */
    private fun getForegroundAppPackage(): String? {
        if (!hasUsageStatsPermission()) return null

        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val beginTime = endTime - 10_000 // last 10 seconds

        val usageEvents = usm.queryEvents(beginTime, endTime)
        var lastForegroundPackage: String? = null
        var lastForegroundTime: Long = 0

        val event = android.app.usage.UsageEvents.Event()
        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)
            if (event.eventType == android.app.usage.UsageEvents.Event.ACTIVITY_RESUMED) {
                if (event.timeStamp > lastForegroundTime) {
                    lastForegroundTime = event.timeStamp
                    lastForegroundPackage = event.packageName
                }
            }
        }

        return lastForegroundPackage
    }

    /**
     * Get usage stats for the past N hours. Returns a list of maps
     * with packageName and totalTimeInForeground (ms).
     */
    private fun getUsageStatsData(hours: Int): List<Map<String, Any>> {
        if (!hasUsageStatsPermission()) return emptyList()

        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val beginTime = endTime - (hours * 3600 * 1000L)

        val stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, beginTime, endTime)

        return stats
            .filter { it.totalTimeInForeground > 0 }
            .sortedByDescending { it.totalTimeInForeground }
            .map { stat ->
                mapOf(
                    "packageName" to stat.packageName,
                    "totalTimeInForeground" to stat.totalTimeInForeground,
                    "lastTimeUsed" to stat.lastTimeUsed
                )
            }
    }

    /**
     * Start polling the foreground app every 1 second and send it
     * to the Flutter EventChannel sink.
     */
    private fun startPolling(events: EventChannel.EventSink?) {
        if (isPolling) return
        isPolling = true

        pollingHandler = Handler(Looper.getMainLooper())
        pollingRunnable = object : Runnable {
            private var lastPackage: String? = null

            override fun run() {
                if (!isPolling) return

                val currentPackage = getForegroundAppPackage()
                if (currentPackage != null && currentPackage != lastPackage) {
                    lastPackage = currentPackage
                    events?.success(mapOf(
                        "packageName" to currentPackage,
                        "timestamp" to System.currentTimeMillis()
                    ))
                }

                pollingHandler?.postDelayed(this, 1000) // poll every 1 second
            }
        }

        pollingHandler?.post(pollingRunnable!!)
    }

    /**
     * Stop polling the foreground app.
     */
    private fun stopPolling() {
        isPolling = false
        pollingRunnable?.let { pollingHandler?.removeCallbacks(it) }
        pollingHandler = null
        pollingRunnable = null
    }

    override fun onDestroy() {
        stopPolling()
        super.onDestroy()
    }
}
