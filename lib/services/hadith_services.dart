// lib/services/hadith_service.dart
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/models/hadith.dart';
import 'package:islamic_app/globals.dart';

class HadithService {
  static Future<void> loadInitialRange(Function(bool) setLoading, Function() refreshUI) async {
    final prefs = await SharedPreferences.getInstance();
    Globals.currentRangeStart = prefs.getInt("bukhari_range_start") ?? 1;
    Globals.currentRangeEnd = Globals.currentRangeStart + Globals.rangeSize - 1;
    await loadHadiths(Globals.currentRangeStart, Globals.currentRangeEnd, setLoading, refreshUI);
  }

  static Future<void> loadHadiths(int start, int end, Function(bool) setLoading, Function() refreshUI) async {
    setLoading(true);
    try {
      final List<Hadith> hadiths = await Hadith.loadHadithsByRange(start, end);
      Globals.hadiths = hadiths;
    } catch (e) {
      Globals.hadiths = [];
    } finally {
      setLoading(false);
      refreshUI();
    }
  }

  static Future<void> loadNextRange(Function(bool) setLoading, Function() refreshUI) async {
    final newStart = Globals.currentRangeStart + Globals.rangeSize;
    final newEnd = newStart + Globals.rangeSize - 1;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("bukhari_range_start", newStart);

    Globals.currentRangeStart = newStart;
    Globals.currentRangeEnd = newEnd;

    await loadHadiths(newStart, newEnd, setLoading, refreshUI);
  }

  static Future<void> loadPreviousRange(Function(bool) setLoading, Function() refreshUI) async {
    if (Globals.currentRangeStart <= 1) return;

    final newStart = Globals.currentRangeStart - Globals.rangeSize;
    final newEnd = newStart + Globals.rangeSize - 1;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("bukhari_range_start", newStart);

    Globals.currentRangeStart = newStart;
    Globals.currentRangeEnd = newEnd;

    await loadHadiths(newStart, newEnd, setLoading, refreshUI);
  }

  static String convertNumbersToArabic(String input, bool isEnglish) {
  if (isEnglish) {
    return input; // Return as-is for English
  }
  
  // Define Arabic numerals
  const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  
  // Convert each digit in the string
  return input.replaceAllMapped(RegExp(r'[0-9]'), (match) {
    final digit = int.parse(match.group(0)!);
    return arabicNumerals[digit];
  });
}

static void shareHadith(Hadith hadith, bool isEnglish) {
  final String reference = Globals.referenceUrl.isNotEmpty ? '\n\nReference: $Globals.referenceUrl' : '';
  final hadithNumber = HadithService.convertNumbersToArabic(hadith.number.toString(), isEnglish);
  
  final String shareText = isEnglish
      ? '''
Hadith #${hadith.number} - Sahih al-Bukhari

${hadith.arab}

${hadith.id}$reference

Shared via Islamic App
'''
      : '''
حديث رقم $hadithNumber - صحيح البخاري

${hadith.arab}

${hadith.id}$reference

تمت المشاركة عبر تطبيق إسلامي
''';

  Share.share(
    shareText,
    subject: isEnglish 
        ? 'Hadith from Sahih al-Bukhari' 
        : 'حديث من صحيح البخاري',
  );
}


}
