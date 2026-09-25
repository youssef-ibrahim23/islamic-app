import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/models/Azkar.dart';
import 'package:islamic_app/services/azkar_services.dart';
import 'package:islamic_app/widgets/app_them.dart';
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
  bool get isEnglish => Globals.languageState ?? true;
  String get fontFamily => isEnglish ? 'Roboto' : 'Tajawal';

  @override
  void initState() {
    super.initState();

    _initializeData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForNewDayAndShowWelcome();
    });
  }

  Future<void> _initializeData() async {
    Globals.currentCounts[widget.category] ??= {};
    Globals.completionCounts[widget.category] ??= {};

    // Always create a fresh map for locked state to avoid stale data
    Globals.azkarCardLocked[widget.category] = {};

    for (int i = 0; i < widget.azkarList.length; i++) {
      final azkar = widget.azkarList[i];
      final count = int.tryParse(azkar.count) ?? 1;
      final displayCount = count == 1 ? 3 : count;

      Globals.currentCounts[widget.category]![i] ??=
          AzkarService.loadCurrentCount(widget.category, i, displayCount);

      final savedCompletion =
          AzkarService.loadCompletionCount(widget.category, i);
      Globals.completionCounts[widget.category]![i] = savedCompletion;

      final isLocked = AzkarService.isCardLocked(widget.category, i);
      Globals.azkarCardLocked[widget.category]![i] = isLocked;

      print(
          '📥 Init card $i: isLocked=$isLocked, completion=$savedCompletion, current=${Globals.currentCounts[widget.category]![i]}');
    }

    print(
        '🔐 Final locked map for ${widget.category}: ${Globals.azkarCardLocked[widget.category]}');
  }

  Future<void> _checkForNewDayAndShowWelcome() async {
    if (!mounted) return;

    final wasNewDay = await AzkarService.forceCheckAndResetDaily();

    if (wasNewDay && AzkarService.shouldShowNewDayWelcome()) {
      await AzkarService.markNewDayWelcomeShown();

      if (!mounted) return;

      await _showStyledDialog(
        icon: Icons.wb_sunny_outlined,
        title: isEnglish ? 'New Day!' : 'يوم جديد!',
        content: isEnglish
            ? 'A new day has begun! All azkar counters have been reset. Complete your azkar today to earn rewards.'
            : 'بدأ يوم جديد! تم إعادة تعيين جميع عدادات الأذكار. أكمل أذكارك اليوم لكسب المكافآت.',
        buttonText: isEnglish ? 'Let\'s Start!' : 'لنبدأ!',
      );

      if (mounted) {
        setState(() {
          _initializeData();
        });
      }
    } else {
      _checkAndShowCompletionDialogIfNeeded();
    }
  }

  Future<void> _checkAndShowCompletionDialogIfNeeded() async {
    if (!mounted) return;

    final lockedMap = Globals.azkarCardLocked[widget.category] ?? {};

    int finishedCount = 0;
    for (int i = 0; i < widget.azkarList.length; i++) {
      if (lockedMap[i] == true) finishedCount++;
    }

    if (finishedCount < widget.azkarList.length) return;

    if (AzkarService.isCompletionDialogShown(widget.category)) return;
    await AzkarService.markCompletionDialogShown(widget.category);

    if (!mounted) return;
    await _showStyledDialog(
      icon: Icons.check_circle_outline,
      title: isEnglish ? 'Azkar Completed!' : 'تم الانتهاء من الأذكار!',
      content: isEnglish
          ? 'You have finished all today\'s azkar. Great job! You can browse the azkar but cannot click them again until tomorrow.'
          : 'لقد أنهيت جميع أذكار اليوم. أحسنت! يمكنك تصفح الأذكار ولكن لا يمكنك النقر عليها مرة أخرى حتى الغد.',
      buttonText: isEnglish ? 'OK' : 'حسناً',
    );
  }

  Future<void> _showStyledDialog({
    required IconData icon,
    required String title,
    required String content,
    required String buttonText,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -15,
                  left: -15,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 32,
                        ),
                      )
                          .animate()
                          .scale(delay: 200.ms, duration: 300.ms)
                          .then()
                          .shimmer(
                              delay: 600.ms,
                              duration: 1000.ms,
                              color: Colors.white.withOpacity(0.3)),
                      const SizedBox(height: 20),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.getFont(
                          fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                      const SizedBox(height: 12),
                      Text(
                        content,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.getFont(
                          fontFamily,
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                        ),
                      ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                        ),
                        child: Text(
                          buttonText,
                          style: GoogleFonts.getFont(
                            fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms, duration: 300.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
              category: widget.category,
              index: index,
              azkar: azkar,
              count: displayCount,
              onChanged: () {
                setState(() {});
                _checkAndShowCompletionDialogIfNeeded();
              },
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}
