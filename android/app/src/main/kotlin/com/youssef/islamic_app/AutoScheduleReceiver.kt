package com.youssef.islamic_app

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class AutoScheduleReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "IslamicApp-AutoSchedule"
        private const val FLUTTER_CHANNEL = "com.youssef.islamic_app/autoschedule"
        private const val FALLBACK_CHANNEL_ID = "auto_schedule_fallback"

        // Cache Flutter engine to avoid recreating on every alarm
        private var cachedFlutterEngine: FlutterEngine? = null

        fun getFlutterEngine(context: Context): FlutterEngine {
            if (cachedFlutterEngine == null) {
                cachedFlutterEngine = FlutterEngine(context)
            }
            return cachedFlutterEngine!!
        }

        fun scheduleNextAutoSchedule(context: Context, triggerTime: Long, prayerName: String) {
            try {
                val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                val intent = Intent(context, AutoScheduleReceiver::class.java).apply {
                    action = "com.youssef.islamic_app.AUTO_SCHEDULE"
                    putExtra("prayer_name", prayerName)
                }

                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    2001, // unique request code
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

                Log.d(TAG, "⏰ Scheduling auto-schedule for ${java.util.Date(triggerTime)} - Prayer: $prayerName")

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        triggerTime,
                        pendingIntent
                    )
                } else {
                    alarmManager.setExact(
                        AlarmManager.RTC_WAKEUP,
                        triggerTime,
                        pendingIntent
                    )
                }

                Log.i(TAG, "✅ Auto-schedule alarm set for: $prayerName")
            } catch (e: Exception) {
                Log.e(TAG, "💥 Failed to schedule auto-schedule alarm: ${e.message}")
            }
        }

        fun cancelAutoSchedule(context: Context) {
            try {
                val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                val intent = Intent(context, AutoScheduleReceiver::class.java).apply {
                    action = "com.youssef.islamic_app.AUTO_SCHEDULE"
                }

                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    2001,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

                alarmManager.cancel(pendingIntent)
                Log.i(TAG, "✅ Auto-schedule alarm cancelled")
            } catch (e: Exception) {
                Log.e(TAG, "💥 Failed to cancel auto-schedule: ${e.message}")
            }
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.i(TAG, "🔄 Auto-schedule triggered")

        val prayerName = intent.getStringExtra("prayer_name") ?: "Unknown"
        Log.i(TAG, "🕌 Prayer: $prayerName")

        try {
            // Communicate with Flutter to schedule the next prayer
            scheduleNextPrayerViaFlutter(context, prayerName)
        } catch (e: Exception) {
            Log.e(TAG, "💥 Flutter communication failed: ${e.message}")
            createFallbackNotification(context, prayerName)
        }
    }

    private fun scheduleNextPrayerViaFlutter(context: Context, prayerName: String) {
        val flutterEngine = getFlutterEngine(context)
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FLUTTER_CHANNEL)

        methodChannel.invokeMethod("scheduleNextPrayer", prayerName, object : MethodChannel.Result {
            override fun success(result: Any?) {
                Log.i(TAG, "✅ Flutter method succeeded")
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                Log.e(TAG, "❌ Flutter error: $errorCode - $errorMessage")
                createFallbackNotification(context, prayerName)
            }

            override fun notImplemented() {
                Log.e(TAG, "❌ Flutter method not implemented")
                createFallbackNotification(context, prayerName)
            }
        })
    }

    private fun createFallbackNotification(context: Context, prayerName: String) {
        try {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    FALLBACK_CHANNEL_ID,
                    "Auto-Schedule Fallback",
                    NotificationManager.IMPORTANCE_DEFAULT
                ).apply {
                    description = "Fallback notifications when Flutter is unavailable"
                    enableLights(true)
                    enableVibration(true)
                }
                notificationManager.createNotificationChannel(channel)
            }

            val builder = android.app.Notification.Builder(context, FALLBACK_CHANNEL_ID)
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setContentTitle("🔄 Auto-Schedule")
                .setContentText("Scheduling next prayer: $prayerName")
                .setAutoCancel(true)
                .setPriority(android.app.Notification.PRIORITY_DEFAULT)

            notificationManager.notify(4001, builder.build())
            Log.i(TAG, "✅ Fallback notification shown")
        } catch (e: Exception) {
            Log.e(TAG, "💥 Failed to show fallback notification: ${e.message}")
        }
    }
}