// widgets/basmala.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BasmalaWidget extends StatelessWidget {
  final Color primaryColor;
  final String arabicFontFamily;

  const BasmalaWidget({
    super.key,
    required this.primaryColor,
    required this.arabicFontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Text(
        "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
        textAlign: TextAlign.center,
        style: GoogleFonts.getFont(
          arabicFontFamily,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: primaryColor,
          height: 1.8,
        ),
      ),
    );
  }
}