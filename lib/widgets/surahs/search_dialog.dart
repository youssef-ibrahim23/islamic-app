import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/widgets/app_them.dart';

class SearchDialog {
  static Widget buildSearchDialog(
      BuildContext context, TextEditingController searchControllerr) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Directionality(
        textDirection: Globals.textDirection,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Globals.languageState! ? "Search Surah" : "بحث عن سورة",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                  fontFamily: Globals.fontFamily,
                ),
              ).animate().fadeIn(duration: 200.ms),
              const SizedBox(height: 16),
              TextField(
                controller: searchControllerr,
                textAlign: Globals.languageState! ? TextAlign.left : TextAlign.right,
                decoration: InputDecoration(
                  hintText:
                      Globals.languageState! ? "Enter Surah Name" : "أدخل اسم السورة",
                  hintStyle: TextStyle(
                    color: secondaryTextColor,
                    fontFamily: Globals.fontFamily,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: primaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                style: TextStyle(
                  fontFamily: Globals.fontFamily,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      searchControllerr.clear();
                      Navigator.pop(context);
                    },
                    child: Text(
                      Globals.languageState! ? "Cancel" : "إلغاء",
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontFamily: Globals.fontFamily,
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      Globals.languageState! ? "Search" : "بحث",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: Globals.fontFamily,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ],
              ),
            ],
          ),
        ),
      ).animate().scaleXY(begin: 0.9),
    );
  }
}
