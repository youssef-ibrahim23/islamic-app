// lib/widgets/settings/language_dropdown.dart

import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/screens/bottom_bar.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageDropDown extends StatelessWidget {
  final bool isEnglish;
  final Size size;
  final Function(VoidCallback fn) setState;
  final BuildContext context;

  const LanguageDropDown({
    super.key,
    required this.isEnglish,
    required this.size,
    required this.setState,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: isEnglish ? "Select Language" : "اختر اللغة",
        labelStyle: TextStyle(
          color: primaryColor,
          fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      dropdownColor: Colors.white,
      style: TextStyle(
        color: textColor,
        fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
      ),
      icon: Icon(Icons.arrow_drop_down, color: primaryColor),
      value: Globals.selectedLanguage,
      items: Globals.languages.map((language) {
        return DropdownMenuItem<String>(
          value: language,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Directionality(
              textDirection: Globals.languageState! ? TextDirection.ltr : TextDirection.rtl,
              child: Text(
                language,
                style: TextStyle(
                  fontFamily: language == 'English' ? 'Roboto' : 'Tajawal',
                ),
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: (value) async {
        final sharedPreferences = await SharedPreferences.getInstance();
        setState(() {
          Globals.selectedLanguage = value!;
          Globals.languageState = value == "English";
        });

        await sharedPreferences.setBool("language", Globals.languageState!);
        Navigator.push(context, MaterialPageRoute(builder: (context) => const BottomBar()));
      },
    );
  }
}



