import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/azkar_services.dart';

class ZekrTab {
  static Future<void> handleZikrTap(
      String category, int index, int count) async {
    // Ensure the maps exist for the category
    Globals.currentCounts[category] ??= {};
    Globals.completionCounts[category] ??= {};
    Globals.azkarCardLocked[category] ??= {};

    // Check if this specific card is locked
    if (Globals.azkarCardLocked[category]![index] == true) {
      print('🔒 Card $index is already locked, returning');
      return;
    }

    // Decrease current count
    final int current = (Globals.currentCounts[category]![index] ?? count) - 1;
    Globals.currentCounts[category]![index] = current;
    await AzkarService.saveCurrentCount(category, index, current);

    print('📊 Card $index: current count = $current');

    // Check if completed
    if (Globals.currentCounts[category]![index]! <= 0) {
      Globals.completionCounts[category]![index] =
          (Globals.completionCounts[category]![index] ?? 0) + 1;

      // Keep counter at 0 for the rest of the day
      Globals.currentCounts[category]![index] = 0;
      await AzkarService.saveCurrentCount(category, index, 0);

      // Lock this specific card only
      Globals.azkarCardLocked[category]![index] = true;
      await AzkarService.setCardLocked(category, index, true);

      print(
          '✅ Card $index completed and locked. Completion count: ${Globals.completionCounts[category]![index]}');
      print(
          '🔐 Locked map for $category: ${Globals.azkarCardLocked[category]}');

      // Save completion to SharedPreferences
      await AzkarService.saveCompletionCount(
        category,
        index,
        Globals.completionCounts[category]![index]!,
      );
    }
  }
}
