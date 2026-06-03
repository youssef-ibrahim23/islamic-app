import 'dart:async';
import 'package:flutter/services.dart';
import 'app_logger.dart';
import 'notification_scheduler_service.dart';
import 'prayer_time_calculation_service.dart';

class BackgroundServiceHandler {
  static const MethodChannel _channel =
      MethodChannel('com.youssef.islamic_app/notifications');

  /// Initialize background service handler
  static void initialize() {
    AppLogger.log('[BackgroundServiceHandler] Initializing...');

    _channel.setMethodCallHandler((call) async {
      AppLogger.log('[BackgroundServiceHandler] Method called: ${call.method}');

      switch (call.method) {
        case 'rescheduleOnBoot':
          await _handleRescheduleOnBoot();
          break;

        case 'rescheduleOnTimezoneChange':
          await _handleRescheduleOnTimezoneChange();
          break;

        case 'rescheduleOnDateChange':
          await _handleRescheduleOnDateChange();
          break;

        case 'autoScheduleNextPrayer':
          await _handleAutoScheduleNextPrayer();
          break;

        default:
          AppLogger.log(
              '[BackgroundServiceHandler] Unknown method: ${call.method}');
          throw PlatformException(
            code: 'Unimplemented',
            details: 'Method ${call.method} not implemented',
          );
      }
    });

    AppLogger.log('[BackgroundServiceHandler] Initialized');
  }

  /// Handle reschedule on boot
  static Future<void> _handleRescheduleOnBoot() async {
    try {
      AppLogger.log('[BackgroundServiceHandler] Handling boot reschedule...');

      // Initialize timezone system
      await PrayerTimeCalculationService.initializeTimezone();

      // Initialize notification scheduler
      await NotificationSchedulerService.initialize();

      // Reschedule next prayer
      await NotificationSchedulerService.rescheduleOnBoot();

      AppLogger.log('[BackgroundServiceHandler] Boot reschedule completed');
    } catch (e) {
      AppLogger.log('[BackgroundServiceHandler] Boot reschedule failed: $e');
    }
  }

  /// Handle reschedule on timezone change
  static Future<void> _handleRescheduleOnTimezoneChange() async {
    try {
      AppLogger.log(
          '[BackgroundServiceHandler] Handling timezone change reschedule...');

      // Reschedule with timezone change handling
      await NotificationSchedulerService.rescheduleOnTimezoneChange();

      AppLogger.log(
          '[BackgroundServiceHandler] Timezone change reschedule completed');
    } catch (e) {
      AppLogger.log(
          '[BackgroundServiceHandler] Timezone change reschedule failed: $e');
    }
  }

  /// Handle reschedule on date change
  static Future<void> _handleRescheduleOnDateChange() async {
    try {
      AppLogger.log(
          '[BackgroundServiceHandler] Handling date change reschedule...');

      // Clear cached prayer times (new day)
      PrayerTimeCalculationService.clearCache();

      // Reschedule next prayer
      await NotificationSchedulerService.scheduleNextPrayer();

      AppLogger.log(
          '[BackgroundServiceHandler] Date change reschedule completed');
    } catch (e) {
      AppLogger.log(
          '[BackgroundServiceHandler] Date change reschedule failed: $e');
    }
  }

  /// Handle auto-schedule next prayer
  static Future<void> _handleAutoScheduleNextPrayer() async {
    try {
      AppLogger.log(
          '[BackgroundServiceHandler] Handling auto-schedule next prayer...');

      // Initialize timezone system
      await PrayerTimeCalculationService.initializeTimezone();

      // Initialize notification scheduler
      await NotificationSchedulerService.initialize();

      // Schedule next prayer
      await NotificationSchedulerService.scheduleNextPrayer();

      AppLogger.log(
          '[BackgroundServiceHandler] Auto-schedule next prayer completed');
    } catch (e) {
      AppLogger.log(
          '[BackgroundServiceHandler] Auto-schedule next prayer failed: $e');
    }
  }
}
