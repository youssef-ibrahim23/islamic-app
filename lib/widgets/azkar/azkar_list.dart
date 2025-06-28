import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/models/Azkar.dart';
import 'package:islamic_app/services/azkar_services.dart';
import 'package:islamic_app/widgets/azkar/azkar_card.dart';

class AzkarList extends StatefulWidget {
  final String category; // <-- Add category
  final List<Azkar> azkarList;

  const AzkarList({
    super.key,
    required this.category,
    required this.azkarList,
  });

  // Optional builder method
  static Widget buildAzkarList(String category, List<Azkar> azkarList) {
    return AzkarList(category: category, azkarList: azkarList);
  }

  @override
  State<AzkarList> createState() => _AzkarListState();
}

class _AzkarListState extends State<AzkarList> {
  @override
  void initState() {
    super.initState();

    // Initialize currentCounts and completionCounts for this category
    Globals.currentCounts[widget.category] ??= {};
    Globals.completionCounts[widget.category] ??= {};

    for (int i = 0; i < widget.azkarList.length; i++) {
      final azkar = widget.azkarList[i];
      final count = int.tryParse(azkar.count) ?? 1;
      final displayCount = count == 1 ? 3 : count;

      Globals.currentCounts[widget.category]![i] ??= displayCount;
      Globals.completionCounts[widget.category]![i] =
          AzkarService.loadCompletionCount(widget.category, i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: widget.azkarList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final azkar = widget.azkarList[index];
        final count = int.tryParse(azkar.count) ?? 1;
        final displayCount = count == 1 ? 3 : count;

        return Column(
          children: [
            AzkarCard(
              category: widget.category, // <-- Pass category here
              index: index,
              azkar: azkar,
              count: displayCount,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}
