import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/models/Azkar.dart';
import 'package:islamic_app/services/azkar_services.dart';
import 'package:islamic_app/widgets/azkar/azkar_card.dart';

class AzkarList extends StatefulWidget {
  final List<Azkar> azkarList;

  const AzkarList({super.key, required this.azkarList});

  // You can still use this as a builder
  static Widget buildAzkarList(List<Azkar> azkarList) {
    return AzkarList(azkarList: azkarList);
  }

  @override
  State<AzkarList> createState() => _AzkarListState();
}

class _AzkarListState extends State<AzkarList> {
  @override
  void initState() {
    super.initState();

    // Initialize completionCounts from SharedPreferences
    for (int i = 0; i < widget.azkarList.length; i++) {
      final azkar = widget.azkarList[i];
      final count = int.tryParse(azkar.count) ?? 1;
      final displayCount = count == 1 ? 3 : count;

      Globals.currentCounts[i] ??= displayCount;
      Globals.completionCounts[i] = AzkarService.loadCompletionCount(i);
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

        // Pass a callback to update the state
        return AzkarCard(
          index: index,
          azkar: azkar,
          count: displayCount,
          onChanged: () {
            setState(() {});
          },
        );
      },
    );
  }
}
