// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../globals.dart';

class MoreService {
  /// Launches a link: http, mailto, etc.
  static Future<void> launchExternalUrl(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      print('🔗 Launching URI: $uri');

      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) throw 'Cannot launch this URL';

      final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (!launched) throw 'launchUrl returned false';
    } catch (e) {
      print('❌ Exception launching: $e');
      _showSnackBar(
        context,
        Globals.languageState!
            ? "Failed to open the link. Please try again."
            : "فشل فتح الرابط. يرجى المحاولة مرة أخرى.",
      );
    }
  }

  /// Language settings
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

  /// Show snackbar
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
