import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingWidget extends StatelessWidget {
  final Color primaryColor;
  final Color textColor;
  final String fontFamily;
  final bool isEnglish;

  const LoadingWidget({
    super.key,
    required this.primaryColor,
    required this.textColor,
    required this.fontFamily,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            isEnglish ? 'Loading Surah...' : 'جاري تحميل السورة...',
            style: GoogleFonts.getFont(
              fontFamily,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}