// surah_detail_page.dart
// ignore_for_file: unused_field, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:islamic_app/services/quran_services.dart';
import 'package:islamic_app/services/verses_services.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/verses/audio_controls_widget.dart';
import 'package:islamic_app/widgets/verses/basmala_widget.dart';
import 'package:islamic_app/widgets/verses/error_widget.dart';
import 'package:islamic_app/widgets/verses/loading_widget.dart';
import 'package:islamic_app/widgets/verses/search_results_info_widget.dart';
import 'package:islamic_app/widgets/verses/surah_app_bar.dart';
import 'package:islamic_app/widgets/verses/verse_rich_text_widget.dart';
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
      statusBarColor: primaryColor,
      systemNavigationBarColor: cardColor,
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

  Future<bool> _onWillPop() async {
    await _saveScrollPosition();
    return true;
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterVerses();
    });
  }

  void _filterVerses() {
    final query = VersesServices.normalizeArabic(_searchQuery);

    if (query.isEmpty) {
      filteredVerses = verses;
    } else {
      filteredVerses = verses?.where((verse) {
        final verseText = VersesServices.normalizeArabic(verse.textUthmani);
        return verseText.contains(query);
      }).toList();
    }
  }

  Future<void> _loadScrollPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPosition = prefs.getDouble('scroll_position_${widget.surahId}') ?? 0.0;
    
    setState(() {
      _lastScrollPosition = savedPosition;
    });
    
    if (verses != null && _scrollController.hasClients) {
      _scrollController.jumpTo(savedPosition);
    }
  }

  Future<void> _saveScrollPosition() async {
    if (_scrollController.hasClients) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(
        'scroll_position_${widget.surahId}', 
        _scrollController.offset
      );
    }
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
    await _loadScrollPosition();
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
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients && _lastScrollPosition > 0) {
          _scrollController.jumpTo(_lastScrollPosition);
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = isEnglish
            ? 'Error loading verses'
            : 'حدث خطأ في تحميل الآيات';
        isLoading = false;
      });
    }
  }


  String _combineVersesWithIcons(List<Verse> verses) {
    final buffer = StringBuffer();
    for (int i = 0; i < verses.length; i++) {
      final verse = verses[i];
      final verseNumber = i + 1;
      final verseIcon = VersesServices.toArabicNumber(verseNumber, true);
      
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
            textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
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
            content: Directionality(
              textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
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
              textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
              child: Text(
                isEnglish
                    ? 'Download failed'
                    : 'فشل التنزيل',
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
            textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
            child: Text(
              isEnglish 
                  ? 'Audio deleted'
                  : 'تم حذف الصوت',
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
            child: Text(
              isEnglish 
                  ? 'Error deleting audio'
                  : 'حدث خطأ أثناء حذف الصوت',
            ),
          ),
        ),
      );
    }
  }

  List<InlineSpan> _buildVerseSpans() {
    final spans = <InlineSpan>[];
    final versesToDisplay = filteredVerses ?? verses ?? [];

    for (int i = 0; i < versesToDisplay.length; i++) {
      final verse = versesToDisplay[i];
      final verseNumber = verses!.indexOf(verse) + 1;
      final verseIcon = VersesServices.toArabicNumber(verseNumber, true);
      final verseText = verse.textUthmani;

      final isSelected = _selectedVerse == verseNumber;
      final isHighlighted = _searchQuery.isNotEmpty &&
          verse.textUthmani.contains(_searchQuery);

      spans.add(
        TextSpan(
          text: '$verseText ',
          style: TextStyle(
            fontFamily: arabicFontFamily,
            color: isSelected ? primaryColor : textColor,
            fontWeight: FontWeight.normal,
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

      spans.add(
        TextSpan(
          text: '$verseIcon ',
          style: TextStyle(
            fontFamily: arabicFontFamily,
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: _fontSize + 2,
            shadows: [
              Shadow(
                color: primaryColor.withOpacity(0.2),
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
                          textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
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
    final arabicNumber = VersesServices.toArabicNumber(verseNumber, false);
    final verseTextWithNumber = '${verse.textUthmani.trim()} (${VersesServices.toArabicNumber(verseNumber, false)})';

    final surahName = isEnglish ? widget.surahName : widget.arabicName;

    final shareText = isEnglish
        ? '$surahName, Verse $verseNumber:\n\n$verseTextWithNumber\n\n- Shared via Islamic App'
        : '$surahName، الآية $arabicNumber:\n\n$verseTextWithNumber\n\n- مشاركة من تطبيق القرآن';

    final shareSubject = isEnglish
        ? 'Quran Verse - $surahName $verseNumber'
        : 'آية قرآنية - $surahName $arabicNumber';

    Share.share(shareText, subject: shareSubject);
  }

  Widget _buildContent() {
    if (verses == null) return Container();

    return SingleChildScrollView(
  controller: _scrollController,
  padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
  child: ConstrainedBox(
    constraints: BoxConstraints(
      minHeight: MediaQuery.of(context).size.height - 100, // Ensure minimum height
    ),
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: primaryColor,
          width: 2.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space evenly
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              if (widget.surahId != 9 && widget.surahId != 1) 
                BasmalaWidget(
                  primaryColor: primaryColor,
                  fontSize: _fontSize,
                  arabicFontFamily: arabicFontFamily,
                ),
              SearchResultsInfoWidget(
                searchQuery: _searchQuery,
                filteredVerses: filteredVerses,
                primaryColor: primaryColor,
                fontFamily: fontFamily,
                isEnglish: isEnglish,
              ),
              VerseRichTextWidget(
                spans: _buildVerseSpans(),
                fontSize: _fontSize,
                arabicFontFamily: arabicFontFamily,
                textColor: textColor,
              ),
            ],
          ),
          // Push audio controls to bottom
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: AudioControlsWidget(
              showAudioControls: _showAudioControls,
              isDownloading: _isDownloading,
              downloadProgress: _downloadProgress,
              hasDuration: _duration.inSeconds > 0,
              position: _position,
              duration: _duration,
              playbackSpeed: _playbackSpeed,
              isPlaying: _isPlaying,
              primaryColor: primaryColor,
              textColor: textColor,
              fontFamily: fontFamily,
              isEnglish: isEnglish,
              onChangePlaybackSpeed: _changePlaybackSpeed,
              onPlayPause: () {
                if (_isPlaying) {
                  _pauseSurah();
                } else {
                  _playSurah();
                }
              },
              onStop: _stopSurah,
              onSeek: (value) async {
                await _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),
          ),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildBody() {
    if (isLoading) {
      return LoadingWidget(
        primaryColor: primaryColor,
        textColor: textColor,
        fontFamily: fontFamily,
        isEnglish: isEnglish,
      );
    } else if (errorMessage.isNotEmpty) {
      return ErrorrWidget(
        errorMessage: errorMessage,
        primaryColor: primaryColor,
        textColor: textColor,
        fontFamily: fontFamily,
        isEnglish: isEnglish,
        onRetry: _loadVerses,
      );
    } else {
      return _buildContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && 
          _lastScrollPosition > 0 && 
          _scrollController.offset == 0) {
        _scrollController.jumpTo(_lastScrollPosition);
      }
    });

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: cardColor,
        appBar: SurahAppBar(
          surahName: widget.surahName,
          arabicName: widget.arabicName,
          surahId: widget.surahId,
          isSearching: _isSearching,
          searchController: _searchController,
          isEnglish: isEnglish,
          fontFamily: fontFamily,
          primaryColor: primaryColor,
          onSearchChanged: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _searchQuery = '';
                _filterVerses();
              }
            });
          },
          onBackPressed: () {
            _audioPlayer.stop();
            _saveScrollPosition().then((_) {
              Navigator.pop(context);
            });
          },
        ),
        body: SafeArea(
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light.copyWith(
              statusBarColor: primaryColor,
              systemNavigationBarColor: cardColor,
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
              backgroundColor: primaryColor,
              onPressed: () {
                setState(() {
                  if (_fontSize > 16) {
                    _fontSize -= 2;
                  }
                });
              },
              child: const Icon(Icons.zoom_out, color: Colors.white),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'zoom_in',
              mini: true,
              backgroundColor: primaryColor,
              onPressed: () {
                setState(() {
                  if (_fontSize < 36) {
                    _fontSize += 2;
                  }
                });
              },
              child: const Icon(Icons.zoom_in, color: Colors.white),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'download',
              mini: true,
              backgroundColor: primaryColor,
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
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
              backgroundColor: primaryColor,
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