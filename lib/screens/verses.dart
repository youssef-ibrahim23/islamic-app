import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:islamic_app/services/quran_services.dart';
import 'package:islamic_app/services/verse_services.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/verses/app_bar.dart';
import 'package:islamic_app/widgets/verses/audio_controls.dart';
import 'package:islamic_app/widgets/verses/basmala.dart';
import 'package:islamic_app/widgets/verses/verses_rich_text.dart';
import 'package:islamic_app/models/verse.dart';
import 'package:islamic_app/globals.dart';

class SurahDetailPage extends StatefulWidget {
  final int surahId;
  final String surahName;
  final String arabicName;

  const SurahDetailPage(
    this.surahName,
    this.surahId,
    this.arabicName, {
    super.key,
  });

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _searchController = TextEditingController();

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
      statusBarColor: primaryColor,
      systemNavigationBarColor: cardColor,
    ));
    _setupAudioListeners();
    _checkIfDownloaded();
    _loadScrollPosition();
    _searchController.addListener(_onSearchChanged);
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

  Future<void> _initialize() async {
    await Future.wait([
      _loadLastClickedVerse(),
      _loadVerses(),
    ]);
  }

  void _setupAudioListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          Globals.playerState = state;
          Globals.isPlaying = state == PlayerState.playing;
          Globals.showAudioControls = Globals.isPlaying;
          Globals.isPlayButtonLoading = false;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() => Globals.duration = duration);
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) setState(() => Globals.position = position);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          Globals.isPlaying = false;
          Globals.position = Duration.zero;
          Globals.showAudioControls = false;
          Globals.isPlayButtonLoading = false;
        });
      }
    });
  }

  Future<void> _loadScrollPosition() async {
    final position = await QuranServices.loadScrollPosition(widget.surahId);
    if (mounted) setState(() => Globals.lastScrollPosition = position);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(Globals.lastScrollPosition);
      }
    });
  }

  Future<void> _saveScrollPosition() async {
    await QuranServices.saveScrollPosition(widget.surahId, _scrollController.offset);
  }

  Future<void> _loadLastClickedVerse() async {
    final verse = await QuranServices.loadLastClickedVerse(widget.surahId);
    if (mounted) setState(() => Globals.lastClickedVerse = verse);
  }

  Future<void> _saveLastClickedVerse(int verse) async {
    await QuranServices.saveLastClickedVerse(widget.surahId, verse);
    if (mounted) setState(() => Globals.lastClickedVerse = verse);
  }

  Future<void> _loadVerses() async {
    try {
      final quranData = await QuranServices.loadLocalVerses(widget.surahId);
      if (mounted) {
        setState(() {
          Globals.verses = quranData.verses;
          Globals.filteredVerses = Globals.verses;
          Globals.allVersesText = VerseService.combineVersesWithIcons(Globals.verses!);
          Globals.verseIsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          Globals.errorMessage = Globals.languageState! 
              ? 'Error loading verses: $e' 
              : 'حدث خطأ في تحميل الآيات: $e';
          Globals.verseIsLoading = false;
        });
      }
    }
  }

  Future<void> _playSurah() async {
    try {
      setState(() => Globals.isPlayButtonLoading = true);
      await QuranServices.playAudio(
        audioPlayer: _audioPlayer,
        localPath: Globals.localAudioPath,
        remoteUrl: _audioBaseUrl,
      );
      if (mounted) {
        setState(() {
          Globals.isPlaying = true;
          Globals.showAudioControls = true;
          Globals.isPlayButtonLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => Globals.isPlayButtonLoading = false);
        _showSnackBar(Globals.languageState! ? 'Error playing audio' : 'حدث خطأ في تشغيل الصوت');
      }
    }
  }

  Future<void> _downloadAudio() async {
    try {
      setState(() {
        Globals.isDownloading = true;
        Globals.downloadProgress = 0.0;
      });

      final path = await QuranServices.downloadAudio(
        surahId: widget.surahId,
        downloadUrl: _downloadBaseUrl,
        onProgress: (progress) {
          if (mounted) setState(() => Globals.downloadProgress = progress);
        },
      );

      await QuranServices.saveAudioPath(widget.surahId, path);

      if (mounted) {
        setState(() {
          Globals.isDownloading = false;
          Globals.isDownloaded = true;
          Globals.localAudioPath = path;
        });
        _showSnackBar(Globals.languageState! 
            ? 'Audio downloaded successfully' 
            : 'تم تنزيل الصوت بنجاح');
      }
    } catch (e) {
      if (mounted) {
        setState(() => Globals.isDownloading = false);
        _showSnackBar(Globals.languageState! ? 'Download failed' : 'فشل التنزيل');
      }
    }
  }

  Future<void> _checkIfDownloaded() async {
    final path = await QuranServices.getAudioPath(widget.surahId);
    if (path != null && await File(path).exists()) {
      if (mounted) {
        setState(() {
        Globals.isDownloaded = true;
        Globals.localAudioPath = path;
      });
      }
    } else {
      await QuranServices.removeAudioPath(widget.surahId);
    }
  }

  Future<void> _deleteDownloadedAudio() async {
    try {
      if (Globals.localAudioPath != null) {
        final file = File(Globals.localAudioPath!);
        if (await file.exists()) await file.delete();
      }

      await QuranServices.removeAudioPath(widget.surahId);

      if (mounted) {
        setState(() {
          Globals.isDownloaded = false;
          Globals.localAudioPath = null;
        });
        _showSnackBar(Globals.languageState! ? 'Audio deleted' : 'تم حذف الصوت');
      }
    } catch (e) {
      _showSnackBar(Globals.languageState! 
          ? 'Error deleting audio' 
          : 'حدث خطأ أثناء حذف الصوت');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onSearchChanged() {
    setState(() {
      Globals.searchQuery = _searchController.text;
      _filterVerses();
    });
  }

  void _filterVerses() {
    final query = VerseService.normalizeArabic(Globals.searchQuery);
    Globals.filteredVerses = query.isEmpty
        ? Globals.verses
        : Globals.verses?.where((verse) {
            return VerseService.normalizeArabic(verse.textUthmani).contains(query);
          }).toList();
  }

  void _showVerseOptions(String verseText, int verseNumber) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(Globals.languageState! ? 'Share' : 'مشاركة'),
              onTap: () {
                Navigator.pop(context);
                VerseService.shareVerse(
                  verse: Globals.verses![verseNumber - 1],
                  verseNumber: verseNumber,
                  surahName: widget.surahName,
                  arabicName: widget.arabicName,
                  isEnglish: Globals.languageState!,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(Globals.languageState! ? 'Copy' : 'نسخ'),
              onTap: () {
                Navigator.pop(context);
                VerseService.copyToClipboard(verseText);
                _showSnackBar(Globals.languageState! ? 'Copied to clipboard' : 'تم النسخ');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: Text(Globals.languageState! ? 'Bookmark' : 'حفظ'),
              onTap: () {
                Navigator.pop(context);
                _saveLastClickedVerse(verseNumber);
                _showSnackBar(Globals.languageState! ? 'Verse bookmarked' : 'تم حفظ الآية');
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(Globals.languageState! ? 'Cancel' : 'إلغاء'),
            ),
          ],
        ),
      ),
    ).then((_) => setState(() => Globals.selectedVerse = null));
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        await _saveScrollPosition();
        return true;
      },
      child: Scaffold(
        backgroundColor: cardColor,
        appBar: SurahAppBar(
          surahName: widget.surahName,
          arabicName: widget.arabicName,
          surahId: widget.surahId,
          isEnglish: Globals.languageState!,
          isSearching: Globals.isSearching,
          searchController: _searchController,
          onSearchToggle: () => setState(() {
            Globals.isSearching = !Globals.isSearching;
            if (!Globals.isSearching) {
              _searchController.clear();
              Globals.searchQuery = '';
              _filterVerses();
            }
          }),
          onBackPressed: () {
            _audioPlayer.stop();
            _saveScrollPosition().then((_) => Navigator.pop(context));
          },
          fontFamily: Globals.fontFamily,
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
        floatingActionButton: _buildFloatingButtons(),
      ),
    );
  }

  Widget _buildBody() {
    if (Globals.verseIsLoading) return _buildLoading();
    if (Globals.errorMessage.isNotEmpty) return _buildError();
    return _buildContent();
  }

  Widget _buildContent() {
    if (Globals.verses == null) return Container();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.surahId != 9 && widget.surahId != 1)
                  BasmalaWidget(
                    primaryColor: primaryColor,
                    arabicFontFamily: Globals.arabicFontFamily,
                  ),
                if (Globals.searchQuery.isNotEmpty && Globals.filteredVerses != null)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      Globals.languageState!
                          ? '${Globals.filteredVerses!.length} verses found'
                          : 'تم العثور على ${Globals.filteredVerses!.length} آية',
                      style: TextStyle(
                        fontFamily: Globals.fontFamily,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                VerseRichText(
                  spans: _buildVerseSpans(),
                  fontSize: Globals.fontSize,
                  arabicFontFamily: Globals.arabicFontFamily,
                  onVerseTap: (verseNumber) {
                    setState(() => Globals.selectedVerse = verseNumber);
                    _showVerseOptions(
                      '${Globals.verses![verseNumber - 1].textUthmani} ${VerseService.toArabicNumber(verseNumber, true)}',
                      verseNumber,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        AudioControls(
          showControls: Globals.showAudioControls,
          isPlaying: Globals.isPlaying,
          isDownloading: Globals.isDownloading,
          downloadProgress: Globals.downloadProgress,
          position: Globals.position,
          duration: Globals.duration,
          playbackSpeed: Globals.playbackSpeed,
          onPlayPause: () => Globals.isPlaying ? _pauseSurah() : _playSurah(),
          onStop: _stopSurah,
          onChangeSpeed: _changePlaybackSpeed,
          fontFamily: Globals.fontFamily,
          primaryColor: primaryColor,
          textColor: textColor,
          cardColor: cardColor,
        ),
      ],
    );
  }

  List<InlineSpan> _buildVerseSpans() {
    return (Globals.filteredVerses ?? Globals.verses ?? []).map((verse) {
      final verseNumber = Globals.verses!.indexOf(verse) + 1;
      final isSelected = Globals.selectedVerse == verseNumber;
      final isHighlighted = Globals.searchQuery.isNotEmpty && 
          verse.textUthmani.contains(Globals.searchQuery);

      return TextSpan(
        text: '${verse.textUthmani} ${VerseService.toArabicNumber(verseNumber, true)} ',
        style: TextStyle(
          color: isSelected ? primaryColor : textColor,
          backgroundColor: isHighlighted ? primaryColor.withOpacity(0.1) : null,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            setState(() => Globals.selectedVerse = verseNumber);
            _showVerseOptions(
              '${verse.textUthmani} ${VerseService.toArabicNumber(verseNumber, true)}',
              verseNumber,
            );
          },
      );
    }).toList();
  }

  Widget _buildLoading() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              Globals.languageState! ? 'Loading Surah...' : 'جاري تحميل السورة...',
              style: TextStyle(
                fontFamily: Globals.fontFamily,
                color: textColor,
              ),
            ),
          ],
        ),
      );

  Widget _buildError() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: primaryColor, size: 48),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                Globals.errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: Globals.fontFamily,
                  color: textColor,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadVerses,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                Globals.languageState! ? 'Retry' : 'إعادة المحاولة',
                style: TextStyle(
                  fontFamily: Globals.fontFamily,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildFloatingButtons() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'zoom_out',
            mini: true,
            backgroundColor: primaryColor,
            onPressed: () => setState(() {
              if (Globals.fontSize > 16) Globals.fontSize -= 2;
            }),
            child: const Icon(Icons.zoom_out, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'zoom_in',
            mini: true,
            backgroundColor: primaryColor,
            onPressed: () => setState(() {
              if (Globals.fontSize < 36) Globals.fontSize += 2;
            }),
            child: const Icon(Icons.zoom_in, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'download',
            mini: true,
            backgroundColor: primaryColor,
            onPressed: Globals.isDownloading
                ? null
                : () => Globals.isDownloaded 
                    ? _deleteDownloadedAudio() 
                    : _downloadAudio(),
            child: Globals.isDownloading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      value: Globals.downloadProgress,
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    Globals.isDownloaded ? Icons.delete : Icons.download,
                    color: Colors.white,
                  ),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'play',
            backgroundColor: primaryColor,
            onPressed: Globals.isPlayButtonLoading
                ? null
                : () => Globals.isPlaying ? _stopSurah() : _playSurah(),
            child: Globals.isPlayButtonLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    Globals.isPlaying ? Icons.stop : Icons.play_arrow,
                    color: Colors.white,
                  ),
          ),
        ],
      );

  Future<void> _pauseSurah() async {
    await _audioPlayer.pause();
    if (mounted) setState(() => Globals.isPlaying = false);
  }

  Future<void> _stopSurah() async {
    await _audioPlayer.stop();
    if (mounted) {
      setState(() {
        Globals.isPlaying = false;
        Globals.position = Duration.zero;
        Globals.showAudioControls = false;
      });
    }
  }

  Future<void> _changePlaybackSpeed() async {
    double newSpeed = Globals.playbackSpeed == 1.0
        ? 1.5
        : Globals.playbackSpeed == 1.5
            ? 0.5
            : 1.0;

    setState(() => Globals.playbackSpeed = newSpeed);
    await _audioPlayer.setPlaybackRate(newSpeed);
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
}