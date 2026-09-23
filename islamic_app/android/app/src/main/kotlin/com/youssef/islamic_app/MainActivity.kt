package com.youssef.islamic_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity: FlutterActivity() {
    private val TIMEZONE_CHANNEL = "com.youssef.islamic_app/timezone"
    private val AUTOSCHEDULE_CHANNEL = "com.youssef.islamic_app.autoschedule"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Timezone channel - FIXED: Changed from timezone to timezone to match Flutter code
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TIMEZONE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getTimezone") {
                try {
                    val timeZone = TimeZone.getDefault().id
                    println("🌍 [MainActivity] getTimezone called, returning: $timeZone")
                    result.success(timeZone)
                } catch (e: Exception) {
                    println("❌ [MainActivity] Error getting timezone: ${e.message}")
                    result.error("TIMEZONE_ERROR", e.message, null)
                }
            } else {
                println("⚠️ [MainActivity] Unknown method: ${call.method}")
                result.notImplemented()
            }
        }

        // Auto-schedule channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUTOSCHEDULE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAutoSchedule" -> {
                    try {
                        val triggerTime = call.argument<Long>("triggerTime")
                        val prayerName = call.argument<String>("prayerName")
                        if (triggerTime != null && prayerName != null) {
                            AutoScheduleReceiver.scheduleNextAutoSchedule(this, triggerTime, prayerName)
                            result.success(null)
                        } else {
                            result.error("INVALID_ARGUMENT", "Trigger time and prayer name are required", null)
                        }
                    } catch (e: Exception) {
                        result.error("SCHEDULE_ERROR", e.message, null)
                    }
                }
                "cancelAutoSchedule" -> {
                    try {
                        AutoScheduleReceiver.cancelAutoSchedule(this)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("CANCEL_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
        
        println("✅ [MainActivity] Method channels configured successfully")
        println("📡 [MainActivity] Timezone channel: $TIMEZONE_CHANNEL")
        println("📡 [MainActivity] Autoschedule channel: $AUTOSCHEDULE_CHANNEL")
    }
}