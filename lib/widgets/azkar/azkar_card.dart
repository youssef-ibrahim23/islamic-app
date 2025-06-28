import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/models/Azkar.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/azkar/counter_header.dart';
import 'package:islamic_app/widgets/azkar/reference.dart';
import 'package:islamic_app/widgets/azkar/zekr_description.dart';
import 'package:islamic_app/widgets/azkar/zekr_tab.dart';

class AzkarCard{
  static Widget buildAzkarCard(
  int index,
  Azkar azkar,
  int count,
  VoidCallback onChanged,
) {
  final current = Globals.currentCounts[index]!;
  final completed = Globals.completionCounts[index]!;

  return Stack(
    children: [
      Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            ZekrTab.handleZikrTap(index, count);
            onChanged(); // Trigger UI update
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (count > 1)
                  CounterHeader.buildCounterHeader(
                    index,
                    Globals.currentCounts[index]!,
                    count,
                    Globals.completionCounts[index]!,
                  ),
                const SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    azkar.content,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.scheherazadeNew(
                      color: textColor,
                      fontSize: 24,
                      height: 1.8,
                    ),
                  ),
                ),
                if (azkar.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ZekrDescription.buildDescription(azkar.description),
                ],
                if (azkar.reference.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Reference.buildReference(azkar.reference),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      // Plus Button
      Positioned(
        bottom: 8,
        left: 8,
        child: InkWell(
          onTap: () {
            ZekrTab.handleZikrTap(index, count);
            onChanged(); // Trigger rebuild
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 24),
          ),
        ),
      ),
    ],
  );
}


}