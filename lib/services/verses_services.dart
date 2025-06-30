class VersesServices{
  static String normalizeArabic(String input) {
    final diacritics = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');
    String normalized = input.replaceAll(diacritics, '');
    normalized = normalized.replaceAll(RegExp(r'[إأٱآ]'), 'ا');
    normalized = normalized.replaceAll('ى', 'ي');
    normalized = normalized.replaceAll('ؤ', 'و');
    normalized = normalized.replaceAll('ئ', 'ي');
    normalized = normalized.replaceAll('ـ', '');
    return normalized;
  }

  static String toArabicNumber(int number, bool withIcon) {
    final arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final arabicNumber = number.toString().split('').map((d) {
      return arabicDigits[int.parse(d)];
    }).join();
    return withIcon ? '۝$arabicNumber' : arabicNumber;
  }
}