// ignore_for_file: unused_field, depend_on_referenced_packages, use_build_context_synchronously, deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/services/quran_services.dart';
import 'package:islamic_app/services/surahs_list_services.dart';
import 'package:islamic_app/data/mushaf_page_map.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/models/verse.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/screens/tajweed_marks_page.dart';
import 'package:islamic_app/screens/tafsir_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SurahDetailPage extends StatefulWidget {
  final int surahId;
  final String surahName;
  final String arabicName;
  final int? targetVerseNumber; // New parameter for scrolling to specific verse
  final String?
      openSource; // New parameter: 'daily_ayah', 'surah_list', 'other'

  const SurahDetailPage(
    this.surahName,
    this.surahId,
    this.arabicName, {
    super.key,
    this.targetVerseNumber,
    this.openSource,
  });

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage>
    with WidgetsBindingObserver {
  final Color _primaryColor = const Color(0xFF8B0000);
  final Color _textColor = const Color(0xFF333333);
  final Color _cardColor = Colors.white;
  final PageController _pageController = PageController();
  final Map<int, ScrollController> _pageScrollControllers = {};
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _searchController = TextEditingController();
  bool _isFirstTimeOpen = true;

  String? _selectedReaderKey;

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const int _mediaNotificationId = 999999;

  final List<String> _khatmaDuaPages = [
    // Page 1
    'اللَّهُمَّ ارْحَمْنِي بِالقُرْآنِ وَاجْعَلْهُ لِي إِمَامًا وَنُورًا وَهُدًى وَرَحْمَةً *\n\nاللَّهُمَّ ذَكِّرْنِي مِنْهُ مَا نَسِيتُ وَعَلِّمْنِي مِنْهُ مَا جَهِلْتُ وَارْزُقْنِي تِلَاوَتَهُ آنَاءَ اللَّيْلِ وَأَطْرَافَ النَّهَارِ وَاجْعَلْهُ لِي حُجَّةً يَا رَبَّ العَالَمِينَ *\n\nاللَّهُمَّ اجْعَلِ القُرْآنَ رَبِيعَ قُلُوبِنَا وَنُورَ صُدُورِنَا وَجَلَاءَ أَحْزَانِنَا وَذَهَابَ هُمُومِنَا وَغُمُومِنَا *',

    // Page 2
    'اللَّهُمَّ أَصْلِحْ لِي دِينِي الَّذِي هُوَ عِصْمَةُ أَمْرِي، وَأَصْلِحْ لِي دُنْيَايَ الَّتِي فِيهَا مَعَاشِي، وَأَصْلِحْ لِي آخِرَتِي الَّتِي فِيهَا مَعَادِي، وَاجْعَلِ الحَيَاةَ زِيَادَةً لِي فِي كُلِّ خَيْرٍ، وَاجْعَلِ المَوْتَ رَاحَةً لِي مِنْ كُلِّ شَرٍّ *\n\nاللَّهُمَّ اجْعَلْ خَيْرَ عُمْرِي آخِرَهُ وَخَيْرَ عَمَلِي خَوَاتِمَهُ وَخَيْرَ أَيَّامِي يَوْمَ أَلْقَاكَ فِيهِ *',

    // Page 3
    'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِيشَةً هَنِيَّةً وَمِيتَةً سَوِيَّةً وَمَرَدًّا غَيْرَ مُخْزٍ وَلاَ فَاضِحٍ *\n\nاللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ المَسْأَلَةِ وَخَيْرَ الدُّعَاءِ وَخَيْرَ النَّجَاحِ وَخَيْرَ العِلْمِ وَخَيْرَ العَمَلِ وَخَيْرَ الثَّوَابِ وَخَيْرَ الحَيَاةِ وَخَيْرَ المَمَاتِ *',

    // Page 4
    'وَثَبِّتْنِي وَثَقِّلْ مَوَازِينِي وَحَقِّقْ إِيمَانِي وَارْفَعْ دَرَجَتِي وَتَقَبَّلْ صَلَاتِي وَصِيَامِي وَصَدَقَتِي وَاغْفِرْ ذَنْبِي وَاسْتُرْ عَوْرَتِي *\n\nاللَّهُمَّ اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ وَالمُؤْمِنَاتِ الأَحْيَاءِ مِنْهُمْ وَالأَمْوَاتِ *',

    // Page 5
    'اللَّهُمَّ إِنِّي أَسْأَلُكَ الفَوْزَ يَوْمَ القَضَاءِ وَالنَّجَاةَ يَوْمَ التَّلَاقِي وَالرِّضْوَانَ يَوْمَ العَرْضِ عَلَيْكَ وَالفَوْزَ بِالجَنَّةِ وَالنَّجَاةَ مِنَ النَّارِ *\n\nاللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ مَا فِي الدُّنْيَا وَالآخِرَةِ وَخَيْرَ عَاقِبَةِ الأَمْرِ كُلِّهِ *',

    // Page 6
    'اللَّهُمَّ إِنِّي أَسْأَلُكَ العَفْوَ وَالعَافِيَةَ فِي الدُّنْيَا وَالآخِرَةِ *\n\nاللَّهُمَّ عَافِنِي فِي بَدَنِي وَبَصِّرْنِي فِي دِينِي وَبَارِكْ لِي فِي رِزْقِي وَاغْفِرْ لِي ذَنْبِي *',

    // Page 7
    'اللَّهُمَّ اجْعَلِ القُرْآنَ لَنَا فِي الدُّنْيَا قَرِينًا، وَفِي القَبْرِ مُؤْنِسًا، وَفِي القِيَامَةِ شَفِيعًا، وَعَلَى الصِّرَاطِ نُورًا، وَإِلَى الجَنَّةِ رَفِيقًا، وَمِنَ النَّارِ سِتْرًا وَحِجَابًا *',

    // Page 8
    'اللَّهُمَّ اجْعَلْنَا مِنْ أَهْلِ القُرْآنِ الَّذِينَ هُمْ أَهْلُكَ وَخَاصَّتُكَ *\n\nاللَّهُمَّ ارْزُقْنَا حُسْنَ تِلَاوَتِهِ وَالعَمَلَ بِهِ آنَاءَ اللَّيْلِ وَأَطْرَافَ النَّهَارِ *',

    // Page 9
    'اللَّهُمَّ اغْفِرْ لَنَا ذُنُوبَنَا كُلَّهَا دِقَّهَا وَجِلَّهَا، أَوَّلَهَا وَآخِرَهَا، عَلَانِيَتَهَا وَسِرَّهَا *\n\nاللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ العَفْوَ فَاعْفُ عَنَّا *',

    // Page 10 (Final)
    'اللَّهُمَّ لاَ تَجْعَلِ القُرْآنَ حُجَّةً عَلَيْنَا وَاجْعَلْهُ حُجَّةً لَنَا *\n\nرَبَّنَا تَقَبَّلْ مِنَّا إِنَّكَ أَنْتَ السَّمِيعُ العَلِيمُ وَتُبْ عَلَيْنَا إِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ *\n\nسُبْحَانَ رَبِّكَ رَبِّ العِزَّةِ عَمَّا يَصِفُونَ وَسَلَامٌ عَلَى المُرْسَلِينَ وَالحَمْدُ لِلَّهِ رَبِّ العَالَمِينَ *'
  ];

  List<Verse>? verses;
  List<Verse>? filteredVerses;
  String? _allVersesText;
  int? _lastClickedVerse;
  bool isLoading = true;
  String errorMessage = '';
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _showAudioControls = false;
  bool _isDownloaded = false;
  bool _isDownloading = false;
  bool _isPlayButtonLoading = false;
  double _downloadProgress = 0.0;
  String? _localAudioPath;
  double _fontSize = 24.0;
  int? _selectedVerse;
  bool _isSearching = false;
  String _searchQuery = '';

  bool _isFabMenuOpen = false;
  bool _isJuzDialogVisible = false;
  String? _currentJuzNumber;
  bool _showScrollInstruction = false;
  CancelToken? _downloadCancelToken;

  // Auto-scroll state
  bool _isAutoScrolling = false;
  bool _wasAutoScrollingBeforeTouch = false;
  Timer? _autoScrollTimer;
  double _autoScrollSpeed = 0.7;
  bool _isWaitingAtStart = false;
  bool _isWaitingAtEnd = false;
  DateTime? _waitStartTime;
  int _waitAtStartMs = 1000;
  int _waitAtEndMs = 1000;

  static const String _autoScrollSpeedKey = 'auto_scroll_speed';
  static const String _autoScrollWaitStartMsKey = 'auto_scroll_wait_start_ms';
  static const String _autoScrollWaitEndMsKey = 'auto_scroll_wait_end_ms';
  static const String _autoScrollFirstTimeKey = 'auto_scroll_first_time';

  final int _pageSize = 10;
  int _currentPage = 0;
  int _savedLastPage = 0;
  double _pendingRestoreOffset = 0.0;

  List<List<Verse>> _mushafPages = const [];
  List<int> _mushafPageNumbers = const [];

  // Flag to determine if we should save position
  bool _shouldSavePosition = false;

  // Flag to track if current session should allow saving (prevents daily ayah from affecting saved positions)
  bool _allowPositionSaving = false;

  bool _isKhatmaSession = false;

  ScrollController _scrollControllerForPage(int page) {
    return _pageScrollControllers.putIfAbsent(page, () => ScrollController());
  }

  Future<void> _buildMushafPages() async {
    final localVerses = verses;
    if (localVerses == null || localVerses.isEmpty) return;

    final chapters = await SurahsListServices.loadLocalChapters();
    final chapter = chapters.chapters.firstWhere(
      (c) => c.id == widget.surahId,
    );

    if (chapter.pages.length < 2) return;

    final startPage = chapter.pages[0];
    final endPage = chapter.pages[1];

    final mushafPages = <List<Verse>>[];
    final mushafPageNumbers = <int>[];

    for (int page = startPage; page <= endPage; page++) {
      if (page <= 0 || page >= mushafPageStarts.length) continue;

      final start = mushafPageStarts[page];
      final next = (page + 1 < mushafPageStarts.length)
          ? mushafPageStarts[page + 1]
          : const <int>[];

      if (start.length < 2) continue;

      int startAyah;
      if (start[0] == widget.surahId) {
        startAyah = start[1];
      } else {
        startAyah = 1;
      }

      int endAyah;
      if (next.length >= 2 && next[0] == widget.surahId) {
        endAyah = next[1] - 1;
      } else {
        endAyah = localVerses.length;
      }

      if (startAyah < 1) startAyah = 1;
      if (endAyah > localVerses.length) endAyah = localVerses.length;
      if (startAyah > endAyah) continue;

      final pageVerses =
          localVerses.sublist(startAyah - 1, endAyah); // end is exclusive
      mushafPages.add(pageVerses);
      mushafPageNumbers.add(page);
    }

    if (!mounted) return;
    setState(() {
      _mushafPages = mushafPages;
      _mushafPageNumbers = mushafPageNumbers;
      _currentPage = _currentPage.clamp(0, _maxPageIndexForCurrentList());
    });
  }

  void _goToFirstPage() {
    setState(() {
      _currentPage = 0;
      _pendingRestoreOffset = 0.0;
      _isFabMenuOpen = false;
      _isSearching = false;
    });

    _searchController.clear();
    _searchQuery = '';
    _filterVerses();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      final controller = _scrollControllerForPage(0);
      if (controller.hasClients) {
        controller.jumpTo(0.0);
      }
    });
  }

  // Auto-scroll methods
  void _startAutoScroll() {
    if (_isAutoScrolling) return;

    setState(() {
      _isAutoScrolling = true;
      _isWaitingAtStart = true;
      _waitStartTime = DateTime.now();
    });

    // Keep screen on during auto-scroll
    WakelockPlus.enable();

    _autoScrollTimer =
        Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel(); 
        return;
      }

      final controller = _pageScrollControllers[_currentPage];
      if (controller == null || !controller.hasClients) return;

      final maxScroll = controller.position.maxScrollExtent;
      final currentOffset = controller.offset; 

      // Check if we're at the start and need to wait
      if (_isWaitingAtStart) {
        final elapsed =
            DateTime.now().difference(_waitStartTime!).inMilliseconds;
        if (elapsed >= _waitAtStartMs) {
          setState(() {
            _isWaitingAtStart = false;
          });
        }
        return;
      }

      // Check if we're at the end and need to wait
      if (_isWaitingAtEnd) {
        final elapsed =
            DateTime.now().difference(_waitStartTime!).inMilliseconds;
        if (elapsed >= _waitAtEndMs) {
          setState(() {
            _isWaitingAtEnd = false;
          });
          // Navigate to next page with animation
          if (_currentPage < _maxPageIndexForCurrentList()) {
            _goToNextPageWithAnimation();
          } else {
            _stopAutoScroll();
          }
        }
        return;
      }

      final newOffset = currentOffset + _autoScrollSpeed;

      if (newOffset >= maxScroll) {
        // Reached bottom of current page, start waiting
        setState(() {
          _isWaitingAtEnd = true;
          _waitStartTime = DateTime.now();
        });
      } else {
        controller.jumpTo(newOffset);
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;

    // Allow screen to lock again when auto-scroll stops
    WakelockPlus.disable();

    if (mounted) {
      setState(() {
        _isAutoScrolling = false;
        _isWaitingAtStart = false;
        _isWaitingAtEnd = false;
        _waitStartTime = null;
      });
    }
  }

  Future<void> _checkFirstTimeAutoScroll() async {
    final prefs = await SharedPreferences.getInstance();
    final hasUsedAutoScroll = prefs.getBool(_autoScrollFirstTimeKey) ?? false;

    if (!hasUsedAutoScroll) {
      await _showAutoScrollInfoDialog();
      await prefs.setBool(_autoScrollFirstTimeKey, true);
    }
  }

  Future<void> _showAutoScrollInfoDialog() {
    return showDialog<void>(
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
                  _primaryColor,
                  _primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
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
                          Icons.swipe_down,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isEnglish
                            ? 'Auto-Scroll Started!'
                            : 'بدأ التمرير التلقائي!',
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
                      const SizedBox(height: 16),
                      Text(
                        isEnglish
                            ? 'Long press the auto-scroll button to customize speed and start/end waiting time'
                            : 'اضغط مطولاً على زر التمرير التلقائي لتخصيص السرعة ووقت الانتظار في البداية والنهاية',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.getFont(
                          fontFamily,
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                        ),
                        child: Text(
                          isEnglish ? 'Got it' : 'فهمت',
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

  void _toggleAutoScroll() async {
    if (_isAutoScrolling) {
      _stopAutoScroll();
    } else {
      await _checkFirstTimeAutoScroll();
      _startAutoScroll();
    }
  }

  void _pauseAutoScroll() {
    if (_isAutoScrolling) {
      _wasAutoScrollingBeforeTouch = true;
      _autoScrollTimer?.cancel();
      _autoScrollTimer = null;
    }
  }

  void _resumeAutoScroll() {
    if (_wasAutoScrollingBeforeTouch) {
      _wasAutoScrollingBeforeTouch = false;
      _isAutoScrolling =
          false; // Reset so _startAutoScroll doesn't return early
      _startAutoScroll();
    }
  }

  Future<void> _loadAutoScrollSpeed() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoScrollSpeed = prefs.getDouble(_autoScrollSpeedKey) ?? 0.7;
      _waitAtStartMs = prefs.getInt(_autoScrollWaitStartMsKey) ?? 1000;
      _waitAtEndMs = prefs.getInt(_autoScrollWaitEndMsKey) ?? 1000;
    });
  }

  Future<void> _saveAutoScrollSettings({
    required double speed,
    required int waitAtStartMs,
    required int waitAtEndMs,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_autoScrollSpeedKey, speed);
    await prefs.setInt(_autoScrollWaitStartMsKey, waitAtStartMs);
    await prefs.setInt(_autoScrollWaitEndMsKey, waitAtEndMs);
    setState(() {
      _autoScrollSpeed = speed;
      _waitAtStartMs = waitAtStartMs;
      _waitAtEndMs = waitAtEndMs;
    });
  }

  void _showSpeedControlDialog() {
    double tempSpeed = _autoScrollSpeed;
    double tempWaitStartSeconds = (_waitAtStartMs / 1000.0).clamp(0.0, 10.0);
    double tempWaitEndSeconds = (_waitAtEndMs / 1000.0).clamp(0.0, 10.0);
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.only(top: 30),
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _primaryColor,
                      _primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.3),
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
                              Icons.speed,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            isEnglish
                                ? 'Auto-Scroll Settings'
                                : 'إعدادات التمرير التلقائي',
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
                          const SizedBox(height: 24),
                          Text(
                            isEnglish
                                ? 'Adjust speed and waiting time'
                                : 'ضبط السرعة ووقت الانتظار',
                            style: GoogleFonts.getFont(
                              fontFamily,
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isEnglish ? 'Slow' : 'بطيء',
                                style: GoogleFonts.getFont(
                                  fontFamily,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tempSpeed.toStringAsFixed(1),
                                  style: GoogleFonts.getFont(
                                    fontFamily,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Text(
                                isEnglish ? 'Fast' : 'سريع',
                                style: GoogleFonts.getFont(
                                  fontFamily,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Slider(
                            value: tempSpeed,
                            min: 0.3,
                            max: 3.0,
                            divisions: 27,
                            activeColor: Colors.white,
                            inactiveColor: Colors.white.withOpacity(0.3),
                            onChanged: (value) {
                              setDialogState(() {
                                tempSpeed = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isEnglish ? 'Start wait' : 'انتظار البداية',
                                style: GoogleFonts.getFont(
                                  fontFamily,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${tempWaitStartSeconds.toStringAsFixed(1)}s',
                                  style: GoogleFonts.getFont(
                                    fontFamily,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: tempWaitStartSeconds,
                            min: 0.0,
                            max: 5.0,
                            divisions: 50,
                            activeColor: Colors.white,
                            inactiveColor: Colors.white.withOpacity(0.3),
                            onChanged: (value) {
                              setDialogState(() {
                                tempWaitStartSeconds = value;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isEnglish ? 'End wait' : 'انتظار النهاية',
                                style: GoogleFonts.getFont(
                                  fontFamily,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${tempWaitEndSeconds.toStringAsFixed(1)}s',
                                  style: GoogleFonts.getFont(
                                    fontFamily,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: tempWaitEndSeconds,
                            min: 0.0,
                            max: 5.0,
                            divisions: 50,
                            activeColor: Colors.white,
                            inactiveColor: Colors.white.withOpacity(0.3),
                            onChanged: (value) {
                              setDialogState(() {
                                tempWaitEndSeconds = value;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.white.withOpacity(0.2),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: Text(
                                    isEnglish ? 'Cancel' : 'إلغاء',
                                    style: GoogleFonts.getFont(
                                      fontFamily,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final waitStartMs =
                                        (tempWaitStartSeconds * 1000).round();
                                    final waitEndMs =
                                        (tempWaitEndSeconds * 1000).round();
                                    await _saveAutoScrollSettings(
                                      speed: tempSpeed,
                                      waitAtStartMs: waitStartMs,
                                      waitAtEndMs: waitEndMs,
                                    );
                                    Navigator.pop(context);
                                    _showPrimarySnackBar(
                                      isEnglish ? 'Saved' : 'تم الحفظ',
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: _primaryColor,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: Text(
                                    isEnglish ? 'Save' : 'حفظ',
                                    style: GoogleFonts.getFont(
                                      fontFamily,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              setDialogState(() {
                                tempSpeed = 0.7;
                                tempWaitStartSeconds = 1.0;
                                tempWaitEndSeconds = 1.0;
                              });
                            },
                            child: Text(
                              isEnglish
                                  ? 'Restore Default'
                                  : 'استعادة الافتراضي',
                              style: GoogleFonts.getFont(
                                fontFamily,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
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
      },
    );
  }

  void _goToNextPageWithAnimation() {
    if (_currentPage < _maxPageIndexForCurrentList()) {
      setState(() {
        _currentPage++;
        _isWaitingAtStart = true;
        _waitStartTime = DateTime.now();
      });
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
      final controller = _scrollControllerForPage(_currentPage);
      if (controller.hasClients) {
        controller.jumpTo(0.0);
      }
    }
  }

  bool get isEnglish => Globals.languageState ?? true;
  String get fontFamily => isEnglish ? 'Roboto' : 'Tajawal';
  String get arabicFontFamily => 'Scheherazade New';

  static const List<Map<String, String>> _audioReaders = [
    {
      'key': 'minsh',
      'ar': 'محمد صديق المنشاوي',
      'en': 'Muhammad Siddiq Al-Minshawi',
      'edition': 'ar.minshawi',
      'bitrate': '128'
    },
    {
      'key': 'afs',
      'ar': 'مشاري العفاسي',
      'en': 'Mishary Al-Afasy',
      'edition': 'ar.alafasy',
      'bitrate': '128'
    },
    {
      'key': 'sds',
      'ar': 'عبدالرحمن السديس',
      'en': 'Abdul Rahman Al-Sudais',
      'edition': 'ar.abdurrahmaansudais',
      'bitrate': '128'
    },
    {
      'key': 'yasser',
      'ar': 'ياسر الدوسري',
      'en': 'Yasser Al-Dosari',
      'edition': 'ar.yasserdosari',
      'bitrate': '128'
    },
    {
      'key': 'basit',
      'ar': 'عبدالباسط عبدالصمد',
      'en': 'Abdul Basit Abdul Samad',
      'edition': 'ar.abdulbasitmurattal',
      'bitrate': '192'
    },
    {
      'key': 'husr',
      'ar': 'محمود خليل الحصري',
      'en': 'Mahmoud Khalil Al-Hosari',
      'edition': 'ar.husary',
      'bitrate': '128'
    },
    {
      'key': 'maher',
      'ar': 'ماهر المعيقلي',
      'en': 'Maher Al Muaiqly',
      'edition': 'ar.maheralmuaiqly',
      'bitrate': '128'
    }
  ];

  String _editionForReader(String readerKey) {
    final reader = _audioReaders.firstWhere(
      (r) => r['key'] == readerKey,
      orElse: () => _audioReaders[1], // Default to Afasy
    );
    return reader['edition'] ?? 'ar.alafasy';
  }

  String _bitrateForReader(String readerKey) {
    final reader = _audioReaders.firstWhere(
      (r) => r['key'] == readerKey,
      orElse: () => _audioReaders[1], // Default to Afasy
    );
    return reader['bitrate'] ?? '128';
  }

  String _serverForReader(String readerKey) {
    switch (readerKey) {
      case 'minsh':
        return 'server10';
      case 'afs':
        return 'server8';
      case 'sds':
      case 'yasser':
        return 'server11';
      case 'basit':
        return 'server7';
      case 'husr':
        return 'server13';
      case 'maher':
        return 'server12';
      default:
        return 'server8';
    }
  }

  String _buildSurahAudioUrl(String readerKey) {
    final server = _serverForReader(readerKey);
    return 'https://$server.mp3quran.net/$readerKey/${widget.surahId.toString().padLeft(3, '0')}.mp3';
  }

  String _audioPrefsKey(String readerKey) =>
      'audio_${widget.surahId}_$readerKey';
  String _readerPrefsKey() => 'audio_reader_${widget.surahId}';

  void _showPrimarySnackBar(String message, {Duration? duration}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _primaryColor,
        content: Directionality(
          textDirection:
              Globals.languageState! ? TextDirection.ltr : TextDirection.rtl,
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        duration: duration ?? const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _initializeMediaNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'media_controls',
      'Media Controls',
      description: 'Media playback controls',
      importance: Importance.low,
      showBadge: false,
      playSound: false,
      enableVibration: false,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _showMediaNotification() async {
    final readerName = _selectedReaderKey != null
        ? _audioReaders.firstWhere((r) => r['key'] == _selectedReaderKey,
            orElse: () => {'ar': '', 'en': ''})[isEnglish ? 'en' : 'ar']
        : '';

    final androidDetails = AndroidNotificationDetails(
      'media_controls',
      'Media Controls',
      channelDescription: 'Media playback controls',
      icon: '@mipmap/ic_launcher',
      color: _primaryColor,
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: _duration.inSeconds,
      progress: _position.inSeconds,
      ongoing: true,
      autoCancel: false,
      actions: [
        const AndroidNotificationAction('pause_action', 'Pause'),
        const AndroidNotificationAction('stop_action', 'Stop'),
      ],
      styleInformation: const MediaStyleInformation(),
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      category: AndroidNotificationCategory.transport,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: _mediaNotificationId,
      title: isEnglish ? 'Holy Quran' : 'القرآن الكريم',
      body:
          '${isEnglish ? widget.surahName : widget.arabicName}\n${isEnglish ? 'Reciter' : 'القارئ'}: $readerName',
      notificationDetails: details,
    );
  }

  Future<void> _updateMediaNotification() async {
    final readerName = _selectedReaderKey != null
        ? _audioReaders.firstWhere((r) => r['key'] == _selectedReaderKey,
            orElse: () => {'ar': '', 'en': ''})[isEnglish ? 'en' : 'ar']
        : '';

    final currentPosition = _formatDuration(_position);
    final totalDuration = _formatDuration(_duration);

    final androidDetails = AndroidNotificationDetails(
      'media_controls',
      'Media Controls',
      channelDescription: 'Media playback controls',
      icon: '@mipmap/ic_launcher',
      color: _primaryColor,
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: _duration.inSeconds,
      progress: _position.inSeconds,
      ongoing: true,
      autoCancel: false,
      actions: [
        const AndroidNotificationAction('pause_action', 'Pause'),
        const AndroidNotificationAction('stop_action', 'Stop'),
      ],
      styleInformation: const MediaStyleInformation(),
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      category: AndroidNotificationCategory.transport,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: _mediaNotificationId,
      title: isEnglish ? 'Holy Quran' : 'القرآن الكريم',
      body:
          '${isEnglish ? widget.surahName : widget.arabicName}\n${isEnglish ? 'Reciter' : 'القارئ'}: $readerName\n$currentPosition / $totalDuration',
      notificationDetails: details,
    );
  }

  Future<void> _hideMediaNotification() async {
    await _notificationsPlugin.cancel(id: _mediaNotificationId);
  }

  Future<void> _initializeNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initSettings = InitializationSettings(android: androidInit);

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.actionId != null) {
          _handleNotificationAction(response.actionId!);
        }
      },
    );
  }

  Future<void> _handleNotificationAction(String action) async {
    switch (action) {
      case 'pause_action':
        await _pauseSurah();
        break;
      case 'stop_action':
        await _stopSurah();
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _isKhatmaSession = widget.openSource == 'khatma';

    // Initialize position saving flags based on open source
    _shouldSavePosition = _isKhatmaSession;
    _allowPositionSaving = _isKhatmaSession;

    // DEBUG: Log initialization
    print('🚀 DEBUG: initState - openSource: ${widget.openSource}');
    print('🚀 DEBUG: initState - _shouldSavePosition: $_shouldSavePosition');
    print('🚀 DEBUG: initState - _allowPositionSaving: $_allowPositionSaving');
    print(
        '🚀 DEBUG: initState - targetVerseNumber: ${widget.targetVerseNumber}');

    _initializeWithKhatmaGate();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: _primaryColor,
      systemNavigationBarColor: _cardColor,
    ));
    _setupAudioListeners();
    _initializeNotifications();
    _initializeMediaNotificationChannel();
    _checkIfDownloaded();
    _loadAutoScrollSpeed();
    _searchController.addListener(() => _onSearchChanged());
  }

  Future<String?> _pickReaderKey() async {
    final selectedKey = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Directionality(
          textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 520),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _primaryColor,
                    _primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.record_voice_over,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isEnglish ? 'Choose reciter' : 'اختر القارئ',
                                style: GoogleFonts.getFont(
                                  fontFamily,
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _audioReaders.length,
                            itemBuilder: (context, index) {
                              final reader = _audioReaders[index];
                              final key = reader['key']!;
                              final label =
                                  isEnglish ? reader['en']! : reader['ar']!;
                              final isSelected = _selectedReaderKey == key;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Material(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                  child: FutureBuilder<String?>(
                                    future: _getLocalPathForReader(key),
                                    builder: (context, snapshot) {
                                      final isDownloadedForReader =
                                          snapshot.connectionState ==
                                                  ConnectionState.done &&
                                              snapshot.data != null;

                                      return InkWell(
                                        borderRadius: BorderRadius.circular(14),
                                        onTap: () =>
                                            Navigator.of(context).pop(key),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 12),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  label,
                                                  style: GoogleFonts.getFont(
                                                    fontFamily,
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              if (isDownloadedForReader)
                                                IconButton(
                                                  tooltip: isEnglish
                                                      ? 'Delete download'
                                                      : 'حذف التحميل',
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                    await _deleteDownloadedAudioForReader(
                                                        key);
                                                  },
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selectedKey == null) return null;
    _selectedReaderKey = selectedKey;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_readerPrefsKey(), selectedKey);

    return selectedKey;
  }

  Future<String?> _getLocalPathForReader(String readerKey) async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_audioPrefsKey(readerKey));
    if (path == null) return null;
    final file = File(path);
    if (await file.exists()) return path;
    await prefs.remove(_audioPrefsKey(readerKey));
    return null;
  }

  Future<void> _deleteDownloadedAudioForReader(String readerKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString(_audioPrefsKey(readerKey));
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
        await prefs.remove(_audioPrefsKey(readerKey));
      }

      if (!mounted) return;
      if (_selectedReaderKey == readerKey) {
        setState(() {
          _isDownloaded = false;
          _localAudioPath = null;
        });
      }

      _showPrimarySnackBar(isEnglish ? 'Audio deleted' : 'تم حذف الصوت');
    } catch (e) {
      _showPrimarySnackBar(
          isEnglish ? 'Error deleting audio' : 'حدث خطأ أثناء حذف الصوت');
    }
  }

  Future<void> _initializeWithKhatmaGate() async {
    if (_isKhatmaSession) {
      final prefs = await SharedPreferences.getInstance();
      final state = prefs.getString('khatma_state') ??
          ((prefs.getBool('khatma_enabled') ?? false) ? 'active' : 'inactive');
      if (state != 'active') {
        _shouldSavePosition = false;
        _allowPositionSaving = false;
      } else {
        _shouldSavePosition = true;
        _allowPositionSaving = true;
      }
    } else {
      // For non-khatma sessions, allow position saving for manual bookmarks
      _shouldSavePosition = true;
      _allowPositionSaving =
          false; // Don't auto-save, only manual bookmark saves
    }

    await _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveReadingPosition();
    _audioPlayer.dispose();
    _hideMediaNotification();
    _pageController.dispose();
    for (final controller in _pageScrollControllers.values) {
      controller.dispose();
    }
    _searchController.dispose();
    _stopAutoScroll(); // Stop auto-scroll timer
    Globals.isSearching = false;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _saveReadingPosition();
      Globals.isSearching = false;
    } else if (state == AppLifecycleState.resumed) {
      _loadReadingPosition();
      Globals.isSearching = false;
    }
  }

  // Add WillPopCallback to handle device back button
  Future<bool> _onWillPop() async {
    await _saveReadingPosition();
    return true; // Allow the back navigation
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterVerses();
      if (_searchQuery.isEmpty) {
        print('🔍 DEBUG: Search cancelled - restoring to page $_savedLastPage');
        _currentPage = _savedLastPage;
      } else {
        _currentPage = 0;
      }
    });

    if (_searchQuery.isEmpty) {
      _loadScrollOffsetForPage(_currentPage).then((value) {
        _pendingRestoreOffset = value;
        _restoreScrollForCurrentPage();
      });
    } else {
      _pendingRestoreOffset = 0.0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_currentPage);
        }
      });
    }

    // Check for juz verses after search/filter
    _checkAndShowJuzDialog();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentPage);
      }
    });
  }

  String _normalizeArabic(String input) {
    final diacritics = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');
    String normalized = input.replaceAll(diacritics, '');

    // Unify letter variations
    normalized = normalized.replaceAll(RegExp(r'[إأٱآ]'), 'ا');
    normalized = normalized.replaceAll('ى', 'ي');
    normalized = normalized.replaceAll('ؤ', 'و');
    normalized = normalized.replaceAll('ئ', 'ي');
    normalized = normalized.replaceAll('ـ', ''); // Tatweel

    return normalized;
  }

  void _filterVerses() {
    final query = _normalizeArabic(_searchQuery);

    if (query.isEmpty) {
      filteredVerses = verses;
    } else {
      filteredVerses = verses?.where((verse) {
        final verseText = _normalizeArabic(verse.textUthmani);
        return verseText.contains(query);
      }).toList();
    }
  }

  Future<void> _loadLastPage() async {
    // DEBUG: Log load attempt
    print(
        '📄 DEBUG: _loadLastPage called - _shouldSavePosition: $_shouldSavePosition');
    print('📄 DEBUG: _isKhatmaSession: $_isKhatmaSession');

    // Only load saved page if we should save position (not from daily ayah)
    if (!_shouldSavePosition) {
      print(
          '📄 DEBUG: Skipping saved page load - _shouldSavePosition is false');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    int savedPage;

    if (_isKhatmaSession) {
      // Load khatma-specific page
      final gen = prefs.getInt('khatma_gen') ?? 0;
      savedPage =
          prefs.getInt('khatma_${gen}_surah_${widget.surahId}_page') ?? 0;
      print('📄 DEBUG: Loaded khatma page: $savedPage (gen: $gen)');
    } else {
      // Load manual bookmark page
      savedPage = prefs.getInt('manual_last_page_${widget.surahId}') ?? 0;
      print('📄 DEBUG: Loaded manual page: $savedPage');
    }

    if (!mounted) return;
    setState(() {
      _savedLastPage = savedPage;
      if (_searchQuery.isEmpty) {
        _currentPage = savedPage;
      }
    });
    print(
        '📄 DEBUG: Final saved page: $savedPage, current page: $_currentPage');
  }

  Future<void> _saveLastPage() async {
    // Only save if this session allows it AND we're not searching
    if (!_allowPositionSaving || _searchQuery.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    if (_isKhatmaSession) {
      final gen = prefs.getInt('khatma_gen') ?? 0;
      await prefs.setInt(
          'khatma_${gen}_surah_${widget.surahId}_page', _currentPage);
      await prefs.setInt('khatma_${gen}_last_surah', widget.surahId);
      await prefs.setInt('khatma_${gen}_last_page', _currentPage);
    } else {
      await prefs.setInt('last_page_${widget.surahId}', _currentPage);
    }
    _savedLastPage = _currentPage;
  }

  String _scrollOffsetKeyForPage(int page) {
    return 'scroll_offset_${widget.surahId}_$page';
  }

  Future<double> _loadScrollOffsetForPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    if (_isKhatmaSession) {
      final gen = prefs.getInt('khatma_gen') ?? 0;
      return prefs.getDouble('khatma_${gen}_surah_${widget.surahId}_offset') ??
          0.0;
    } else {
      // Load manual bookmark offset
      return prefs.getDouble('manual_last_offset_${widget.surahId}') ??
          prefs.getDouble(_scrollOffsetKeyForPage(page)) ??
          0.0;
    }
  }

  Future<void> _saveScrollOffsetForPage(int page) async {
    // Only save if this session allows it AND we're not searching
    if (!_allowPositionSaving || _searchQuery.isNotEmpty) return;
    final controller = _pageScrollControllers[page];
    if (controller == null || !controller.hasClients) return;

    final prefs = await SharedPreferences.getInstance();
    if (_isKhatmaSession) {
      final gen = prefs.getInt('khatma_gen') ?? 0;
      await prefs.setDouble(
          'khatma_${gen}_surah_${widget.surahId}_offset', controller.offset);
      await prefs.setInt('khatma_${gen}_last_surah', widget.surahId);
      await prefs.setInt('khatma_${gen}_last_page', _currentPage);
      await prefs.setDouble('khatma_${gen}_last_offset', controller.offset);
    } else {
      await prefs.setDouble(_scrollOffsetKeyForPage(page), controller.offset);
    }
  }

  Future<void> _saveManualBookmark() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save manual bookmark position (separate from khatma)
      await prefs.setInt('manual_last_page_${widget.surahId}', _currentPage);
      await prefs.setInt('manual_last_surah', widget.surahId);

      // Save scroll offset for the current page
      final controller = _pageScrollControllers[_currentPage];
      if (controller != null && controller.hasClients) {
        await prefs.setDouble(
            'manual_last_offset_${widget.surahId}', controller.offset);
      }

      // Update UI to show bookmark as filled
      if (mounted) {
        setState(() {});
      }

      // Show success message
      _showPrimarySnackBar(isEnglish ? 'Bookmark saved' : 'تم حفظ الصفحة');
    } catch (e) {
      print('Error saving manual bookmark: $e');
      if (mounted) {
        _showPrimarySnackBar(
            isEnglish ? 'Failed to save bookmark' : 'فشل حفظ الصفحة');
      }
    }
  }

  // Check if current page is bookmarked
  Future<bool> _isCurrentPageBookmarked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPage =
          prefs.getInt('manual_last_page_${widget.surahId}') ?? -1;
      return savedPage == _currentPage;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveReadingPosition() async {
    print('💾 DEBUG: _saveReadingPosition called');
    print('💾 DEBUG: _allowPositionSaving: $_allowPositionSaving');

    // Only save position if this session allows saving
    if (!_allowPositionSaving) {
      print(
          '💾 DEBUG: Position saving blocked - _allowPositionSaving is false');
      return;
    }

    if (_searchQuery.isNotEmpty) {
      print('💾 DEBUG: Position saving blocked - search is active');
      return;
    }

    print('💾 DEBUG: Saving position - page $_currentPage');
    await _saveLastPage();
    await _saveScrollOffsetForPage(_currentPage);
    print('💾 DEBUG: Position saved successfully');
  }

  Future<void> _loadReadingPosition() async {
    // DEBUG: Log load attempt
    print('📂 DEBUG: _loadReadingPosition called');
    print('📂 DEBUG: _shouldSavePosition: $_shouldSavePosition');

    // Only load if we are supposed to save position (i.e., from surah_list)
    if (!_shouldSavePosition) {
      print('📂 DEBUG: Skipping saved position load');
      return;
    }

    await _loadLastPage();
    if (_isKhatmaSession) {
      _pendingRestoreOffset = await _loadScrollOffsetForPage(_currentPage);
    } else {
      _pendingRestoreOffset = await _loadScrollOffsetForPage(_currentPage);
    }
    print(
        '📂 DEBUG: Loaded last page: $_currentPage, offset: $_pendingRestoreOffset');
    _restoreScrollForCurrentPage();
  }

  void _restoreScrollForCurrentPage() {
    // DEBUG: Log restoration attempt
    print('🔄 DEBUG: _restoreScrollForCurrentPage called');
    print('🔄 DEBUG: widget.targetVerseNumber: ${widget.targetVerseNumber}');
    print('🔄 DEBUG: _shouldSavePosition: $_shouldSavePosition');

    // Skip scroll restoration if we have a target verse to scroll to
    // OR if we shouldn't save/restore position (daily ayah case)
    if (widget.targetVerseNumber != null || !_shouldSavePosition) {
      print(
          '🔄 DEBUG: Restoration blocked - targetVerseNumber: ${widget.targetVerseNumber}, shouldSave: $_shouldSavePosition');
      return;
    }

    print('🔄 DEBUG: Restoring scroll position');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = _pageScrollControllers[_currentPage];
      if (controller == null || !controller.hasClients) return;

      final max = controller.position.maxScrollExtent;
      final target = _pendingRestoreOffset.clamp(0.0, max);
      print('🔄 DEBUG: Jumping to offset: $target (max: $max)');
      if (_isFirstTimeOpen) {
        _isFirstTimeOpen = false;
        controller.jumpTo(target);
      }
    });
  }

  void _setupAudioListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
          _isPlaying = state == PlayerState.playing;
          _showAudioControls = _isPlaying;
          _isPlayButtonLoading = false;
        });

        // Handle media notification based on player state
        if (state == PlayerState.playing) {
          _showMediaNotification();
        } else {
          _hideMediaNotification();
        }
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _duration = duration);
      // Update notification when duration is available
      if (_isPlaying && mounted) {
        _updateMediaNotification();
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) setState(() => _position = position);
      // Update notification progress during playback
      if (_isPlaying && mounted) {
        _updateMediaNotification();
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
          _showAudioControls = false;
          _isPlayButtonLoading = false;
          // Keep verse highlighted - don't clear _selectedVerse
        });
        _hideMediaNotification();
      }
    });
  }

  Future<void> _initialize() async {
    await _loadVerses();
    await _loadReadingPosition();
    await _checkScrollInstruction();
  }

  Future<void> _checkScrollInstruction() async {
    final prefs = await SharedPreferences.getInstance();
    final globalKey = 'scroll_instruction_shown_globally';
    final hasShown = prefs.getBool(globalKey) ?? false;

    final maxPage = _maxPageIndexForCurrentList();
    final hasPagination = maxPage > 0;

    if (hasPagination && !hasShown) {
      setState(() {
        _showScrollInstruction = true;
      });

      // Mark as shown globally for the entire app
      await prefs.setBool(globalKey, true);

      // Removed auto-hide - message now stays until user clicks a button
    }
  }

  Future<void> _loadVerses() async {
    try {
      final quranData = await QuranServices.loadLocalVerses(widget.surahId);
      setState(() {
        verses = quranData.verses;
        filteredVerses = verses;
        _allVersesText = _combineVersesWithIcons(verses!);
        isLoading = false;
        _currentPage = _currentPage.clamp(0, _maxPageIndexForCurrentList());
      });

      await _buildMushafPages();

      // Only restore scroll position if we don't have a target verse AND we should save position
      if (_searchQuery.isEmpty &&
          widget.targetVerseNumber == null &&
          _shouldSavePosition) {
        print(
            '📖 DEBUG: Restoring position on load - _shouldSavePosition: $_shouldSavePosition');
        _pendingRestoreOffset = await _loadScrollOffsetForPage(_currentPage);
        _restoreScrollForCurrentPage();
      } else {
        print(
            '📖 DEBUG: Skipping position restoration - searchQuery: "${_searchQuery}", targetVerse: ${widget.targetVerseNumber}, shouldSave: $_shouldSavePosition');
      }

      // Scroll to target verse if specified
      if (widget.targetVerseNumber != null && verses != null) {
        print(
            '📖 DEBUG: Scrolling to target verse: ${widget.targetVerseNumber}');
        _scrollToVerse(widget.targetVerseNumber!);
      }

      // Check for juz verses on initial load
      _checkAndShowJuzDialog();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_currentPage);
        }
      });
    } catch (e) {
      setState(() {
        errorMessage =
            isEnglish ? 'Error loading verses' : 'حدث خطأ في تحميل الآيات';
        isLoading = false;
      });
    }
  }

  // Scroll to specific verse
  void _scrollToVerse(int verseNumber) {
    // DEBUG: Log scroll attempt
    print('🎯 DEBUG: _scrollToVerse called with verseNumber: $verseNumber');
    print('🎯 DEBUG: Current _shouldSavePosition: $_shouldSavePosition');

    if (verses == null || verseNumber < 1 || verseNumber > verses!.length)
      return;

    int targetPage;
    if (_searchQuery.isNotEmpty) {
      // Search mode uses legacy fixed-size pagination
      targetPage = ((verseNumber - 1) ~/ _pageSize)
          .clamp(0, _maxPageIndexForCurrentList());
    } else {
      // Mushaf mode: find the mushaf page that contains this verse number
      int found = 0;
      for (int i = 0; i < _mushafPages.length; i++) {
        final pageVerses = _mushafPages[i];
        if (pageVerses.isEmpty) continue;

        final startAyah = verses!.indexOf(pageVerses.first) + 1;
        final endAyah = verses!.indexOf(pageVerses.last) + 1;
        if (verseNumber >= startAyah && verseNumber <= endAyah) {
          found = i;
          break;
        }
      }
      targetPage = found.clamp(0, _maxPageIndexForCurrentList());
    }

    print(
        '🎯 DEBUG: Calculated targetPage: $targetPage (from page $_currentPage)');

    // Set current page to target page
    setState(() {
      _currentPage = targetPage;
    });

    print('🎯 DEBUG: _currentPage changed to: $_currentPage');

    // Wait for page to be ready then scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Navigate to target page
      if (_pageController.hasClients) {
        _pageController.jumpToPage(targetPage);

        // After page change, scroll to verse within page
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final controller = _scrollControllerForPage(targetPage);
          if (controller.hasClients) {
            // Get actual verse items for this page to calculate precise position
            final pageVerses = _pageItemsForIndex(targetPage);
            final actualVerseIndexInPage = pageVerses.indexWhere(
                (verse) => verses!.indexOf(verse) + 1 == verseNumber);

            // Use more accurate height calculation based on actual verse content
            final estimatedVerseHeight =
                80.0; // More realistic height per verse with spacing
            final targetOffset =
                (actualVerseIndexInPage >= 0 ? actualVerseIndexInPage : 0) *
                    estimatedVerseHeight;

            // Small delay to ensure page is rendered
            Future.delayed(const Duration(milliseconds: 150), () {
              if (mounted && controller.hasClients) {
                // Check if we can scroll to the target position
                final maxScroll = controller.position.maxScrollExtent;
                final finalTargetOffset = targetOffset.clamp(0.0, maxScroll);

                controller.animateTo(
                  finalTargetOffset,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );

                // Highlight the target verse
                setState(() {
                  _selectedVerse = verseNumber;
                });

                print(
                    '🎯 DEBUG: Scrolled to verse $verseNumber on page $targetPage');
              }
            });
          }
        });
      }
    });
  }

  int _maxPageIndexForCurrentList() {
    if (_searchQuery.isNotEmpty) {
      final list = filteredVerses ?? verses ?? <Verse>[];
      if (list.isEmpty) return 0;
      return (list.length - 1) ~/ _pageSize;
    }

    if (_mushafPages.isEmpty) return 0;
    return _mushafPages.length - 1;
  }

  void _checkAndShowJuzDialog() {
    final currentPageVerses = _pageItemsForIndex(_currentPage);

    // Check if any verse on the current page has a juz field
    for (final verse in currentPageVerses) {
      if (verse.juz != null) {
        setState(() {
          _currentJuzNumber = verse.juz;
          _isJuzDialogVisible = true;
        });

        // Auto-hide the dialog after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isJuzDialogVisible = false;
            });
          }
        });

        break; // Only show once per page
      }
    }
  }

  List<Verse> _pageItemsForIndex(int pageIndex) {
    if (_searchQuery.isNotEmpty) {
      final list = filteredVerses ?? verses ?? <Verse>[];
      if (list.isEmpty) return <Verse>[];
      final start = (pageIndex * _pageSize).clamp(0, list.length);
      final end = (start + _pageSize).clamp(0, list.length);
      return list.sublist(start, end);
    }

    if (_mushafPages.isEmpty) return <Verse>[];
    if (pageIndex < 0 || pageIndex >= _mushafPages.length) return <Verse>[];
    return _mushafPages[pageIndex];
  }

  String _toArabicNumber(int number, bool withIcon) {
    final arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    final arabicNumber = number.toString().split('').map((d) {
      return arabicDigits[int.parse(d)];
    }).join();

    return withIcon ? '۝$arabicNumber' : arabicNumber;
  }

  String _combineVersesWithIcons(List<Verse> verses) {
    final buffer = StringBuffer();
    for (int i = 0; i < verses.length; i++) {
      final verse = verses[i];
      final verseNumber = i + 1;
      final verseIcon = _toArabicNumber(verseNumber, true);

      buffer.write(verse.textUthmani);
      buffer.write(' $verseIcon');

      if (i < verses.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  Future<void> _playSurah() async {
    try {
      setState(() => _isPlayButtonLoading = true);

      final readerKey = await _pickReaderKey();
      if (readerKey == null) {
        if (mounted) setState(() => _isPlayButtonLoading = false);
        return;
      }

      final localPathForReader = await _getLocalPathForReader(readerKey);
      final hasOffline = localPathForReader != null;

      if (hasOffline) {
        await _audioPlayer.play(DeviceFileSource(localPathForReader));
        if (mounted) {
          setState(() {
            _isDownloaded = true;
            _localAudioPath = localPathForReader;
          });
        }
      } else {
        await _audioPlayer.play(UrlSource(_buildSurahAudioUrl(readerKey)));
        if (mounted) {
          setState(() {
            _isDownloaded = false;
            _localAudioPath = null;
          });
        }
      }
      setState(() {
        _isPlaying = true;
        _showAudioControls = true;
        _isPlayButtonLoading = false;
      });
    } catch (e) {
      setState(() => _isPlayButtonLoading = false);

      String message = isEnglish
          ? 'No internet connection. Please download the verse to play offline.'
          : 'لا يوجد اتصال بالإنترنت. يرجى تنزيل السورة للتشغيل دون اتصال.';

      _showPrimarySnackBar(message);
    }
  }

  Future<void> _pauseSurah() async {
    await _audioPlayer.pause();
    setState(() => _isPlaying = false);
  }

  Future<void> _stopSurah() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _position = Duration.zero;
      _showAudioControls = false;
    });
  }

  Future<void> _cancelDownload() async {
    _downloadCancelToken
        ?.cancel(isEnglish ? 'Download cancelled' : 'تم إلغاء التنزيل');
    setState(() {
      _isDownloading = false;
      _downloadProgress = 0.0;
    });
    _showPrimarySnackBar(isEnglish ? 'Download cancelled' : 'تم إلغاء التنزيل');
  }

  Future<void> _downloadAudio() async {
    try {
      final readerKey = await _pickReaderKey();
      if (readerKey == null) return;

      // If this reader is already downloaded, don't re-download
      final existingPath = await _getLocalPathForReader(readerKey);
      if (existingPath != null) {
        _showPrimarySnackBar(
          isEnglish ? 'Already downloaded' : 'تم تنزيل الصوت بالفعل',
        );
        if (mounted) {
          setState(() {
            _isDownloaded = true;
            _localAudioPath = existingPath;
          });
        }
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/surah_${widget.surahId}_$readerKey.mp3';
      final file = File(filePath);

      if (mounted) {
        setState(() {
          _isDownloading = true;
          _downloadProgress = 0.0;
        });
      }

      _downloadCancelToken = CancelToken();

      final dio = Dio();
      await dio.download(
        _buildSurahAudioUrl(readerKey),
        filePath,
        cancelToken: _downloadCancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_audioPrefsKey(readerKey), filePath);
      await prefs.setString(_readerPrefsKey(), readerKey);

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isDownloaded = true;
          _localAudioPath = filePath;
        });

        _showPrimarySnackBar(isEnglish
            ? 'Audio downloaded successfully'
            : 'تم تنزيل الصوت بنجاح');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });

        _showPrimarySnackBar(isEnglish ? 'Download failed' : 'فشل التنزيل');
      }
    }
  }

  Future<void> _checkIfDownloaded() async {
    final prefs = await SharedPreferences.getInstance();

    _selectedReaderKey ??= prefs.getString(_readerPrefsKey());
    final readerKey = _selectedReaderKey;
    if (readerKey == null) return;

    final path = await _getLocalPathForReader(readerKey);
    if (!mounted) return;
    if (path != null) {
      setState(() {
        _isDownloaded = true;
        _localAudioPath = path;
      });
    } else {
      setState(() {
        _isDownloaded = false;
        _localAudioPath = null;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [minutes, seconds].join(':');
  }

  AppBar _buildAppBar() {
    final int maxPageIndex = _maxPageIndexForCurrentList();
    final int totalPages = (maxPageIndex + 1).clamp(1, 9999);
    final int currentPageOneBased = (_currentPage + 1).clamp(1, totalPages);

    final int? currentMushafPage = (_searchQuery.isEmpty &&
            _mushafPageNumbers.isNotEmpty &&
            _currentPage >= 0 &&
            _currentPage < _mushafPageNumbers.length)
        ? _mushafPageNumbers[_currentPage]
        : null;

    final int? totalMushafPage =
        (_searchQuery.isEmpty && _mushafPageNumbers.isNotEmpty)
            ? _mushafPageNumbers.last
            : null;

    final String totalPagesLabel = (totalMushafPage != null)
        ? (isEnglish
            ? '$totalMushafPage'
            : _toArabicNumber(totalMushafPage, false))
        : (isEnglish ? '$totalPages' : _toArabicNumber(totalPages, false));

    final String currentOverTotalLabel =
        (currentMushafPage != null && totalMushafPage != null)
            ? (isEnglish
                ? '$currentMushafPage'
                : '${_toArabicNumber(currentMushafPage, false)}')
            : (isEnglish
                ? '$currentPageOneBased'
                : '${_toArabicNumber(currentPageOneBased, false)}');

    return AppBar(
      toolbarHeight: 80,
      backgroundColor: _primaryColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leadingWidth: 120,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              _audioPlayer.stop();
              await _saveReadingPosition();
              if (mounted) Navigator.pop(context);
            },
          ),
          Text(
            totalPagesLabel,
            style: GoogleFonts.getFont(
              fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            tooltip: isEnglish ? 'Tajweed Marks' : 'علامات التجويد',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TajweedMarksPage()),
              );
            },
          ),
        ],
      ),
      centerTitle: true,
      title: _isSearching
          ? Directionality(
              textDirection: Globals.languageState!
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText:
                      isEnglish ? 'Search verses...' : 'ابحث في الآيات...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                cursorColor: Colors.white,
              ),
            )
          : Column(
              children: [
                Text(
                  isEnglish ? widget.surahName : widget.arabicName,
                  style: GoogleFonts.getFont(
                    fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${isEnglish ? 'Surah' : 'سورة'} ${isEnglish ? widget.surahId : _toArabicNumber(widget.surahId, false)}',
                  style: GoogleFonts.getFont(
                    fontFamily,
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
      actions: [
        if (!_isKhatmaSession)
          FutureBuilder<bool>(
            future: _isCurrentPageBookmarked(),
            builder: (context, snapshot) {
              final isBookmarked = snapshot.data ?? false;
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                ),
                onPressed: _saveManualBookmark,
                tooltip: isEnglish ? 'Save bookmark' : 'حفظ صفحة',
              );
            },
          ),
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Center(
            child: Text(
              currentOverTotalLabel,
              style: GoogleFonts.getFont(
                fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search,
              color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _searchQuery = '';
                _filterVerses();
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildBasmala() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Text(
        "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily:
              arabicFontFamily, // Changed to use the same font family as verses
          fontSize: _fontSize + 4, // Slightly larger than verse font size
          fontWeight: FontWeight.bold,
          color: _primaryColor,
          height: 1.8,
        ),
      ),
    );
  }

  Widget _buildVerseRichTextWithFontSize(
      List<InlineSpan> spans, double fontSize) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: RichText(
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        text: TextSpan(
          children: spans,
          style: TextStyle(
            fontSize: fontSize,
            height: 2.0,
            fontFamily: arabicFontFamily,
            color: _textColor,
          ),
        ),
      ),
    );
  }

  double _measureSpansHeight({
    required List<InlineSpan> spans,
    required double maxWidth,
    required double fontSize,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        children: spans,
        style: TextStyle(
          fontSize: fontSize,
          height: 2.0,
          fontFamily: arabicFontFamily,
          color: _textColor,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
    );

    painter.layout(maxWidth: maxWidth);
    return painter.height;
  }

  double _autoFitFontSizeForPage({
    required List<InlineSpan> spans,
    required double maxWidth,
    required double targetHeight,
    required double baseFontSize,
  }) {
    if (targetHeight <= 0) return baseFontSize;

    final double min = baseFontSize;
    final double max = (baseFontSize * 1.8).clamp(baseFontSize, 48.0);

    final baseHeight = _measureSpansHeight(
      spans: spans,
      maxWidth: maxWidth,
      fontSize: baseFontSize,
    );

    if (baseHeight >= targetHeight * 0.92) {
      return baseFontSize;
    }

    double lo = min;
    double hi = max;
    double best = baseFontSize;

    for (int i = 0; i < 10; i++) {
      final mid = (lo + hi) / 2;
      final h = _measureSpansHeight(
        spans: spans,
        maxWidth: maxWidth,
        fontSize: mid,
      );

      if (h <= targetHeight) {
        best = mid;
        lo = mid;
      } else {
        hi = mid;
      }
    }

    return best;
  }

  List<InlineSpan> _buildVerseSpans(List<Verse> versesToDisplay) {
    final spans = <InlineSpan>[];
    for (int i = 0; i < versesToDisplay.length; i++) {
      final verse = versesToDisplay[i];
      final verseNumber = verses!.indexOf(verse) + 1;
      final verseIcon = _toArabicNumber(verseNumber, true);

      final verseText = verse.textUthmani;

      final isSelected = _selectedVerse == verseNumber;
      final isHighlighted =
          _searchQuery.isNotEmpty && verse.textUthmani.contains(_searchQuery);

      // Add verse text
      spans.add(
        TextSpan(
          text: '$verseText ',
          style: TextStyle(
            fontFamily: arabicFontFamily,
            color: isSelected ? _primaryColor : _textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              setState(() {
                _selectedVerse = verseNumber;
              });
              _showVerseOptions('$verseText $verseIcon', verseNumber);
            },
        ),
      );

      // Add verse number with enhanced styling
      spans.add(
        TextSpan(
          text: '$verseIcon ',
          style: TextStyle(
            fontFamily: arabicFontFamily,
            color: _primaryColor, // Use primary color for verse numbers
            fontWeight: FontWeight.bold,
            fontSize: _fontSize + 2, // Slightly larger than verse text
            shadows: [
              Shadow(
                color: _primaryColor.withOpacity(0.2),
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              setState(() {
                _selectedVerse = verseNumber;
              });
              _showVerseOptions('$verseText $verseIcon', verseNumber);
            },
        ),
      );
    }
    return spans;
  }

  void _showVerseOptions(String verseText, int verseNumber) {
    final verse = verses![verseNumber - 1];

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _primaryColor,
                  _primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
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
                // Decorative pattern
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

                // Main content
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with icon and title
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.more_vert,
                              color: Colors.white,
                              size: 24,
                            ),
                          )
                              .animate()
                              .scale(delay: 200.ms, duration: 300.ms)
                              .then()
                              .shimmer(
                                  delay: 600.ms,
                                  duration: 1000.ms,
                                  color: Colors.white.withOpacity(0.3)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              isEnglish ? 'Verse Options' : 'خيارات الآية',
                              style: GoogleFonts.getFont(
                                fontFamily,
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 300.ms, duration: 400.ms)
                              .slideX(
                                  begin: isEnglish ? -0.3 : 0.3,
                                  end: 0,
                                  delay: 300.ms),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Colors.white24),
                      const SizedBox(height: 16),

                      // Play verse option
                      _buildOptionTile(
                        icon: Icons.play_arrow,
                        title: isEnglish ? 'Play Verse' : 'تشغيل الآية',
                        onTap: () {
                          Navigator.pop(context);
                          _playVerse(widget.surahId, verseNumber);
                        },
                        delay: 300,
                      ),

                      const SizedBox(height: 12),

                      // Share option
                      _buildOptionTile(
                        icon: Icons.share,
                        title: isEnglish ? 'Share' : 'مشاركة',
                        onTap: () {
                          Navigator.pop(context);
                          _shareVerse(verse, verseNumber);
                        },
                        delay: 400,
                      ),

                      const SizedBox(height: 12),

                      // Copy option
                      _buildOptionTile(
                        icon: Icons.copy,
                        title: isEnglish ? 'Copy' : 'نسخ',
                        onTap: () {
                          Navigator.pop(context);
                          Clipboard.setData(ClipboardData(text: verseText));
                          _showPrimarySnackBar(
                              isEnglish ? 'Copied to clipboard' : 'تم النسخ');
                        },
                        delay: 500,
                      ),

                      const SizedBox(height: 12),

                      // Tafsir option
                      _buildOptionTile(
                        icon: Icons.menu_book,
                        title: isEnglish ? 'Tafsir' : 'تفسير',
                        onTap: () {
                          Navigator.pop(context);
                          _showTafsirPage(verse, verseNumber);
                        },
                        delay: 550,
                      ),

                      const SizedBox(height: 20),

                      // Cancel button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            isEnglish ? 'Cancel' : 'إلغاء',
                            style: GoogleFonts.getFont(
                              fontFamily,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                    ],
                  ),
                ),

                // Auto-dismiss indicator
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scaleXY(
                          begin: 1.0,
                          end: 0.3,
                          duration: 2000.ms,
                          curve: Curves.easeInOut)
                      .then()
                      .scaleXY(
                          begin: 0.3,
                          end: 1.0,
                          duration: 2000.ms,
                          curve: Curves.easeInOut),
                ),
              ],
            ),
          )
              .animate()
              .slideY(
                  begin: 1.0,
                  end: 0.0,
                  duration: 500.ms,
                  curve: Curves.elasticOut)
              .fadeIn(duration: 500.ms),
        );
      },
    ).then((_) {
      setState(() {
        _selectedVerse = null;
      });
    });
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.getFont(
            fontFamily,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white.withOpacity(0.7),
          size: 16,
        ),
        onTap: onTap,
      ),
    )
        .animate()
        .fadeIn(delay: delay.ms, duration: 400.ms)
        .slideX(begin: isEnglish ? -0.2 : 0.2, end: 0, delay: delay.ms);
  }

  Future<void> _playVerse(int surahId, int verseNumber) async {
    try {
      // Pick reader for verse playback
      final readerKey = await _pickVerseReaderKey();
      if (readerKey == null) return; // User cancelled

      // Get global verse number
      final globalVerseNumber =
          await _getGlobalVerseNumber(surahId, verseNumber);

      final edition = _editionForReader(readerKey);
      final bitrate = _bitrateForReader(readerKey);
      final verseUrl =
          'https://cdn.islamic.network/quran/audio/$bitrate/$edition/$globalVerseNumber.mp3';

      // Stop any current playback
      await _audioPlayer.stop();

      // Play the verse audio immediately (audio controls will show automatically)
      await _audioPlayer.play(UrlSource(verseUrl));
    } catch (e) {
      print('Error playing verse: $e');
    }
  }

  Future<String?> _pickVerseReaderKey() async {
    // Filter out specific readers for verse playback
    final verseReaders = _audioReaders.where((reader) {
      final key = reader['key'];
      // Exclude these readers from verse playback
      return key != 'maher' && key != 'sds' && key != 'yasser';
    }).toList();

    final selectedKey = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Directionality(
          textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 520),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _primaryColor,
                    _primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.record_voice_over,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isEnglish
                                    ? 'Choose reciter for verse'
                                    : 'اختر القارئ للآية',
                                style: GoogleFonts.getFont(
                                  fontFamily,
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1, color: Colors.white24),
                        const SizedBox(height: 16),
                        Flexible(
                          child: SingleChildScrollView(
                            child: Column(
                              children: verseReaders.map((reader) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        reader[isEnglish ? 'en' : 'ar'] ?? '',
                                        style: GoogleFonts.getFont(
                                          fontFamily,
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.of(context)
                                            .pop(reader['key']);
                                      },
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    return selectedKey;
  }

  Future<int> _getGlobalVerseNumber(int surahId, int verseNumber) async {
    // Calculate global verse number (1 to 6236)
    // This is a simplified calculation - you may need to adjust based on your data
    final chapters = await SurahsListServices.loadLocalChapters();
    int globalVerseNumber = verseNumber;

    for (final chapter in chapters.chapters) {
      if (chapter.id < surahId) {
        globalVerseNumber += chapter.versesCount;
      } else {
        break;
      }
    }

    return globalVerseNumber;
  }

  void _shareVerse(Verse verse, int verseNumber) {
    final arabicNumber = _toArabicNumber(verseNumber, false);
    final verseTextWithNumber =
        '${verse.textUthmani.trim()} (${_toArabicNumber(verseNumber, false)})';

    final surahName = isEnglish ? widget.surahName : widget.arabicName;

    final shareText = isEnglish
        ? '$verseTextWithNumber\n\n${widget.arabicName}، الآية $arabicNumber\n\nQuran Verse - ${widget.surahName} $verseNumber\n\nShared via Siraj - سِرَاچ\nDownload the app: https://play.google.com/store/apps/details?id=com.youssef.islamic_app'
        : '$verseTextWithNumber\n\n${widget.arabicName}، الآية $arabicNumber\n\n- مشاركة من Siraj - سِرَاچ\nحمل التطبيق: https://play.google.com/store/apps/details?id=com.youssef.islamic_app';

    final shareSubject = isEnglish
        ? 'Quran Verse - ${widget.surahName} $verseNumber'
        : 'آية قرآنية - ${widget.arabicName} $arabicNumber';

    Share.share(shareText, subject: shareSubject);
  }

  void _showTafsirPage(Verse verse, int verseNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TafsirPage(
          verse: verse,
          verseNumber: verseNumber,
          surahName: widget.surahName,
          arabicName: widget.arabicName,
        ),
      ),
    );
  }

  Widget _buildSearchResultsInfo() {
    if (_searchQuery.isEmpty || filteredVerses == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isEnglish
            ? '${filteredVerses!.length} verses found'
            : 'تم العثور على ${filteredVerses!.length} آية',
        style: GoogleFonts.getFont(
          fontFamily,
          color: _primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (verses == null) return Container();

    final maxPage = _maxPageIndexForCurrentList();
    final pageCount = maxPage + 1;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            backgroundColor.withOpacity(0.9),
            backgroundColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Main content with staggered animations
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Scroll instruction message
                      if (_showScrollInstruction)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _primaryColor.withOpacity(0.1),
                                _primaryColor.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _primaryColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.swipe_vertical,
                                    color: _primaryColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      isEnglish
                                          ? 'Swipe left or right to navigate between pages'
                                          : 'اسحب يساراً أو يميناً للتنقل بين الصفحات',
                                      style: GoogleFonts.getFont(
                                        fontFamily,
                                        color: _primaryColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _showScrollInstruction = false;
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          _primaryColor.withOpacity(0.1),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      isEnglish ? 'Understand' : 'فهمت',
                                      style: GoogleFonts.getFont(
                                        fontFamily,
                                        color: _primaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 100.ms).slideY(
                              begin: -0.2,
                              end: 0,
                              curve: Curves.easeOutCubic,
                              duration: 400.ms,
                            ),
                      // Basmala for first page (excluding Surah 1 and 9)
                      if (widget.surahId != 9 &&
                          widget.surahId != 1 &&
                          _currentPage == 0)
                        _buildBasmala().animate().fadeIn(delay: 100.ms).slideY(
                              begin: 0.2,
                              end: 0,
                              curve: Curves.easeOutCubic,
                              duration: 400.ms,
                            ),
                      const SizedBox(height: 8),
                      _buildSearchResultsInfo()
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .scaleXY(
                            begin: 0.9,
                            end: 1,
                            curve: Curves.elasticOut,
                          ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: PageView.builder(
                          reverse: true,
                          controller: _pageController,
                          itemCount: pageCount,
                          onPageChanged: (index) {
                            // Hide scroll instruction when user scrolls
                            if (_showScrollInstruction) {
                              setState(() {
                                _showScrollInstruction = false;
                              });
                            }

                            // Save offset of the page we are leaving (only if allowed)
                            if (_allowPositionSaving && _searchQuery.isEmpty) {
                              _saveScrollOffsetForPage(_currentPage);
                            }

                            setState(() {
                              _currentPage = index;
                            });

                            // Always update saved last page when not searching, regardless of position saving
                            if (_searchQuery.isEmpty) {
                              _savedLastPage = index;
                            }

                            // Save the new page number (only if allowed)
                            if (_allowPositionSaving) {
                              _saveLastPage();
                            }

                            // Load offset for the new page only if we are supposed to restore position
                            if (_shouldSavePosition) {
                              _loadScrollOffsetForPage(_currentPage)
                                  .then((value) {
                                _pendingRestoreOffset = value;
                                _restoreScrollForCurrentPage();
                              });
                            }
                            // Check for juz verses on page change

                            _checkAndShowJuzDialog();
                          },
                          itemBuilder: (context, index) {
                            final items = _pageItemsForIndex(index);
                            final controller = _scrollControllerForPage(index);
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                const bottomPadding = 80.0;
                                const containerOuterPadding = 5.0;
                                const richTextPadding = 12.0;
                                final availableHeight =
                                    (constraints.maxHeight - bottomPadding)
                                        .clamp(0.0, double.infinity);
                                final availableWidth = (constraints.maxWidth -
                                        (containerOuterPadding * 2) -
                                        (richTextPadding * 2))
                                    .clamp(0.0, double.infinity);

                                final spans = _buildVerseSpans(items);
                                final fittedFontSize = _autoFitFontSizeForPage(
                                  spans: spans,
                                  maxWidth: availableWidth,
                                  targetHeight: availableHeight,
                                  baseFontSize: _fontSize,
                                );

                                return Listener(
                                  onPointerDown: (_) {
                                    if (_isAutoScrolling) {
                                      _pauseAutoScroll();
                                    }
                                  },
                                  onPointerUp: (_) {
                                    if (_wasAutoScrollingBeforeTouch) {
                                      _resumeAutoScroll();
                                    }
                                  },
                                  child: CustomScrollView(
                                    controller: controller,
                                    physics: const BouncingScrollPhysics(),
                                    slivers: [
                                      SliverFillRemaining(
                                        hasScrollBody: false,
                                        child: Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: primaryColor
                                                      .withOpacity(0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(5),
                                              child:
                                                  _buildVerseRichTextWithFontSize(
                                                          spans, fittedFontSize)
                                                      .animate()
                                                      .fadeIn(delay: 150.ms)
                                                      .shimmer(
                                                        delay: 400.ms,
                                                        duration: 900.ms,
                                                        color: _primaryColor
                                                            .withOpacity(0.1),
                                                      ),
                                            )
                                                .animate(
                                                    onPlay: (controller) =>
                                                        controller.repeat())
                                                .shimmer(
                                                  duration: 3000.ms,
                                                  angle: -0.1,
                                                  size: 0.8,
                                                  delay: 1000.ms,
                                                  color: _primaryColor
                                                      .withOpacity(0.05),
                                                ),
                                            const Spacer(),
                                            const SizedBox(height: 80),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Juz dialog overlay
                _buildJuzDialog(),
              ],
            ),
          ),

          if (_isKhatmaSession &&
              widget.surahId == 114 &&
              _searchQuery.isEmpty &&
              _currentPage == _maxPageIndexForCurrentList())
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('khatma_state', 'inactive');
                    await prefs.setBool('khatma_enabled', false);
                    await prefs.remove('khatma_last_surah');
                    await prefs.remove('khatma_last_page');
                    await prefs.remove('khatma_last_offset');

                    if (!mounted) return;

                    await showDialog<void>(
                      context: context,
                      builder: (dialogContext) {
                        return Dialog(
                          insetPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 18),
                          backgroundColor: Colors.transparent,
                          child: Container(
                            constraints: const BoxConstraints(
                              maxWidth: 400, // Fixed width
                              maxHeight: 500, // Fixed height
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _primaryColor,
                                  _primaryColor.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryColor.withOpacity(0.3),
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
                                // Decorative pattern
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

                                // Main content
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(18, 18, 10, 8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          IconButton(
                                            onPressed: () =>
                                                Navigator.pop(dialogContext),
                                            icon: const Icon(Icons.close),
                                            color: Colors.white,
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.auto_awesome,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          )
                                              .animate()
                                              .scale(
                                                  delay: 200.ms,
                                                  duration: 300.ms)
                                              .then()
                                              .shimmer(
                                                  delay: 600.ms,
                                                  duration: 1000.ms,
                                                  color: Colors.white
                                                      .withOpacity(0.3)),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              isEnglish
                                                  ? 'Khatma Dua'
                                                  : 'دعاء ختم القرآن',
                                              style: GoogleFonts.getFont(
                                                fontFamily,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 4,
                                                    offset: const Offset(1, 1),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                              .animate()
                                              .fadeIn(
                                                  delay: 300.ms,
                                                  duration: 400.ms)
                                              .slideX(
                                                  begin: isEnglish ? -0.3 : 0.3,
                                                  end: 0,
                                                  delay: 300.ms),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      const Divider(
                                          height: 1, color: Colors.white24),
                                      Flexible(
                                        child: StatefulBuilder(
                                          builder: (context, setState) {
                                            return Column(
                                              children: [
                                                Container(
                                                  constraints:
                                                      const BoxConstraints(
                                                    maxHeight:
                                                        280, // Reduced height for message space
                                                  ),
                                                  child: PageView.builder(
                                                    itemCount:
                                                        _khatmaDuaPages.length,
                                                    controller:
                                                        PageController(),
                                                    scrollDirection: isEnglish
                                                        ? Axis.horizontal
                                                        : Axis.horizontal,
                                                    reverse:
                                                        !isEnglish, // Scroll from left to right for Arabic
                                                    itemBuilder:
                                                        (context, pageIndex) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                8, 14, 8, 16),
                                                        child: Text(
                                                          textAlign:
                                                              TextAlign.center,
                                                          _khatmaDuaPages[
                                                              pageIndex],
                                                          style: GoogleFonts
                                                              .getFont(
                                                            fontFamily,
                                                            fontSize: 14.5,
                                                            height: 1.9,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            shadows: [
                                                              Shadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.2),
                                                                blurRadius: 2,
                                                                offset:
                                                                    const Offset(
                                                                        1, 1),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 12),

                                                // Scroll instruction message
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    isEnglish
                                                        ? '← Swipe right for next page | Swipe left for previous →'
                                                        : '← اسحب لليمين للصفحة التالية | اسحب لليسار للصفحة السابقة →',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.getFont(
                                                      fontFamily,
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Auto-dismiss indicator
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );

                    if (mounted) Navigator.pop(context);
                  },
                  child: Text(
                    isEnglish ? 'Finish Khatma' : 'إنهاء الختمة',
                    style: GoogleFonts.getFont(
                      fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Enhanced audio controls animation
          _buildAudioControls().animate().fadeIn(delay: 400.ms).slideY(
                begin: 1,
                end: 0,
                curve: Curves.easeOut,
                duration: 500.ms,
              ),
        ],
      ),
    );
  }

  Widget _buildJuzDialog() {
    if (!_isJuzDialogVisible || _currentJuzNumber == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 50,
      left: 60,
      right: 60,
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _primaryColor,
              _primaryColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.3),
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
            // Decorative pattern
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

            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Juz icon with animation
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.bookmark,
                      color: Colors.white,
                      size: 24,
                    ),
                  )
                      .animate()
                      .scale(delay: 200.ms, duration: 300.ms)
                      .then()
                      .shimmer(
                          delay: 600.ms,
                          duration: 1000.ms,
                          color: Colors.white.withOpacity(0.3)),

                  const SizedBox(width: 16),

                  // Juz text
                  Directionality(
                    textDirection:
                        isEnglish ? TextDirection.ltr : TextDirection.rtl,
                    child: Align(
                      alignment: isEnglish
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Text(
                        isEnglish
                            ? 'Juz ${_currentJuzNumber}'
                            : 'الجزء ${_toArabicNumber(int.parse(_currentJuzNumber!), false)}',
                        style: GoogleFonts.getFont(
                          fontFamily,
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        textAlign: isEnglish ? TextAlign.left : TextAlign.right,
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideX(
                      begin: isEnglish ? -0.3 : 0.3, end: 0, delay: 300.ms),

                  const Spacer(),

                  // Progress indicator
                  Container(
                    width: 4,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                          .animate()
                          .slideY(
                              begin: 1.0,
                              end: 0.0,
                              delay: 500.ms,
                              duration: 800.ms,
                              curve: Curves.easeOutBack)
                          .then()
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .shimmer(
                              duration: 2000.ms,
                              color: Colors.white.withOpacity(0.6)),
                    ),
                  ),
                ],
              ),
            ),

            // Auto-dismiss indicator
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scaleXY(
                      begin: 1.0,
                      end: 0.3,
                      duration: 2000.ms,
                      curve: Curves.easeInOut)
                  .then()
                  .scaleXY(
                      begin: 0.3,
                      end: 1.0,
                      duration: 2000.ms,
                      curve: Curves.easeInOut),
            ),
          ],
        ),
      )
          .animate()
          .slideY(
              begin: 1.0, end: 0.0, duration: 500.ms, curve: Curves.elasticOut)
          .fadeIn(duration: 500.ms)
          .then()
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .shimmer(duration: 3000.ms, color: Colors.white.withOpacity(0.1)),
    );
  }

  Widget _buildAudioControls() {
    final bool hasDuration = _duration.inSeconds > 0;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: _showAudioControls
          ? Container(
              key: const ValueKey('audioControlsVisible'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: _cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isDownloading)
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: _downloadProgress.clamp(0.0, 1.0),
                          backgroundColor: _primaryColor.withOpacity(0.1),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(_primaryColor),
                          minHeight: 2,
                        ),
                        Text(
                          '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.getFont(
                            fontFamily,
                            color: _primaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  if (hasDuration)
                    SliderTheme(
                      data: SliderThemeData(
                        overlayShape: SliderComponentShape.noOverlay,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: _position.inSeconds
                            .clamp(0, _duration.inSeconds)
                            .toDouble(),
                        min: 0,
                        max: _duration.inSeconds.toDouble(),
                        onChanged: (value) async {
                          await _audioPlayer
                              .seek(Duration(seconds: value.toInt()));
                        },
                        activeColor: _primaryColor,
                        inactiveColor: _primaryColor.withOpacity(0.3),
                      ),
                    ),
                  if (hasDuration)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: GoogleFonts.getFont(
                              fontFamily,
                              color: _textColor,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: GoogleFonts.getFont(
                              fontFamily,
                              color: _textColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: _primaryColor,
                        child: IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () {
                            if (_isPlaying) {
                              _pauseSurah();
                            } else {
                              _playSurah();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Tooltip(
                        message: isEnglish ? 'Stop' : 'إيقاف',
                        child: IconButton(
                          icon: Icon(
                            Icons.stop,
                            color: _primaryColor,
                            size: 28,
                          ),
                          onPressed: _stopSurah,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 2000.ms),
          const SizedBox(height: 16),
          Text(
            isEnglish ? 'Loading Surah...' : 'جاري تحميل السورة...',
            style: GoogleFonts.getFont(
              fontFamily,
              color: _textColor,
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: _primaryColor, size: 48)
              .animate()
              .shake(duration: 600.ms)
              .then()
              .scaleXY(end: 1.1, duration: 300.ms)
              .then()
              .scaleXY(end: 1.0, duration: 300.ms),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.getFont(
                fontFamily,
                color: _textColor,
                fontSize: 16,
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadVerses,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              isEnglish ? 'Retry' : 'إعادة المحاولة',
              style: GoogleFonts.getFont(
                fontFamily,
                color: Colors.white,
              ),
            ),
          ).animate(delay: 500.ms).scaleXY(
                begin: 0.8,
                end: 1,
                curve: Curves.elasticOut,
              ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoading();
    } else if (errorMessage.isNotEmpty) {
      return _buildError();
    } else {
      return _buildContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: _cardColor,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light.copyWith(
              statusBarColor: _primaryColor,
              systemNavigationBarColor: _cardColor,
            ),
            child: _buildBody(),
          ),
        ),
        floatingActionButton: AnimatedOpacity(
          opacity: _isJuzDialogVisible ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: IgnorePointer(
            ignoring: _isJuzDialogVisible,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.only(
                bottom: _showAudioControls ? 130 : 0,
                right: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedOpacity(
                    opacity: _isFabMenuOpen ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: IgnorePointer(
                      ignoring: !_isFabMenuOpen,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FloatingActionButton(
                            heroTag: 'first_page',
                            mini: true,
                            backgroundColor: _primaryColor,
                            tooltip: isEnglish ? 'First page' : 'الصفحة الأولى',
                            onPressed: () {
                              setState(() {
                                _isFabMenuOpen = false;
                              });
                              _goToFirstPage();
                            },
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FloatingActionButton(
                            heroTag: 'zoom_out',
                            mini: true,
                            backgroundColor: _primaryColor,
                            onPressed: () {
                              setState(() {
                                if (_fontSize > 16) {
                                  _fontSize -= 2;
                                }
                              });
                            },
                            child: const Icon(
                              Icons.zoom_out,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FloatingActionButton(
                            heroTag: 'zoom_in',
                            mini: true,
                            backgroundColor: _primaryColor,
                            onPressed: () {
                              setState(() {
                                if (_fontSize < 36) {
                                  _fontSize += 2;
                                }
                              });
                            },
                            child: const Icon(
                              Icons.zoom_in,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FloatingActionButton(
                            heroTag: 'download',
                            mini: true,
                            backgroundColor: _primaryColor,
                            onPressed: _isDownloading
                                ? _cancelDownload
                                : () {
                                    setState(() {
                                      _isFabMenuOpen = false;
                                    });
                                    _downloadAudio();
                                  },
                            child: _isDownloading
                                ? GestureDetector(
                                    onTap: _cancelDownload,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            value: _downloadProgress,
                                            strokeWidth: 2,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                    Color>(Colors.white),
                                          ),
                                        ),
                                        Text(
                                          '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Icon(
                                    Icons.download,
                                    color: Colors.white,
                                  ),
                          ),
                          const SizedBox(height: 10),
                          FloatingActionButton(
                            heroTag: 'play',
                            mini: true,
                            backgroundColor: _primaryColor,
                            onPressed: _isPlayButtonLoading
                                ? null
                                : () {
                                    setState(() {
                                      _isFabMenuOpen = false;
                                    });
                                    if (_isPlaying) {
                                      _stopSurah();
                                    } else {
                                      _playSurah();
                                    }
                                  },
                            child: _isPlayButtonLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Icon(
                                    _isPlaying ? Icons.stop : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                          ),
                          const SizedBox(height: 10),
                          FloatingActionButton(
                            heroTag: 'autoscroll',
                            mini: true,
                            backgroundColor: _isAutoScrolling
                                ? Colors.orange
                                : _primaryColor,
                            tooltip: _isAutoScrolling
                                ? (isEnglish
                                    ? 'Stop auto-scroll'
                                    : 'إيقاف التمرير التلقائي')
                                : (isEnglish
                                    ? 'Start auto-scroll (long press for speed)'
                                    : 'بدء التمرير التلقائي (اضغط مطولاً للسرعة)'),
                            onPressed: () {
                              setState(() {
                                _isFabMenuOpen = false;
                              });
                              _toggleAutoScroll();
                            },
                            child: GestureDetector(
                              onLongPress: () {
                                setState(() {
                                  _isFabMenuOpen = false;
                                });
                                _showSpeedControlDialog();
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Icon(
                                _isAutoScrolling
                                    ? Icons.pause
                                    : Icons.swipe_down,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  FloatingActionButton(
                    heroTag: 'fab_menu',
                    backgroundColor: _primaryColor,
                    onPressed: () {
                      setState(() {
                        _isFabMenuOpen = !_isFabMenuOpen;
                      });
                    },
                    child: Icon(
                      _isFabMenuOpen ? Icons.close : Icons.menu,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
