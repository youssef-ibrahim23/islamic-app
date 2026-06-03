import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/models/verse.dart';
import 'package:share_plus/share_plus.dart';

class TafsirPage extends StatefulWidget {
  final Verse verse;
  final int verseNumber;
  final String surahName;
  final String arabicName;

  const TafsirPage({
    super.key,
    required this.verse,
    required this.verseNumber,
    required this.surahName,
    required this.arabicName,
  });

  @override
  State<TafsirPage> createState() => _TafsirPageState();
}

class _TafsirPageState extends State<TafsirPage> {
  String? _tafsirText;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTafsir();
  }

  Future<void> _loadTafsir() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/tafsir.json');
      final List<dynamic> tafsirList = json.decode(jsonString);

      // tafsir.json is 0-based indexed, verse.id is 1-based
      final int tafsirIndex = widget.verse.id - 1;

      if (tafsirIndex >= 0 && tafsirIndex < tafsirList.length) {
        setState(() {
          _tafsirText = tafsirList[tafsirIndex]['tafsir'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _tafsirText = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _tafsirText = null;
        _isLoading = false;
      });
    }
  }

  void _shareTafsir() {
    final isEnglish = Globals.languageState ?? false;
    final arabicNumber = Globals.toArabicNumber(widget.verseNumber.toString());

    final shareText = isEnglish
        ? '﴾ ${widget.verse.textUthmani} ﴿\n\n${_tafsirText ?? "Tafsir not available"}\n\nSource: Al-Mukhtasar fi Tafsir al-Quran al-Karim\n\n${widget.surahName} - Verse ${widget.verseNumber}\n\nShared via Siraj - سِرَاچ\nDownload the app: https://play.google.com/store/apps/details?id=com.youssef.islamic_app'
        : '﴾ ${widget.verse.textUthmani} ﴿\n\n${_tafsirText ?? "التفسير غير متوفر"}\n\nالمصدر: المختصر في تفسير القرآن الكريم\n\n${widget.arabicName} - الآية $arabicNumber\n\n- مشاركة من Siraj - سِرَاچ\nحمل التطبيق: https://play.google.com/store/apps/details?id=com.youssef.islamic_app';

    Share.share(shareText,
        subject: isEnglish
            ? 'Tafsir - ${widget.surahName}'
            : 'تفسير - ${widget.arabicName}');
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Globals.languageState ?? false;
    final fontFamily = isEnglish ? 'Roboto' : 'Tajawal';
    final primaryColor = const Color(0xFF8B0000);
    final backgroundColor = const Color(0xFFF8F5EF);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 4,
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareTafsir,
          ),
        ],
        title: Text(
          isEnglish ? 'Tafsir' : 'التفسير',
          style: GoogleFonts.getFont(
            fontFamily,
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
            opacity: 0.9,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B0000)),
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Surah and verse info header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primaryColor.withOpacity(0.9),
                            primaryColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${widget.arabicName} - ${Globals.toArabicNumber(widget.verseNumber.toString())}',
                            style: GoogleFonts.getFont(
                              'Tajawal',
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isEnglish)
                            Text(
                              '${widget.surahName} - Verse ${widget.verseNumber}',
                              style: GoogleFonts.getFont(
                                'Roboto',
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),

                    const SizedBox(height: 20),

                    // Verse text card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '﴿ ${widget.verse.textUthmani} ﴾',
                            style: GoogleFonts.getFont(
                              'Tajawal',
                              fontSize: 24,
                              height: 1.8,
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: 0.2),

                    const SizedBox(height: 20),

                    // Tafsir text card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tafsir title
                          Row(
                            children: [
                              Icon(
                                Icons.menu_book,
                                color: primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isEnglish ? 'Interpretation' : 'التفسير',
                                style: GoogleFonts.getFont(
                                  fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24, thickness: 1),
                          // Tafsir content
                          if (_tafsirText != null)
                            Text(
                              _tafsirText!,
                              style: GoogleFonts.getFont(
                                'Tajawal',
                                fontSize: 18,
                                height: 1.8,
                                color: const Color(0xFF333333),
                              ),
                              textAlign: TextAlign.justify,
                              textDirection: TextDirection.rtl,
                            )
                          else
                            Text(
                              isEnglish
                                  ? 'Tafsir not available for this verse.'
                                  : 'التفسير غير متوفر لهذه الآية.',
                              style: GoogleFonts.getFont(
                                fontFamily,
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 400.ms)
                        .slideY(begin: 0.2),

                    const SizedBox(height: 20),

                    // Source attribution
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: primaryColor.withOpacity(0.7),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              isEnglish
                                  ? 'Source: Al-Mukhtasar fi Tafsir al-Quran al-Karim'
                                  : 'المصدر: المختصر في تفسير القرآن الكريم',
                              style: GoogleFonts.getFont(
                                fontFamily,
                                fontSize: 12,
                                color: primaryColor.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }
}
