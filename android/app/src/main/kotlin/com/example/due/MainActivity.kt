package com.example.due

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
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
    }
}
