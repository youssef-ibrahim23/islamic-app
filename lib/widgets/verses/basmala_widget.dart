// widgets/basmala_widget.dart
import 'package:flutter/material.dart';

class BasmalaWidget extends StatelessWidget {
  final Color primaryColor;
  final double fontSize;
  final String arabicFontFamily;

  const BasmalaWidget({
    super.key,
    required this.primaryColor,
    required this.fontSize,
    required this.arabicFontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
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
        " ( بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ )",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: arabicFontFamily,
          fontSize: fontSize + 4,
          fontWeight: FontWeight.bold,
          color: primaryColor,
          height: 1.8,
        ),
      ),
    );
  }
}