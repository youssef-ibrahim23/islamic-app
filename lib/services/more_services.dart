import 'package:flutter/material.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../globals.dart';

class MoreService {
  /// Launches an external URL using the provided [url].
  /// Shows a snackbar if launching fails.
  static Future<void> launchExternalUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar(context,
            Globals.languageState!
                ? "Cannot open the link."
                : "تعذر فتح الرابط.");
      }
    } catch (e) {
      debugPrint("❌ URL launch failed: $e");
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
      debugPrint("❌ Error setting language preference: $e");
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
