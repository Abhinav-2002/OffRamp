package com.offramp.offramp

import android.app.ActivityManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.Settings
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.SortedMap
import java.util.TreeMap

// ═════════════════════════════════════════════════════════════════════════════
// USAGE STATS SERVICE - Monitors app usage and triggers friction overlay
// Runs as foreground service, checks every 2 seconds
// ═════════════════════════════════════════════════════════════════════════════

class UsageStatsService : Service() {

    companion object {
        const val TAG = "UsageStatsService"
        const val CHANNEL_ID = "offramp_service_channel"
        const val NOTIFICATION_ID = 1
        const val CHECK_INTERVAL = 2000L // 2 seconds
        const val METHOD_CHANNEL = "com.offramp/friction"
    }

    private lateinit var handler: Handler
    private lateinit var usageStatsManager: UsageStatsManager
    private lateinit var activityManager: ActivityManager
    private var checkRunnable: Runnable? = null
    private var distractingApps: Set<String> = emptySet()
    private var lastDetectedPackage: String? = null
    private var lastDetectionTime: Long = 0
    private val cooldownPeriod = 5000L // 5 second cooldown between overlays

    private var flutterEngine: FlutterEngine? = null
    private var methodChannel: MethodChannel? = null

    override fun onCreate() {
        super.onCreate()
        handler = Handler(Looper.getMainLooper())
        usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        createNotificationChannel()
        setupMethodChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Service starting...")

        // Get distracting apps from intent
        intent?.getStringArrayListExtra("distracting_apps")?.let {
            distractingApps = it.toSet()
            Log.d(TAG, "Monitoring ${distractingApps.size} apps: $distractingApps")
        }

        // Start as foreground service
        startForeground(NOTIFICATION_ID, createNotification())

        // Start monitoring
        startMonitoring()

        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        stopMonitoring()
        Log.d(TAG, "Service destroyed")
    }

    private fun setupMethodChannel() {
        // Method channel will be set up when overlay is triggered
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Offramp Monitoring",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Monitoring for distracting apps"
                setShowBadge(false)
            }

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            packageManager.getLaunchIntentForPackage(packageName),
            PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Offramp is protecting your evening")
            .setContentText("Monitoring ${distractingApps.size} distracting apps")
            .setSmallIcon(R.drawable.ic_notification)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setSilent(true)
            .build()
    }

    private fun startMonitoring() {
        checkRunnable = object : Runnable {
            override fun run() {
                checkCurrentApp()
                handler.postDelayed(this, CHECK_INTERVAL)
            }
        }
        handler.post(checkRunnable!!)
        Log.d(TAG, "Monitoring started")
    }

    private fun stopMonitoring() {
        checkRunnable?.let { handler.removeCallbacks(it) }
        Log.d(TAG, "Monitoring stopped")
    }

    private fun checkCurrentApp() {
        try {
            val currentApp = getCurrentAppPackage()
            
            if (currentApp != null && 
                distractingApps.contains(currentApp) && 
                currentApp != packageName &&
                currentApp != lastDetectedPackage &&
                System.currentTimeMillis() - lastDetectionTime > cooldownPeriod) {
                
                Log.d(TAG, "Distracting app detected: $currentApp")
                triggerFrictionOverlay(currentApp)
                
                lastDetectedPackage = currentApp
                lastDetectionTime = System.currentTimeMillis()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking current app", e)
        }
    }

    private fun getCurrentAppPackage(): String? {
        val time = System.currentTimeMillis()
        val usageStats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_BEST,
            time - 1000 * 10, // Last 10 seconds
            time
        )

        if (usageStats != null && usageStats.isNotEmpty()) {
            val sortedMap: SortedMap<Long, UsageStats> = TreeMap()
            for (usageStat in usageStats) {
                sortedMap[usageStat.lastTimeUsed] = usageStat
            }

            if (sortedMap.isNotEmpty()) {
                return sortedMap[sortedMap.lastKey()]?.packageName
            }
        }

        // Fallback for older devices
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP_MR1) {
            val tasks = activityManager.getRunningTasks(1)
            if (tasks.isNotEmpty()) {
                return tasks[0].topActivity?.packageName
            }
        }

        return null
    }

    private fun triggerFrictionOverlay(packageName: String) {
        try {
            // Launch the overlay activity
            val intent = Intent(this, FrictionOverlayActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
                putExtra("package_name", packageName)
                putExtra("app_name", getAppName(packageName))
            }
            startActivity(intent)

            // Notify Flutter side
            methodChannel?.invokeMethod("onDistractingAppOpened", mapOf(
                "packageName" to packageName,
                "timestamp" to System.currentTimeMillis()
            ))

            Log.d(TAG, "Friction overlay triggered for $packageName")
        } catch (e: Exception) {
            Log.e(TAG, "Error triggering overlay", e)
        }
    }

    private fun getAppName(packageName: String): String {
        return try {
            val appInfo = packageManager.getApplicationInfo(packageName, 0)
            packageManager.getApplicationLabel(appInfo).toString()
        } catch (e: Exception) {
            packageName
        }
    }

    // Called from Flutter to update the list of distracting apps
    fun updateDistractingApps(apps: List<String>) {
        distractingApps = apps.toSet()
        Log.d(TAG, "Updated distracting apps: $distractingApps")
    }
}
