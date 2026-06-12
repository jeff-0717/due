package com.example.due

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        var focusActionSink: MethodChannel? = null

        fun dispatchFocusAction(action: String): Boolean {
            val sink = focusActionSink ?: return false
            sink.invokeMethod("focusTimerAction", mapOf("action" to action))
            return true
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "due/monitor_background"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "configurePeriodicChecks",
                "triggerManualBackgroundCheck" -> result.success(null)
                else -> result.notImplemented()
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "due/monitor_notifications"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "showMonitorHit" -> result.success(null)
                else -> result.notImplemented()
            }
        }

        val focusChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "due/focus_notifications"
        )
        focusActionSink = focusChannel
        focusChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "showRunningTimer" -> {
                    val plannedSeconds = call.argument<Int>("plannedSeconds") ?: 2700
                    val remainingSeconds =
                        call.argument<Int>("remainingSeconds") ?: plannedSeconds
                    val isRunning = call.argument<Boolean>("isRunning") ?: false
                    val mode = call.argument<String>("mode") ?: "fixed45"
                    FocusTimerNotifications.show(
                        context = this,
                        plannedSeconds = plannedSeconds,
                        remainingSeconds = remainingSeconds,
                        isRunning = isRunning,
                        mode = mode
                    )
                    result.success(null)
                }
                "cancel" -> {
                    FocusTimerNotifications.cancel(this)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "due/link_opener"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openExternalUrl" -> {
                    val url = call.argument<String>("url")
                    if (url.isNullOrBlank()) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    try {
                        startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
                        result.success(true)
                    } catch (_: Exception) {
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        focusActionSink = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
