import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/prayers/prayer_time_tile.dart';

class PrayerTimesList extends StatefulWidget {
  const PrayerTimesList({
    Key? key,
    this.checklist,
    this.onToggleChecklist,
  }) : super(key: key);

  static const List<String> mainPrayers = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  final Map<String, bool>? checklist;
  final void Function(String prayer, bool value)? onToggleChecklist;

  @override
  State<PrayerTimesList> createState() => _PrayerTimesListState();
}

class _PrayerTimesListState extends State<PrayerTimesList> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _prayerKeys = {};
  String? _lastNextPrayer;

  @override
  void initState() {
    super.initState();
    // Auto-scroll to next prayer after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToNextPrayer();
    });
  }

  @override
  void didUpdateWidget(PrayerTimesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if next prayer has changed and scroll to it
    if (_lastNextPrayer != Globals.nextPrayer) {
      _lastNextPrayer = Globals.nextPrayer;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToNextPrayer();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToNextPrayer() {
    if (Globals.nextPrayer == null || Globals.prayerTimes == null) return;

    final nextPrayerKey = _prayerKeys[Globals.nextPrayer];
    final context = nextPrayerKey?.currentContext;

    if (context != null) {
      Scrollable.ensureVisible(
        context,
        alignment: 0.3, // Position at 30% from top
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

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
        controller: _scrollController,
        child: Column(
          children: [
            if (Globals.prayerTimes != null)
              ...Globals.prayerTimes!.entries.map(
                (entry) {
                  // Create or get GlobalKey for this prayer
                  final key = _prayerKeys.putIfAbsent(
                    entry.key,
                    () => GlobalKey(),
                  );

                  // Show checkbox on all prayers when checklist is available
                  final canShowChecklist = widget.checklist != null &&
                      widget.onToggleChecklist != null;

                  return PrayerTimeTileWidget(
                    key: key,
                    prayerName: entry.key,
                    prayerTime: entry.value,
                    isChecked: canShowChecklist
                        ? (widget.checklist![entry.key] ?? false)
                        : null,
                    onCheckedChanged: canShowChecklist
                        ? (value) => widget.onToggleChecklist!(entry.key, value)
                        : null,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
