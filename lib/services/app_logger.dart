class AppLogger {
  static void log(String message, {String? name}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] ${name != null ? "[$name] " : ""}$message';

    print(logMessage);
  }
}


