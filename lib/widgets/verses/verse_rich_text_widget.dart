// widgets/verse_rich_text_widget.dart
import 'package:flutter/material.dart';

class VerseRichTextWidget extends StatelessWidget {
  final List<InlineSpan> spans;
  final double fontSize;
  final String arabicFontFamily;
  final Color textColor;

  const VerseRichTextWidget({
    super.key,
    required this.spans,
    required this.fontSize,
    required this.arabicFontFamily,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: RichText(
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        text: TextSpan(
          children: spans,
          style: TextStyle(
            fontSize: fontSize,
            height: 2.0,
            fontFamily: arabicFontFamily,
            color: textColor,
          ),
        ),
      ),
    );
  }
}