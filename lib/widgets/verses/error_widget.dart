import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorrWidget extends StatelessWidget {
  final String errorMessage;
  final Color primaryColor;
  final Color textColor;
  final String fontFamily;
  final bool isEnglish;
  final VoidCallback onRetry;

  const ErrorrWidget({
    super.key,
    required this.errorMessage,
    required this.primaryColor,
    required this.textColor,
    required this.fontFamily,
    required this.isEnglish,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: primaryColor, size: 48),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.getFont(
                fontFamily,
                color: textColor,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              isEnglish ? 'Retry' : 'إعادة المحاولة',
              style: GoogleFonts.getFont(
                fontFamily,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}