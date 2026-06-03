// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/app_logger.dart';
import 'package:islamic_app/widgets/app_them.dart';

class MoreService {
  /// Launches an external URL using the provided [url].
  /// Shows a snackbar if launching fails.
  static Future<void> launchExternalUrl(
      BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      print('🔗 Launching URI: $uri');

      // 🔸 Add this check before trying to launch
      if (uri.scheme == 'mailto') {
        _showSnackBar(
            context,
            Globals.languageState!
                ? "Email links require an email app."
                : "روابط البريد تتطلب تطبيق بريد إلكتروني.");
        return;
      }

      final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (!launched) {
        throw 'launchUrl returned false';
      }
    } catch (e) {
      print('❌ Exception: $e');
      _showSnackBar(
        context,
        Globals.languageState!
            ? "Failed to open the link. Please try again."
            : "فشل فتح الرابط. يرجى المحاولة مرة أخرى.",
      );
    }
  }

  /// Updates the app language preference
  static Future<void> setLanguage(bool isEnglish) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("language", isEnglish);
      Globals.languageState = isEnglish;
      Globals.selectedLanguage = isEnglish ? "English" : "العربية";
    } catch (e) {
      AppLogger.log("❌ Error setting language preference: $e",
          name: "MoreServices");
    }
  }

  /// Helper to display a styled snackbar
  static void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: primaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
