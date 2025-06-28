import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/widgets/app_them.dart';

class CustomChip  {
  static Widget buildChip({required String label, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: primaryColor, size: 16),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.getFont(
              Globals.languageState! ? 'Roboto' : 'Tajawal',
              color: primaryColor,
              fontSize: Globals.languageState! ? 11 : 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
