// lib/services/more_services.dart

import 'package:flutter/material.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../globals.dart';

class MoreService {
  /// Launches an external URL using the provided [url] and shows a snackbar on error
  static Future<void> launchExternalUrl(BuildContext context, String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Globals.languageState!
                ? "Failed to open the link. Please try again."
                : "فشل فتح الرابط. يرجى المحاولة مرة أخرى.",
          ),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  /// Sets the app language preference in local storage
  static Future<void> setLanguage(bool isEnglish) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("language", isEnglish);
    Globals.languageState = isEnglish;
    Globals.selectedLanguage = isEnglish ? "English" : "العربية";
  }
}
