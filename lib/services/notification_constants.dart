/// Centralized notification constants and utilities
class NotificationConstants {
  // Channel IDs
  static const String prayerChannel = 'prayer_channel';
  static const String prayerScheduleChannel = 'prayer_schedule_channel';
  static const String azkarReminderChannel = 'azkar_reminder_channel';
  // Test channel removed for production

  // Channel Names
  static const String prayerChannelName = 'Prayer Notifications';
  static const String prayerScheduleChannelName = 'Prayer Time Scheduler';
  static const String azkarReminderChannelName = 'Azkar Reminders';
  // Test channel name removed for production

  // Channel Descriptions
  static const String prayerChannelDescription =
      'Channel for prayer time alerts';
  static const String prayerScheduleChannelDescription =
      'Channel for prayer scheduling notifications';
  static const String azkarReminderChannelDescription =
      'Channel for Azkar and Quran reminders';
  // Test channel description removed for production

  // Notification IDs
  static const int nextPrayerNotificationId = 1001;
  // Test notification IDs removed for production
  static const int morningAzkarId = 999997;
  static const int eveningAzkarId = 999996;
  static const int sleepingAzkarId = 999995;
  static const int quranReminderId = 999998;
  static const int surahKahfId = 999994;

  // Prayer name mappings
  static const Map<String, String> prayerNamesEnglish = {
    'Fajr': 'Fajr',
    'Dhuhr': 'Dhuhr',
    'Asr': 'Asr',
    'Maghrib': 'Maghrib',
    'Isha': 'Isha',
  };

  static const Map<String, String> prayerNamesArabic = {
    'Fajr': 'الفجر',
    'Dhuhr': 'الظهر',
    'Asr': 'العصر',
    'Maghrib': 'المغرب',
    'Isha': 'العشاء',
  };

  // Prayer order for scheduling
  static const List<String> orderedPrayers = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  // Generate prayer notification ID
  static int generatePrayerNotificationId(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return 1001;
      case 'Dhuhr':
        return 1002;
      case 'Asr':
        return 1003;
      case 'Maghrib':
        return 1004;
      case 'Isha':
        return 1005;
      default:
        return 1000;
    }
  }

  // Get prayer display name based on language
  static String getPrayerDisplayName(String prayerName, bool isEnglish) {
    if (isEnglish) {
      return prayerNamesEnglish[prayerName] ?? prayerName;
    } else {
      return prayerNamesArabic[prayerName] ?? prayerName;
    }
  }

  // Get next prayer name based on current time
  static String getNextPrayerByHour() {
    final hour = DateTime.now().hour;
    if (hour >= 19 || hour < 5) return 'Fajr';
    if (hour < 12) return 'Dhuhr';
    if (hour < 16) return 'Asr';
    if (hour < 19) return 'Maghrib';
    return 'Isha';
  }
}
