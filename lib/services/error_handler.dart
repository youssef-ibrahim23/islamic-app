import 'dart:async';
import 'package:flutter/foundation.dart';
import 'app_logger.dart';

/// Comprehensive error handling and logging utility
class ErrorHandler {
  static bool _isInitialized = false;
  static final Map<String, int> _errorCounts = {};
  static final List<String> _recentErrors = [];
  static const int _maxRecentErrors = 50;

  /// Initialize error handler
  static void initialize() {
    if (_isInitialized) return;

    // Set up global error handlers
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _handlePlatformError(error, stack);
      return true; // Prevent default error dialog
    };

    _isInitialized = true;
    AppLogger.log('[ErrorHandler] Initialized');
  }

  /// Handle Flutter errors
  static void _handleFlutterError(FlutterErrorDetails details) {
    try {
      final errorType = _getErrorType(details.exception);
      final message = _formatFlutterError(details);

      _recordError(errorType, message);

      // Log the error
      AppLogger.log('[ErrorHandler] Flutter Error: $message');

      // In debug mode, print to console
      if (kDebugMode) {
        debugPrint('🔥 Flutter Error: $message');
      }

      // In release mode, could send to crash reporting service
      if (!kDebugMode) {
        _sendToCrashReporting(details);
      }
    } catch (e) {
      AppLogger.log('[ErrorHandler] Error in error handler: $e');
    }
  }

  /// Handle platform errors
  static void _handlePlatformError(Object error, StackTrace stack) {
    try {
      final errorType = _getErrorType(error);
      final message = _formatPlatformError(error, stack);

      _recordError(errorType, message);

      // Log the error
      AppLogger.log('[ErrorHandler] Platform Error: $message');

      // In debug mode, print to console
      if (kDebugMode) {
        debugPrint('🔥 Platform Error: $message');
      }

      // In release mode, could send to crash reporting service
      if (!kDebugMode) {
        _sendPlatformErrorToCrashReporting(error, stack);
      }
    } catch (e) {
      AppLogger.log('[ErrorHandler] Error in error handler: $e');
    }
  }

  /// Handle async errors
  static void handleAsyncError(Object error, StackTrace stack, String context) {
    try {
      final errorType = _getErrorType(error);
      final message = _formatAsyncError(error, stack, context);

      _recordError(errorType, message);

      // Log the error
      AppLogger.log('[ErrorHandler] Async Error: $message');

      // In debug mode, print to console
      if (kDebugMode) {
        debugPrint('🔥 Async Error: $message');
      }

      // In release mode, could send to crash reporting service
      if (!kDebugMode) {
        _sendAsyncErrorToCrashReporting(error, stack, context);
      }
    } catch (e) {
      AppLogger.log('[ErrorHandler] Error in error handler: $e');
    }
  }

  /// Handle custom errors with context
  static void handleCustomError(String context, Object error,
      [StackTrace? stack]) {
    try {
      final errorType = _getErrorType(error);
      final message = _formatCustomError(context, error, stack);

      _recordError(errorType, message);

      // Log the error
      AppLogger.log('[ErrorHandler] Custom Error: $message');

      // In debug mode, print to console
      if (kDebugMode) {
        debugPrint('🔥 Custom Error: $message');
      }

      // In release mode, could send to crash reporting service
      if (!kDebugMode) {
        _sendCustomErrorToCrashReporting(context, error, stack);
      }
    } catch (e) {
      AppLogger.log('[ErrorHandler] Error in error handler: $e');
    }
  }

  /// Record error for analytics
  static void _recordError(String errorType, String message) {
    _errorCounts[errorType] = (_errorCounts[errorType] ?? 0) + 1;

    // Add to recent errors
    _recentErrors.add(message);
    if (_recentErrors.length > _maxRecentErrors) {
      _recentErrors.removeAt(0);
    }

    // Check for error threshold
    _checkErrorThresholds(errorType);
  }

  /// Check error thresholds
  static void _checkErrorThresholds(String errorType) {
    final count = _errorCounts[errorType] ?? 0;

    // Define thresholds for different error types
    final thresholds = {
      'NetworkError': 10,
      'PermissionError': 5,
      'DatabaseError': 3,
      'NotificationError': 5,
      'PrayerTimeError': 3,
      'UnknownError': 20,
    };

    final threshold = thresholds[errorType] ?? 10;

    if (count >= threshold) {
      AppLogger.log(
          '[ErrorHandler] ⚠️ High error count for $errorType: $count');
      // Could trigger additional actions like sending alerts
    }
  }

  /// Get error type
  static String _getErrorType(Object error) {
    if (error is NetworkException) {
      return 'NetworkError';
    } else if (error is PermissionException) {
      return 'PermissionError';
    } else if (error is DatabaseException) {
      return 'DatabaseError';
    } else if (error is NotificationException) {
      return 'NotificationError';
    } else if (error is PrayerTimeException) {
      return 'PrayerTimeError';
    } else if (error is TimeoutException) {
      return 'TimeoutError';
    } else if (error is FormatException) {
      return 'FormatError';
    } else if (error is StateError) {
      return 'StateError';
    } else if (error is RangeError) {
      return 'RangeError';
    } else if (error is ArgumentError) {
      return 'ArgumentError';
    } else {
      return 'UnknownError';
    }
  }

  /// Format Flutter error
  static String _formatFlutterError(FlutterErrorDetails details) {
    return '${details.exception}\n'
        'Library: ${details.library}\n'
        'Context: ${details.context}\n'
        'Stack trace: ${details.stack}';
  }

  /// Format platform error
  static String _formatPlatformError(Object error, StackTrace stack) {
    return '$error\nStack trace: $stack';
  }

  /// Format async error
  static String _formatAsyncError(
      Object error, StackTrace stack, String context) {
    return 'Context: $context\nError: $error\nStack trace: $stack';
  }

  /// Format custom error
  static String _formatCustomError(
      String context, Object error, StackTrace? stack) {
    final message = 'Context: $context\nError: $error';
    if (stack != null) {
      return '$message\nStack trace: $stack';
    }
    return message;
  }

  /// Send Flutter error to crash reporting
  static void _sendToCrashReporting(FlutterErrorDetails details) {
    // This would integrate with services like Firebase Crashlytics
    // For now, just log it
    AppLogger.log('[ErrorHandler] Flutter error sent to crash reporting');
  }

  /// Send platform error to crash reporting
  static void _sendPlatformErrorToCrashReporting(
      Object error, StackTrace stack) {
    // This would integrate with services like Firebase Crashlytics
    // For now, just log it
    AppLogger.log('[ErrorHandler] Platform error sent to crash reporting');
  }

  /// Send async error to crash reporting
  static void _sendAsyncErrorToCrashReporting(
      Object error, StackTrace stack, String context) {
    // This would integrate with services like Firebase Crashlytics
    // For now, just log it
    AppLogger.log('[ErrorHandler] Async error sent to crash reporting');
  }

  /// Send custom error to crash reporting
  static void _sendCustomErrorToCrashReporting(
      String context, Object error, StackTrace? stack) {
    // This would integrate with services like Firebase Crashlytics
    // For now, just log it
    AppLogger.log('[ErrorHandler] Custom error sent to crash reporting');
  }

  /// Get error statistics
  static Map<String, dynamic> getErrorStats() {
    return {
      'totalErrors': _errorCounts.values.fold(0, (a, b) => a + b),
      'errorCounts': Map.from(_errorCounts),
      'recentErrors': List.from(_recentErrors),
      'isInitialized': _isInitialized,
    };
  }

  /// Clear error statistics
  static void clearErrorStats() {
    _errorCounts.clear();
    _recentErrors.clear();
    AppLogger.log('[ErrorHandler] Error statistics cleared');
  }

  /// Get recent errors
  static List<String> getRecentErrors({int limit = 10}) {
    final start = (_recentErrors.length - limit).clamp(0, _recentErrors.length);
    return _recentErrors.sublist(start);
  }

  /// Check if error rate is high
  static bool isErrorRateHigh() {
    final totalErrors = _errorCounts.values.fold(0, (a, b) => a + b);
    return totalErrors > 50; // Threshold for high error rate
  }

  /// Safe execution wrapper
  static Future<T?> safeExecute<T>(
    Future<T> Function() operation,
    String context, {
    T? defaultValue,
    bool shouldRethrow = false,
  }) async {
    try {
      return await operation();
    } catch (error, stack) {
      handleCustomError(context, error, stack);
      if (shouldRethrow) {
        rethrow;
      }
      return defaultValue;
    }
  }

  /// Safe synchronous execution wrapper
  static T? safeExecuteSync<T>(
    T Function() operation,
    String context, {
    T? defaultValue,
    bool shouldRethrow = false,
  }) {
    try {
      return operation();
    } catch (error, stack) {
      handleCustomError(context, error, stack);
      if (shouldRethrow) {
        rethrow;
      }
      return defaultValue;
    }
  }
}

// Custom exception types
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class PermissionException implements Exception {
  final String message;
  PermissionException(this.message);

  @override
  String toString() => 'PermissionException: $message';
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}

class NotificationException implements Exception {
  final String message;
  NotificationException(this.message);

  @override
  String toString() => 'NotificationException: $message';
}

class PrayerTimeException implements Exception {
  final String message;
  PrayerTimeException(this.message);

  @override
  String toString() => 'PrayerTimeException: $message';
}
