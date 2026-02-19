// ignore_for_file: unused_field, depend_on_referenced_packages, use_build_context_synchronously, deprecated_member_use

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/services/quran_services.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/models/verse.dart';
import 'package:islamic_app/globals.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class SurahDetailPage extends StatefulWidget {
  final int surahId;
  final String surahName;
  final String arabicName;

  const SurahDetailPage(this.surahName, this.surahId, this.arabicName,
      {super.key});

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

  final int _pageSize = 10;
  int _currentPage = 0;
  int _savedLastPage = 0;
  double _pendingRestoreOffset = 0.0;

  ScrollController _scrollControllerForPage(int page) {
    return _pageScrollControllers.putIfAbsent(page, () => ScrollController());
  }

  bool get isEnglish => Globals.languageState ?? true;
  String get fontFamily => isEnglish ? 'Roboto' : 'Tajawal';
  String get arabicFontFamily => 'Scheherazade New';

  String get _audioBaseUrl =>
      'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/${widget.surahId.toString().padLeft(3, '0')}.mp3';
  String get _downloadBaseUrl =>
      'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/${widget.surahId.toString().padLeft(3, '0')}.mp3';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: _primaryColor,
      systemNavigationBarColor: _cardColor,
    ));
    _setupAudioListeners();
    _checkIfDownloaded();
    _searchController.addListener(() => _onSearchChanged());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveReadingPosition();
    _audioPlayer.dispose();
    _pageController.dispose();
    for (final controller in _pageScrollControllers.values) {
      controller.dispose();
    }
    _searchController.dispose();
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
    final prefs = await SharedPreferences.getInstance();
    final savedPage = prefs.getInt('last_page_${widget.surahId}') ?? 0;

    if (!mounted) return;
    setState(() {
      _savedLastPage = savedPage;
      if (_searchQuery.isEmpty) {
        _currentPage = savedPage;
      }
    });
  }

  Future<void> _saveLastPage() async {
    if (_searchQuery.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page_${widget.surahId}', _currentPage);
    _savedLastPage = _currentPage;
  }

  String _scrollOffsetKeyForPage(int page) {
    return 'scroll_offset_${widget.surahId}_$page';
  }

  Future<double> _loadScrollOffsetForPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_scrollOffsetKeyForPage(page)) ?? 0.0;
  }

  Future<void> _saveScrollOffsetForPage(int page) async {
    if (_searchQuery.isNotEmpty) return;
    final controller = _pageScrollControllers[page];
    if (controller == null || !controller.hasClients) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_scrollOffsetKeyForPage(page), controller.offset);
  }

  Future<void> _saveReadingPosition() async {
    if (_searchQuery.isNotEmpty) return;
    await _saveLastPage();
    await _saveScrollOffsetForPage(_currentPage);
  }

  Future<void> _loadReadingPosition() async {
    await _loadLastPage();
    _pendingRestoreOffset = await _loadScrollOffsetForPage(_currentPage);
    _restoreScrollForCurrentPage();
  }

  void _restoreScrollForCurrentPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = _pageScrollControllers[_currentPage];
      if (controller == null || !controller.hasClients) return;

      final max = controller.position.maxScrollExtent;
      final target = _pendingRestoreOffset.clamp(0.0, max);
      controller.jumpTo(target);
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
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _duration = duration);
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) setState(() => _position = position);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
          _showAudioControls = false;
          _isPlayButtonLoading = false;
        });
      }
    });
  }

  Future<void> _initialize() async {
    await _loadReadingPosition();
    await _loadVerses();
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

      if (_searchQuery.isEmpty) {
        _pendingRestoreOffset = await _loadScrollOffsetForPage(_currentPage);
        _restoreScrollForCurrentPage();
      }

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

  int _maxPageIndexForCurrentList() {
    final list = filteredVerses ?? verses ?? <Verse>[];
    if (list.isEmpty) return 0;
    return (list.length - 1) ~/ _pageSize;
  }

  void _goToPage(int page) {
    final next = page.clamp(0, _maxPageIndexForCurrentList());
    if (next == _currentPage) return;

    _saveScrollOffsetForPage(_currentPage);
    setState(() {
      _currentPage = next;
    });

    _saveLastPage();

    _loadScrollOffsetForPage(_currentPage).then((value) {
      _pendingRestoreOffset = value;
      _restoreScrollForCurrentPage();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<Verse> _pageItemsForIndex(int pageIndex) {
    final list = filteredVerses ?? verses ?? <Verse>[];
    if (list.isEmpty) return <Verse>[];
    final start = (pageIndex * _pageSize).clamp(0, list.length);
    final end = (start + _pageSize).clamp(0, list.length);
    return list.sublist(start, end);
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

      if (_isDownloaded && _localAudioPath != null) {
        await _audioPlayer.play(DeviceFileSource(_localAudioPath!));
      } else {
        await _audioPlayer.play(UrlSource(_audioBaseUrl));
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
              textDirection: Globals.languageState!
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              child: Text(message)),
        ),
      );
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

  Future<void> _downloadAudio() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/surah_${widget.surahId}.mp3';
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
      }

      if (mounted) {
        setState(() {
          _isDownloading = true;
          _downloadProgress = 0.0;
        });
      }

      final dio = Dio();
      await dio.download(
        _downloadBaseUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('audio_${widget.surahId}', filePath);

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isDownloaded = true;
          _localAudioPath = filePath;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Directionality(
              textDirection: Globals.languageState!
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              child: Text(
                isEnglish
                    ? 'Audio downloaded successfully'
                    : 'تم تنزيل الصوت بنجاح',
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Directionality(
              textDirection: Globals.languageState!
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              child: Text(
                isEnglish ? 'Download failed' : 'فشل التنزيل',
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _checkIfDownloaded() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('audio_${widget.surahId}');
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        setState(() {
          _isDownloaded = true;
          _localAudioPath = path;
        });
      } else {
        await prefs.remove('audio_${widget.surahId}');
      }
    }
  }

  Future<void> _deleteDownloadedAudio() async {
    try {
      if (_localAudioPath != null) {
        final file = File(_localAudioPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('audio_${widget.surahId}');

      setState(() {
        _isDownloaded = false;
        _localAudioPath = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection:
                Globals.languageState! ? TextDirection.ltr : TextDirection.rtl,
            child: Text(
              isEnglish ? 'Audio deleted' : 'تم حذف الصوت',
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection:
                Globals.languageState! ? TextDirection.ltr : TextDirection.rtl,
            child: Text(
              isEnglish ? 'Error deleting audio' : 'حدث خطأ أثناء حذف الصوت',
            ),
          ),
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [minutes, seconds].join(':');
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _primaryColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () async {
          _audioPlayer.stop();
          await _saveReadingPosition();
          if (mounted) Navigator.pop(context);
        },
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

  Widget _buildVerseRichText(List<InlineSpan> spans) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: RichText(
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        text: TextSpan(
          children: spans,
          style: TextStyle(
            fontSize: _fontSize,
            height: 2.0,
            fontFamily: arabicFontFamily,
            color: _textColor,
          ),
        ),
      ),
    );
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
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.share),
                  title: Text(isEnglish ? 'Share' : 'مشاركة'),
                  onTap: () {
                    Navigator.pop(context);
                    _shareVerse(verse, verseNumber);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: Text(isEnglish ? 'Copy' : 'نسخ'),
                  onTap: () {
                    Navigator.pop(context);
                    Clipboard.setData(ClipboardData(text: verseText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Directionality(
                          textDirection: Globals.languageState!
                              ? TextDirection.ltr
                              : TextDirection.rtl,
                          child: Text(
                            isEnglish ? 'Copied to clipboard' : 'تم النسخ',
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isEnglish ? 'Cancel' : 'إلغاء'),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      setState(() {
        _selectedVerse = null;
      });
    });
  }

  void _shareVerse(Verse verse, int verseNumber) {
    final arabicNumber = _toArabicNumber(verseNumber, false);
    final verseTextWithNumber =
        '${verse.textUthmani.trim()} (${_toArabicNumber(verseNumber, false)})';

    final surahName = isEnglish ? widget.surahName : widget.arabicName;

    final shareText = isEnglish
        ? '$surahName, Verse $verseNumber:\n\n$verseTextWithNumber\n\n- Shared via Islamic App'
        : '$surahName، الآية $arabicNumber:\n\n$verseTextWithNumber\n\n- مشاركة من تطبيق القرآن';

    final shareSubject = isEnglish
        ? 'Quran Verse - $surahName $verseNumber'
        : 'آية قرآنية - $surahName $arabicNumber';

    Share.share(shareText, subject: shareSubject);
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
                      if (widget.surahId != 9 && widget.surahId != 1)
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _currentPage > 0
                                ? () => _goToPage(_currentPage - 1)
                                : null,
                            icon:
                                Icon(Icons.chevron_left, color: _primaryColor),
                          ),
                          Text(
                            isEnglish
                                ? 'Page ${_currentPage + 1} of $pageCount'
                                : 'صفحة ${_toArabicNumber(_currentPage + 1, false)} من ${_toArabicNumber(pageCount, false)}',
                            style: GoogleFonts.getFont(
                              fontFamily,
                              color: _textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            onPressed: _currentPage < maxPage
                                ? () => _goToPage(_currentPage + 1)
                                : null,
                            icon:
                                Icon(Icons.chevron_right, color: _primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: pageCount,
                          onPageChanged: (index) {
                            if (_searchQuery.isEmpty) {
                              _saveScrollOffsetForPage(_currentPage);
                            }

                            setState(() {
                              _currentPage = index;
                            });

                            _saveLastPage();

                            _loadScrollOffsetForPage(_currentPage)
                                .then((value) {
                              _pendingRestoreOffset = value;
                              _restoreScrollForCurrentPage();
                            });
                          },
                          itemBuilder: (context, index) {
                            final items = _pageItemsForIndex(index);
                            final controller = _scrollControllerForPage(index);
                            return SingleChildScrollView(
                              controller: controller,
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: primaryColor.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(5),
                                    child: _buildVerseRichText(
                                            _buildVerseSpans(items))
                                        .animate()
                                        .fadeIn(delay: 150.ms)
                                        .shimmer(
                                          delay: 400.ms,
                                          duration: 900.ms,
                                          color: _primaryColor.withOpacity(0.1),
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
                                        color: _primaryColor.withOpacity(0.05),
                                      ),
                                  const SizedBox(height: 80),
                                ],
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
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: AnimatedPadding(
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
                            ? null
                            : () {
                                if (_isDownloaded) {
                                  _deleteDownloadedAudio();
                                } else {
                                  _downloadAudio();
                                }
                              },
                        child: _isDownloading
                            ? Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      value: _downloadProgress,
                                      strokeWidth: 2,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Colors.white),
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
                              )
                            : Icon(
                                _isDownloaded ? Icons.delete : Icons.download,
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
    );
  }
}
