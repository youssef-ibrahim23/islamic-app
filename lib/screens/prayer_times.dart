import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/screens/bottom_bar.dart';
import 'package:islamic_app/services/prayer_times_services.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/prayers/next_prayer_card.dart';
import 'package:islamic_app/widgets/prayers/prayer_times_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'location_selection_page.dart';

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  Timer? _localTimer;
  final GlobalKey _prayerListKey = GlobalKey();
  bool _hasAutoScrolled = false;

  static const String _prayerChecklistDateKey = 'prayer_checklist_date';
  static const String _prayerChecklistCongratsDateKey =
      'prayer_checklist_congrats_date';
  static const List<String> _mainPrayers = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  final Map<String, bool> _prayerChecklist = {
    'Fajr': false,
    'Dhuhr': false,
    'Asr': false,
    'Maghrib': false,
    'Isha': false,
  };
  bool _isPrayerChecklistLoaded = false;
  bool _isShowingCongrats = false;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  void _initializePage() async {
    // Reset auto-scroll flag when page is opened
    _hasAutoScrolled = false;

    await _loadOrResetPrayerChecklist();

    await PrayerTimesService.checkLocationAndNavigate(
      context,
      _updateState,
      navigateOnFail: false,
    );
    _localTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateState());
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: primaryColor),
    );
  }

  void _updateState() {
    if (mounted) {
      setState(() {});

      if (_isPrayerChecklistLoaded && !_isShowingCongrats) {
        _maybeShowCongratsDialog();
      }

      // Trigger scroll to next prayer only once per page open
      if (!_hasAutoScrolled) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final prayerListState = _prayerListKey.currentState;
          if (prayerListState != null) {
            // Access the scroll method through dynamic cast
            (prayerListState as dynamic).scrollToNextPrayer();
            _hasAutoScrolled = true;
          }
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  void didPopNext() {
    // Reload prayer times when returning to this page
    // This handles the case when user returns from location selection
    PrayerTimesService.checkLocationAndNavigate(context, _updateState,
        forceGPSDetection: false, navigateOnFail: false);
    setState(() {});
  }

  @override
  void dispose() {
    Globals.timer?.cancel();
    _localTimer?.cancel();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadOrResetPrayerChecklist() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _todayKey();

    // All prayers including Sunrise
    final allPrayers = [..._mainPrayers, 'Sunrise'];

    final storedDate = prefs.getString(_prayerChecklistDateKey);
    if (storedDate != todayKey) {
      // New day -> reset all
      for (final p in allPrayers) {
        await prefs.setBool('prayer_checklist_$p', false);
        _prayerChecklist[p] = false;
      }
      await prefs.setString(_prayerChecklistDateKey, todayKey);
      await prefs.remove(_prayerChecklistCongratsDateKey);
    } else {
      // Same day -> load
      for (final p in allPrayers) {
        _prayerChecklist[p] = prefs.getBool('prayer_checklist_$p') ?? false;
      }
    }

    if (mounted) {
      setState(() {
        _isPrayerChecklistLoaded = true;
      });
    }
  }

  Future<void> _togglePrayerChecklist(String prayer, bool value) async {
    // Prevent unchecking - once checked, can only reset next day
    if (_prayerChecklist[prayer] == true) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayer_checklist_$prayer', value);
    if (!mounted) return;
    setState(() {
      _prayerChecklist[prayer] = value;
    });
    _maybeShowCongratsDialog();
  }

  bool _allPrayersDone() {
    for (final p in _mainPrayers) {
      if ((_prayerChecklist[p] ?? false) == false) return false;
    }
    return true;
  }

  Future<void> _maybeShowCongratsDialog() async {
    if (!_allPrayersDone()) return;
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _todayKey();
    final congratsShownFor = prefs.getString(_prayerChecklistCongratsDateKey);
    if (congratsShownFor == todayKey) return;
    if (!mounted) return;

    setState(() {
      _isShowingCongrats = true;
    });

    await prefs.setString(_prayerChecklistCongratsDateKey, todayKey);
    await _showCongratsDialog(Globals.languageState!);

    if (mounted) {
      setState(() {
        _isShowingCongrats = false;
      });
    }
  }

  Future<void> _showCongratsDialog(bool isEnglish) async {
    final String fontFamily = isEnglish ? 'Roboto' : 'Tajawal';

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
                        child: const Icon(
                          Icons.celebration,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isEnglish ? 'Congratulations!' : 'مبارك لك!',
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
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isEnglish
                            ? 'You have completed all 5 prayers today.'
                            : 'لقد أتممت الصلوات الخمس اليوم.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.getFont(
                          fontFamily,
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                        ),
                      ),
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
                          isEnglish ? 'OK' : 'حسناً',
                          style: GoogleFonts.getFont(
                            fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
    final bool isEnglish = Globals.languageState!;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isEnglish ? "Prayer Times" : 'مواعيد الصلاة',
          style: GoogleFonts.getFont(
            isEnglish ? 'Roboto' : 'Tajawal',
            color: Colors.white,
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            tooltip: isEnglish ? 'Notification Info' : 'معلومات التنبيهات',
            onPressed: () => _showNotificationInfoDialog(isEnglish),
          ),
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.white),
            tooltip: isEnglish ? 'Change Location' : 'تغيير الموقع',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const LocationSelectionPage()),
              );
              if (result == true) {
                await PrayerTimesService.changeLocation(context);
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: Globals.prayerTimesIsLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : (!Globals.locationSelected)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 64,
                          color: primaryColor.withOpacity(0.9),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isEnglish
                              ? 'Please choose your location to calculate prayer times.'
                              : 'يرجى اختيار موقعك لحساب مواقيت الصلاة.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.getFont(
                            isEnglish ? 'Roboto' : 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const LocationSelectionPage()),
                            );
                            if (result == true) {
                              await PrayerTimesService.changeLocation(context);
                              setState(() {});
                            }
                          },
                          icon: const Icon(Icons.edit_location_alt),
                          label: Text(
                            isEnglish ? 'Select Location' : 'اختر الموقع',
                            style: GoogleFonts.getFont(
                              isEnglish ? 'Roboto' : 'Tajawal',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SafeArea(
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/background.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      children: [
                        NextPrayerCard(
                          isEnglish: isEnglish,
                          screenWidth: screenWidth,
                        ),
                        Expanded(
                          child: PrayerTimesList(
                            key: _prayerListKey,
                            checklist: _isPrayerChecklistLoaded
                                ? _prayerChecklist
                                : null,
                            onToggleChecklist: _isPrayerChecklistLoaded
                                ? _togglePrayerChecklist
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Future<void> _showNotificationInfoDialog(bool isEnglish) async {
    final String fontFamily = isEnglish ? 'Roboto' : 'Tajawal';

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
                        child: const Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isEnglish ? 'Prayer Notifications' : 'تنبيهات الصلاة',
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
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isEnglish
                            ? 'Make sure to open the app at least once per day to receive prayer time notifications.'
                            : 'تأكد من فتح التطبيق مرة واحدة على الأقل يومياً لتلقي إشعارات مواقيت الصلاة.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.getFont(
                          fontFamily,
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                        ),
                      ),
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
                          isEnglish ? 'OK' : 'حسناً',
                          style: GoogleFonts.getFont(
                            fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
}
