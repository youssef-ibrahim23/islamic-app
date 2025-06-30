import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/prayers/prayer_time_tile.dart';

class PrayerTimesList extends StatelessWidget {
  const PrayerTimesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (Globals.prayerTimes != null)
              ...Globals.prayerTimes!.entries.map(
                (entry) => PrayerTimeTileWidget(
                  prayerName: entry.key,
                  prayerTime: entry.value,
                ),
              ),
          ],
        ),
      ),
    );
  }
}