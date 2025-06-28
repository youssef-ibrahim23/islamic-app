import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/azkar_services.dart';

class ZekrTab {
  static void handleZikrTap(String category, int index, int count) {
    // Ensure the maps exist for the category
    Globals.currentCounts[category] ??= {};
    Globals.completionCounts[category] ??= {};

    // Decrease current count
    Globals.currentCounts[category]![index] =
        (Globals.currentCounts[category]![index] ?? count) - 1;

    // Check if completed
    if (Globals.currentCounts[category]![index]! <= 0) {
      Globals.completionCounts[category]![index] =
          (Globals.completionCounts[category]![index] ?? 0) + 1;

      // Reset counter
      Globals.currentCounts[category]![index] = count;

      // Save completion to SharedPreferences
      AzkarService.saveCompletionCount(
        category,
        index,
        Globals.completionCounts[category]![index]!,
      );
    }
  }
}
