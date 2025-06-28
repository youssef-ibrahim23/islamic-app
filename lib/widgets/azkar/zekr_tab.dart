import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/azkar_services.dart';

class ZekrTab{
  static void handleZikrTap(int index, int count) {
    Globals.currentCounts[index] = (Globals.currentCounts[index] ?? 0) - 1;

    // If completed
    if (Globals.currentCounts[index]! <= 0) {
      Globals.completionCounts[index] = (Globals.completionCounts[index] ?? 0) + 1;

      // Reset current count
      Globals.currentCounts[index] = count;

      // Save updated completion count
      AzkarService.saveCompletionCount(index, Globals.completionCounts[index]!);

    }
  }
}