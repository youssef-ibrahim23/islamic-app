// ignore_for_file: deprecated_member_use

import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:islamic_app/models/verse.dart';

class VerseService {
  static String normalizeArabic(String input) {
    final diacritics = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');
    String normalized = input.replaceAll(diacritics, '');
    return normalized.replaceAll('ٱ', 'ا');
  }

  static String toArabicNumber(int number, bool withIcon) {
    final arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final arabicNumber = number.toString().split('').map((d) => arabicDigits[int.parse(d)]).join();
    return withIcon ? '۝$arabicNumber' : arabicNumber;
  }

  static String combineVersesWithIcons(List<Verse> verses) {
    final buffer = StringBuffer();
    for (int i = 0; i < verses.length; i++) {
      buffer.write(verses[i].textUthmani);
      buffer.write(' ${toArabicNumber(i + 1, true)}');
      if (i < verses.length - 1) buffer.write(' ');
    }
    return buffer.toString();
  }

  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<void> shareVerse({
    required Verse verse,
    required int verseNumber,
    required String surahName,
    required String arabicName,
    required bool isEnglish,
  }) async {
    final arabicNumber = toArabicNumber(verseNumber, false);
    final verseText = '${verse.textUthmani.trim()} ($arabicNumber)';
    final name = isEnglish ? surahName : arabicName;

    Share.share(
      isEnglish
          ? '$name, Verse $verseNumber:\n\n$verseText\n\n- Shared via Islamic App'
          : '$name، الآية $arabicNumber:\n\n$verseText\n\n- مشاركة من تطبيق القرآن',
      subject: isEnglish
          ? 'Quran Verse - $name $verseNumber'
          : 'آية قرآنية - $name $arabicNumber',
    );
  }
}