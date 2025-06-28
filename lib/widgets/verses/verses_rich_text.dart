// widgets/verse_rich_text.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class VerseRichText extends StatelessWidget {
  final List<InlineSpan> spans;
  final double fontSize;
  final String arabicFontFamily;
  final Function(int) onVerseTap;

  const VerseRichText({
    super.key,
    required this.spans,
    required this.fontSize,
    required this.arabicFontFamily,
    required this.onVerseTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;
        
        final offset = details.localPosition;
        final position = renderBox.globalToLocal(offset);
        
        final textPainter = TextPainter(
          text: TextSpan(children: spans),
          textDirection: TextDirection.rtl,
        )..layout(maxWidth: renderBox.size.width);
        
        final tappedPosition = textPainter.getPositionForOffset(position);
        final tappedText = textPainter.text!.getSpanForPosition(tappedPosition);
        
        if (tappedText is TextSpan && tappedText.recognizer != null) {
          (tappedText.recognizer as TapGestureRecognizer).onTap?.call();
        }
      },
      child: RichText(
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        text: TextSpan(
          children: spans,
          style: TextStyle(
            fontSize: fontSize,
            height: 2.0,
            fontFamily: arabicFontFamily,
          ),
        ),
      ),
    );
  }
}