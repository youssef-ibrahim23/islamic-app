import 'dart:io';
import 'package:flutter/services.dart';

class ExactAlarmPermission {
  static const MethodChannel _channel = MethodChannel('exact_alarm_permission');

  /// Checks if exact alarms are permitted
  static Future<bool> isExactAlarmAllowed() async {
    if (!Platform.isAndroid) return true; // Only Android cares
    try {
      final bool allowed = await _channel.invokeMethod('isExactAlarmAllowed');
      return allowed;
    } catch (e) {
      return false;
    }
  }

  /// Requests the exact alarm permission UI
  static Future<void> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('requestExactAlarmPermission');
    } catch (e) {
      // ignore
    }
  }
}
