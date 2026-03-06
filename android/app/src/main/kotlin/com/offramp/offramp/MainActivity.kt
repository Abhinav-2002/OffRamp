package com.offramp.offramp

import android.app.AppOpsManager
import android.app.NotificationManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Process
import android.provider.Settings
import android.util.Log
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

// ═════════════════════════════════════════════════════════════════════════════
// MAIN ACTIVITY - Entry point with method channels for native features
// Handles: permissions, app monitoring, sleep mode, DND
// ═════════════════════════════════════════════════════════════════════════════

class MainActivity: FlutterActivity() {

    companion object {
        const val CHANNEL = "com.offramp/permissions"
        const val APPS_CHANNEL = "com.offramp/apps"
        const val FRICTION_CHANNEL = "com.offramp/friction"
        const val TIMER_CHANNEL = "com.offramp/timer"
        const val SLEEP_CHANNEL = "com.offramp/sleep"
        const val TAG = "OfframpMainActivity"
    }

    private lateinit var permissionChannel: MethodChannel
    private lateinit var appsChannel: MethodChannel
    private lateinit var frictionChannel: MethodChannel
    private lateinit var timerChannel: MethodChannel
    private lateinit var sleepChannel: MethodChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Permission channel
        permissionChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        permissionChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermissions" -> {
                    val permissions = checkAllPermissions()
                    result.success(permissions)
                }
                "openSettings" -> {
                    val action = call.argument<Int>("action")
                    openSettings(action ?: 0)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Apps channel
        appsChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APPS_CHANNEL)
        appsChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    val apps = getInstalledApps()
                    result.success(apps)
                }
                else -> result.notImplemented()
            }
        }

        // Friction channel
        frictionChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FRICTION_CHANNEL)
        frictionChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startMonitoring" -> {
                    val apps = call.argument<List<String>>("apps")
                    startMonitoringService(apps ?: emptyList())
                    result.success(true)
                }
                "stopMonitoring" -> {
                    stopMonitoringService()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Timer channel
        timerChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TIMER_CHANNEL)
        timerChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startTimer" -> {
                    val duration = call.argument<Int>("duration")
                    val taskName = call.argument<String>("taskName")
                    startTimerService(duration ?: 0, taskName ?: "")
                    result.success(true)
                }
                "stopTimer" -> {
                    stopTimerService()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Sleep channel
        sleepChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SLEEP_CHANNEL)
        sleepChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "enableDoNotDisturb" -> {
                    enableDoNotDisturb()
                    result.success(true)
                }
                "disableDoNotDisturb" -> {
                    disableDoNotDisturb()
                    result.success(true)
                }
                "enableGrayscale" -> {
                    enableGrayscale()
                    result.success(true)
                }
                "disableGrayscale" -> {
                    disableGrayscale()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    // ═════════════════════════════════════════════════════════════════════════
    // PERMISSION HANDLING
    // ═════════════════════════════════════════════════════════════════════════

    private fun checkAllPermissions(): List<Boolean> {
        return listOf(
            hasUsageStatsPermission(),
            hasOverlayPermission(),
            hasNotificationPermission()
        )
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(), packageName
            )
        } else {
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(), packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun hasOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun hasNotificationPermission(): Boolean {
        return NotificationManagerCompat.from(this).areNotificationsEnabled()
    }

    private fun openSettings(action: Int) {
        val intent = when (action) {
            0 -> Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
            1 -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:$packageName")
                )
            } else {
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
            }
            2 -> Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
            }
            else -> Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        }
        startActivity(intent)
    }

    // ═════════════════════════════════════════════════════════════════════════
    // INSTALLED APPS
    // ═════════════════════════════════════════════════════════════════════════

    private fun getInstalledApps(): List<Map<String, String>> {
        val apps = mutableListOf<Map<String, String>>()
        val packageManager = packageManager
        val packages = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)

        for (packageInfo in packages) {
            // Skip system apps
            if ((packageInfo.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0) {
                continue
            }

            val appName = packageManager.getApplicationLabel(packageInfo).toString()
            val packageName = packageInfo.packageName

            apps.add(mapOf(
                "appName" to appName,
                "packageName" to packageName
            ))
        }

        return apps
    }

    // ═════════════════════════════════════════════════════════════════════════
    // MONITORING SERVICE
    // ═════════════════════════════════════════════════════════════════════════

    private fun startMonitoringService(apps: List<String>) {
        val intent = Intent(this, UsageStatsService::class.java).apply {
            putStringArrayListExtra("distracting_apps", ArrayList(apps))
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
        Log.d(TAG, "Started monitoring service with ${apps.size} apps")
    }

    private fun stopMonitoringService() {
        val intent = Intent(this, UsageStatsService::class.java)
        stopService(intent)
        Log.d(TAG, "Stopped monitoring service")
    }

    // ═════════════════════════════════════════════════════════════════════════
    // TIMER SERVICE
    // ═════════════════════════════════════════════════════════════════════════

    private fun startTimerService(duration: Int, taskName: String) {
        // Timer is handled in Flutter with background execution
        Log.d(TAG, "Timer started: $taskName for $duration seconds")
    }

    private fun stopTimerService() {
        Log.d(TAG, "Timer stopped")
    }

    // ═════════════════════════════════════════════════════════════════════════
    // SLEEP MODE
    // ═════════════════════════════════════════════════════════════════════════

    private fun enableDoNotDisturb() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!notificationManager.isNotificationPolicyAccessGranted) {
                val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                startActivity(intent)
                return
            }
            
            notificationManager.setInterruptionFilter(
                NotificationManager.INTERRUPTION_FILTER_PRIORITY
            )
        }
    }

    private fun disableDoNotDisturb() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            notificationManager.setInterruptionFilter(
                NotificationManager.INTERRUPTION_FILTER_ALL
            )
        }
    }

    private fun enableGrayscale() {
        // Grayscale requires WRITE_SECURE_SETTINGS permission
        // This is typically done via ADB or device admin
        // For production, guide user to enable in accessibility settings
        try {
            Settings.Secure.putInt(contentResolver, "accessibility_display_daltonizer_enabled", 1)
            Settings.Secure.putInt(contentResolver, "accessibility_display_daltonizer", 0)
        } catch (e: Exception) {
            Log.e(TAG, "Could not enable grayscale", e)
            // Guide user to manual settings
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            startActivity(intent)
        }
    }

    private fun disableGrayscale() {
        try {
            Settings.Secure.putInt(contentResolver, "accessibility_display_daltonizer_enabled", 0)
        } catch (e: Exception) {
            Log.e(TAG, "Could not disable grayscale", e)
        }
    }
}
