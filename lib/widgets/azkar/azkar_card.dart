import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/models/Azkar.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/azkar/counter_header.dart';
import 'package:islamic_app/widgets/azkar/reference.dart';
import 'package:islamic_app/widgets/azkar/zekr_description.dart';
import 'package:islamic_app/widgets/azkar/zekr_tab.dart';

class AzkarCard extends StatelessWidget {
  final int index;
  final String category; // ✅ This must be added
  final Azkar azkar;
  final int count;
  final VoidCallback onChanged;

  const AzkarCard({
    Key? key,
    required this.index,
    required this.category, // ✅ Include in constructor
    required this.azkar,
    required this.count,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Correct
final current = Globals.currentCounts[category]?[index] ?? count;
final completed = Globals.completionCounts[category]?[index] ?? 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              ZekrTab.handleZikrTap(category, index, count); // <-- Category-aware tap
              onChanged();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (count > 1)
                    CounterHeader(
                      index: index,
                      current: current,
                      total: count,
                      completed: completed,
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
                    ZekrDescription(description: azkar.description),
                  ],
                  if (azkar.reference.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Reference(reference: azkar.reference),
                  ],
                  const SizedBox(height: 48), // Leave more space for the button
                ],
              ),
            ),
          ),
        ),

        // Floating + button
        Positioned(
          bottom: -12,
          left: 12,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () {
                ZekrTab.handleZikrTap(category, index, count); // <-- Category-aware tap
                onChanged();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
