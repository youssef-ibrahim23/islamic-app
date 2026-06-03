package com.youssef.islamic_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class BootReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "BootReceiver"
        private const val NOTIFICATION_CHANNEL = "com.youssef.islamic_app/notifications"

        // Cache Flutter engine to avoid recreating (optional but safe)
        private var cachedFlutterEngine: FlutterEngine? = null

        fun getFlutterEngine(context: Context): FlutterEngine {
            if (cachedFlutterEngine == null) {
                cachedFlutterEngine = FlutterEngine(context)
            }
            return cachedFlutterEngine!!
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.i(TAG, "🚀 Boot receiver triggered: ${intent.action}")

        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            "android.intent.action.QUICKBOOT_POWERON",
            "android.intent.action.REBOOT" -> {
                Log.i(TAG, "📱 Boot/reboot event")
                notifyFlutter(context, "rescheduleOnBoot")
            }
            Intent.ACTION_TIME_CHANGED -> {
                Log.i(TAG, "🕐 Time changed")
                notifyFlutter(context, "rescheduleOnTimezoneChange")
            }
            "android.intent.action.DATE_CHANGED" -> {
                Log.i(TAG, "📅 Date changed")
                notifyFlutter(context, "rescheduleOnDateChange")
            }
            Intent.ACTION_TIMEZONE_CHANGED -> {
                Log.i(TAG, "🌍 Timezone changed")
                notifyFlutter(context, "rescheduleOnTimezoneChange")
            }
            else -> Log.w(TAG, "⚠️ Unhandled action: ${intent.action}")
        }
    }

    private fun notifyFlutter(context: Context, method: String) {
        try {
            val flutterEngine = getFlutterEngine(context)
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFICATION_CHANNEL)

            channel.invokeMethod(method, null, object : MethodChannel.Result {
                override fun success(result: Any?) {
                    Log.i(TAG, "✅ Flutter method $method succeeded")
                }
                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    Log.e(TAG, "❌ Flutter method $method failed: $errorCode - $errorMessage")
                }
                override fun notImplemented() {
                    Log.e(TAG, "❌ Flutter method $method not implemented")
                }
            })
        } catch (e: Exception) {
            Log.e(TAG, "💥 Error notifying Flutter: ${e.message}")
        }
    }
}