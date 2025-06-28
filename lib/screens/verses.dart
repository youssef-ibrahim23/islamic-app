// ignore_for_file: unused_field, depend_on_referenced_packages, use_build_context_synchronously, deprecated_member_use

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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

  const SurahDetailPage(this.surahName, this.surahId, this.arabicName, {super.key});

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> with WidgetsBindingObserver {
  final Color _primaryColor = const Color(0xFF8B0000);
  final Color _textColor = const Color(0xFF333333);
  final Color _cardColor = Colors.white;
  final ScrollController _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _searchController = TextEditingController();

  List<Verse>? verses;
  List<Verse>? filteredVerses;
  String? _allVersesText;
  int? _lastClickedVerse;
  bool isLoading = true;
  String errorMessage = '';
  PlayerState _playerState = PlayerState.stopped;
  double _playbackSpeed = 1.0;
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
  double _lastScrollPosition = 0.0;
  int? _selectedVerse;
  bool _isSearching = false;
  String _searchQuery = '';

  bool get isEnglish => Globals.languageState ?? true;
  String get fontFamily => isEnglish ? 'Roboto' : 'Tajawal';
  String get arabicFontFamily => 'Scheherazade New';
  
  String get _audioBaseUrl => 'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/${widget.surahId.toString().padLeft(3, '0')}.mp3';
  String get _downloadBaseUrl => 'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/${widget.surahId.toString().padLeft(3, '0')}.mp3';

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
    _loadScrollPosition();
    _searchController.addListener(() => _onSearchChanged());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveScrollPosition();
    _audioPlayer.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    Globals.isSearching = false;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _saveScrollPosition();
      Globals.isSearching = false;
    } else if (state == AppLifecycleState.resumed) {
      _loadScrollPosition();
      Globals.isSearching = false;
    }
  }

  // Add WillPopCallback to handle device back button
  Future<bool> _onWillPop() async {
    await _saveScrollPosition();
    return true; // Allow the back navigation
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterVerses();
    });
  }

  String _normalizeArabic(String input) {
    final diacritics = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');
    String normalized = input.replaceAll(diacritics, '');
    normalized = normalized.replaceAll('ٱ', 'ا');
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

  Future<void> _loadScrollPosition() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastScrollPosition = prefs.getDouble('scroll_position_${widget.surahId}') ?? 0.0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_lastScrollPosition);
      }
    });
  }

  Future<void> _saveScrollPosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('scroll_position_${widget.surahId}', _scrollController.offset);
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
    await Future.wait([
      _loadLastClickedVerse(),
      _loadVerses(),
    ]);
  }

  Future<void> _loadLastClickedVerse() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _lastClickedVerse = prefs.getInt('last_clicked_${widget.surahId}') ?? 1);
  }

  Future<void> _saveLastClickedVerse(int verse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_clicked_${widget.surahId}', verse);
    setState(() => _lastClickedVerse = verse);
  }

  Future<void> _loadVerses() async {
    try {
      final quranData = await QuranService.loadLocalVerses(widget.surahId);
      setState(() {
        verses = quranData.verses;
        filteredVerses = verses;
        _allVersesText = _combineVersesWithIcons(verses!);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = isEnglish
            ? 'Error loading verses: $e'
            : 'حدث خطأ في تحميل الآيات: $e';
        isLoading = false;
      });
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEnglish 
                ? 'Error playing audio'
                : 'حدث خطأ في تشغيل الصوت',
          ),
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

  Future<void> _changePlaybackSpeed() async {
    double newSpeed;
    if (_playbackSpeed == 1.0) {
      newSpeed = 1.5;
    } else if (_playbackSpeed == 1.5) {
      newSpeed = 0.5;
    } else {
      newSpeed = 1.0;
    }
    
    setState(() => _playbackSpeed = newSpeed);
    await _audioPlayer.setPlaybackRate(newSpeed);
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
            content: Text(
              isEnglish
                  ? 'Audio downloaded successfully'
                  : 'تم تنزيل الصوت بنجاح',
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
            content: Text(
              isEnglish
                  ? 'Download failed'
                  : 'فشل التنزيل',
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
          content: Text(
            isEnglish 
                ? 'Audio deleted'
                : 'تم حذف الصوت',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEnglish 
                ? 'Error deleting audio'
                : 'حدث خطأ أثناء حذف الصوت',
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
        onPressed: () {
          _audioPlayer.stop();
          _saveScrollPosition().then((_) {
            Navigator.pop(context);
          });
        },
      ),
      centerTitle: true,
      title: _isSearching
          ? Directionality(
            textDirection: Globals.languageState! ? TextDirection.ltr : TextDirection.rtl,
            child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: isEnglish ? 'Search verses...' : 'ابحث في الآيات...',
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
          icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
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
      margin: const EdgeInsets.only(bottom: 24),
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
        style: GoogleFonts.getFont(
          arabicFontFamily,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
          height: 1.8,
        ),
      ),
    );
  }

  Widget _buildVerseRichText(List<InlineSpan> spans) {
    return GestureDetector(
      onTapDown: (details) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;
        
        final offset = details.localPosition;
        final position = renderBox.globalToLocal(offset);
        
        final textPainter = TextPainter(
          text: TextSpan(children: spans),
          textDirection: TextDirection.rtl,
        )..layout(maxWidth: renderBox.size.width);
        
        final tappedPosition = textPainter.getPositionForOffset(position);
        final tappedText = textPainter.text!.getSpanForPosition(tappedPosition);
        
        if (tappedText is TextSpan && tappedText.recognizer != null) {
          (tappedText.recognizer as TapGestureRecognizer).onTap?.call();
        }
      },
      child: RichText(
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        text: TextSpan(
          children: spans,
          style: TextStyle(
            fontSize: _fontSize,
            height: 2.0,
            fontFamily: arabicFontFamily,
          ),
        ),
      ),
    );
  }

  List<InlineSpan> _buildVerseSpans() {
    final spans = <InlineSpan>[];
    final versesToDisplay = filteredVerses ?? verses ?? [];
    
    for (int i = 0; i < versesToDisplay.length; i++) {
      final verse = versesToDisplay[i];
      final verseNumber = verses!.indexOf(verse) + 1;
      final verseIcon = _toArabicNumber(verseNumber, true);
      final verseText = '${verse.textUthmani} $verseIcon';

      final isSelected = _selectedVerse == verseNumber;
      final isHighlighted = _searchQuery.isNotEmpty && 
          (verse.textUthmani.contains(_searchQuery) == true);

      spans.add(
        TextSpan(
          text: '$verseText ',
          style: TextStyle(
            color: isSelected ? _primaryColor : _textColor,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              setState(() {
                _selectedVerse = verseNumber;
              });
              _showVerseOptions(verseText, verseNumber);
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
                        content: Text(
                          isEnglish ? 'Copied to clipboard' : 'تم النسخ',
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: Text(isEnglish ? 'Bookmark' : 'حفظ'),
                  onTap: () {
                    Navigator.pop(context);
                    _saveLastClickedVerse(verseNumber);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEnglish ? 'Verse bookmarked' : 'تم حفظ الآية',
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
    final verseTextWithNumber = '${verse.textUthmani.trim()} (${_toArabicNumber(verseNumber, false)})';

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

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.surahId != 9 && widget.surahId != 1) _buildBasmala(),
                _buildSearchResultsInfo(),
                _buildVerseRichText(_buildVerseSpans()),
              ],
            ),
          ),
        ),
        _buildAudioControls(),
      ],
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isDownloading)
                    LinearProgressIndicator(
                      value: _downloadProgress.clamp(0.0, 1.0),
                      backgroundColor: _primaryColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                      minHeight: 2,
                    ),
                  if (hasDuration)
                    SliderTheme(
                      data: SliderThemeData(
                        overlayShape: SliderComponentShape.noOverlay,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: _position.inSeconds.clamp(0, _duration.inSeconds).toDouble(),
                        min: 0,
                        max: _duration.inSeconds.toDouble(),
                        onChanged: (value) async {
                          await _audioPlayer.seek(Duration(seconds: value.toInt()));
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
                      Tooltip(
                        message: isEnglish ? 'Playback Speed' : 'سرعة التشغيل',
                        child: TextButton(
                          onPressed: _changePlaybackSpeed,
                          child: Text(
                            '${_playbackSpeed}x',
                            style: GoogleFonts.getFont(
                              fontFamily,
                              color: _primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
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
          ),
          const SizedBox(height: 16),
          Text(
            isEnglish ? 'Loading Surah...' : 'جاري تحميل السورة...',
            style: GoogleFonts.getFont(
              fontFamily,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: _primaryColor, size: 48),
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
            ),
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
        floatingActionButton: Column(
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
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        value: _downloadProgress,
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      _isDownloaded ? Icons.delete : Icons.download,
                      color: Colors.white,
                    ),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'play',
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      _isPlaying ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}