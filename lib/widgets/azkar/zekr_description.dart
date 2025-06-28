import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/widgets/app_them.dart';

class ZekrDescription {
  static Widget buildDescription(String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withOpacity(0.1), width: 1),
      ),
      child: Directionality(
        textDirection: Globals.languageState! ? TextDirection.ltr : TextDirection.rtl,
        child: Text(
          description,
          textAlign: TextAlign.justify,
          style: GoogleFonts.getFont(
            Globals.languageState! ? 'Roboto' : 'Tajawal',
            color: textColor.withOpacity(0.8),
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
