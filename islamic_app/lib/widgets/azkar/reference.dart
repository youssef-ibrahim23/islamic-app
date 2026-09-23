import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/widgets/app_them.dart';

class Reference extends StatelessWidget {
  final String reference;

  const Reference({Key? key, required this.reference}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Globals.languageState! ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Directionality(
          textDirection: Globals.languageState! ? TextDirection.ltr : TextDirection.rtl,
          child: Text(
            reference,
            style: GoogleFonts.getFont(
              Globals.languageState! ? 'Roboto' : 'Tajawal',
              color: primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
