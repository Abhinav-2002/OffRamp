package com.offramp.offramp

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// ═════════════════════════════════════════════════════════════════════════════
// FRICTION OVERLAY ACTIVITY - Native Android activity that launches Flutter overlay
// Full screen, semi-transparent, 30-second countdown
// ═════════════════════════════════════════════════════════════════════════════

class FrictionOverlayActivity : Activity() {

    companion object {
        const val TAG = "FrictionOverlay"
        const val METHOD_CHANNEL = "com.offramp/friction"
        const val COUNTDOWN_DURATION = 30 // seconds
    }

    private lateinit var packageName: String
    private lateinit var appName: String
    private var countdownValue = COUNTDOWN_DURATION
    private val handler = Handler(Looper.getMainLooper())
    private var countdownRunnable: Runnable? = null
    private var methodChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Get the target package info
        packageName = intent.getStringExtra("package_name") ?: ""
        appName = intent.getStringExtra("app_name") ?: "Unknown App"

        // Set up window flags for overlay behavior
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )

        // Launch Flutter overlay as a transparent activity
        launchFlutterOverlay()

        // Start countdown
        startCountdown()
    }

    private fun launchFlutterOverlay() {
        val flutterIntent = FlutterActivity
            .withNewEngine()
            .initialRoute("/friction")
            .build(this)
            .apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                putExtra("package_name", packageName)
                putExtra("app_name", appName)
            }
        
        startActivity(flutterIntent)
    }

    private fun startCountdown() {
        countdownRunnable = object : Runnable {
            override fun run() {
                countdownValue--
                
                if (countdownValue <= 0) {
                    // Countdown complete, allow the app
                    allowApp()
                } else {
                    // Update countdown in Flutter via method channel
                    methodChannel?.invokeMethod("updateCountdown", countdownValue)
                    handler.postDelayed(this, 1000)
                }
            }
        }
        handler.postDelayed(countdownRunnable!!, 1000)
    }

    private fun allowApp() {
        // Record the action
        methodChannel?.invokeMethod("onOpenAnyway", mapOf(
            "packageName" to packageName,
            "countdownExpired" to true
        ))

        // Launch the target app
        try {
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                startActivity(intent)
            }
        } catch (e: Exception) {
            Toast.makeText(this, "Could not open app", Toast.LENGTH_SHORT).show()
        }

        finish()
    }

    fun onCloseClicked() {
        // Record resistance
        methodChannel?.invokeMethod("onClose", mapOf(
            "packageName" to packageName,
            "countdownRemaining" to countdownValue
        ))

        // Go to home
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)

        finish()
    }

    fun onOpenAnywayClicked() {
        allowApp()
    }

    override fun onDestroy() {
        super.onDestroy()
        countdownRunnable?.let { handler.removeCallbacks(it) }
    }

    override fun onBackPressed() {
        // Prevent back button from closing overlay
        onCloseClicked()
    }
}
