import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/models/surah.dart';
import 'package:islamic_app/screens/bottom_bar.dart';
import 'package:islamic_app/screens/verses.dart';
import 'package:islamic_app/services/surahs_list_services.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  List<Chapter>? chapters;
  List<Chapter>? filteredChapters;
  Map<int, String> favoriteSurahIds = {};
  int? lastClickedSurahId;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  bool hasError = false;
  bool isSearching = false;

  String _khatmaState = 'inactive';
  int _khatmaGen = 0;
  int? _khatmaLastSurahId;
  final Map<int, GlobalKey> _surahKeys = {};

  // Tutorial state variables
  bool _isTutorialActive = false;
  int _tutorialStep = 0;
  bool _khatmaTutorialSeen = false;
  bool _isFabHighlighted = false; // متغير التمييز

  // Overlay for custom tutorial dialog
  bool _showTutorialOverlay = false;
  Widget? _tutorialDialogContent;

  // Helper getters for language and direction
  bool get isEnglish => Globals.languageState ?? true;
  TextDirection get textDirection =>
      isEnglish ? TextDirection.ltr : TextDirection.ltr;
  String get fontFamily => isEnglish ? 'Roboto' : 'Tajawal';

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_filterChapters);
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _loadChapters(),
      _loadFavoriteSurahs(),
      _loadLastClickedSurah(),
      _loadKhatmaState(),
      _loadKhatmaTutorialState(),
    ]);

    // Show tutorial if first time
    if (!_khatmaTutorialSeen && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startKhatmaTutorial();
      });
    }
  }

  Future<void> _loadKhatmaState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _khatmaState = prefs.getString('khatma_state') ??
          ((prefs.getBool('khatma_enabled') ?? false) ? 'active' : 'inactive');
      _khatmaGen = prefs.getInt('khatma_gen') ?? 0;
      _khatmaLastSurahId = prefs.getInt('khatma_${_khatmaGen}_last_surah') ??
          prefs.getInt('khatma_last_surah');
    });
  }

  Future<void> _setKhatmaState(String state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('khatma_state', state);
    await prefs.setBool('khatma_enabled', state != 'inactive');

    if (!mounted) return;
    setState(() {
      _khatmaState = state;
    });
  }

  Future<void> _startNewKhatma() async {
    final prefs = await SharedPreferences.getInstance();
    final nextGen = (prefs.getInt('khatma_gen') ?? 0) + 1;
    await prefs.setInt('khatma_gen', nextGen);
    await prefs.setString('khatma_state', 'active');
    await prefs.setBool('khatma_enabled', true);
    await prefs.setInt('khatma_${nextGen}_last_surah', 1);
    await prefs.setInt('khatma_${nextGen}_last_page', 0);
    await prefs.setDouble('khatma_${nextGen}_last_offset', 0.0);

    // Check if this is the first time starting khatma (first generation)
    final hasSeenIntro = prefs.getBool('khatma_intro_seen') ?? false;
    if (!hasSeenIntro && nextGen == 1) {
      await prefs.setBool('khatma_intro_seen', true);
      if (mounted) {
        await _showKhatmaIntroDialog();
      }
    }

    if (!mounted) return;
    setState(() {
      _khatmaGen = nextGen;
      _khatmaState = 'active';
      _khatmaLastSurahId = 1;
    });
  }

  Future<void> _showKhatmaIntroDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(minHeight: 250),
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
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with icon and title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.auto_stories,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              isEnglish ? 'Khatma Mode' : 'وضع الختمة',
                              style: GoogleFonts.getFont(
                                fontFamily,
                                color: Colors.white,
                                fontSize: 20,
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
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Colors.white24),
                      const SizedBox(height: 20),

                      // Message content
                      Text(
                        isEnglish
                            ? 'Welcome to Khatma Mode!\n\nIn this mode, your reading progress is saved automatically. The last surah and page you read will be saved, so you can continue from where you left off anytime.'
                            : ' ! مرحباً بك في وضع الختمة\n\nفي هذا الوضع، يتم حفظ تقدمك في القراءة تلقائياً. سيتم حفظ آخر سورة وصفحة قرأتها، حتى تتمكن من المتابعة من حيث توقفت في أي وقت.',
                        style: GoogleFonts.getFont(
                          fontFamily,
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 2,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // OK button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(
                            isEnglish ? 'Got it !' : '! فهمت',
                            style: GoogleFonts.getFont(
                              fontFamily,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
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
                  begin: 1.0,
                  end: 0.0,
                  duration: 500.ms,
                  curve: Curves.elasticOut)
              .fadeIn(duration: 500.ms),
        );
      },
    );
  }

  Future<void> _continueKhatma() async {
    if (_khatmaState != 'active') return;

    final targetSurahId = _khatmaLastSurahId;
    if (targetSurahId == null || chapters == null) return;

    final targetIndex = chapters!.indexWhere((c) => c.id == targetSurahId);
    if (targetIndex == -1) return;

    const itemHeight = 88.0;
    const topPadding = 16.0;
    const alignmentOffset = 200.0;

    final targetScrollOffset =
        (targetIndex * itemHeight + topPadding - alignmentOffset);
    final maxScrollExtent = _scrollController.hasClients
        ? _scrollController.position.maxScrollExtent
        : (chapters!.length * itemHeight);
    final finalOffset = targetScrollOffset.clamp(0.0, maxScrollExtent);

    try {
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          finalOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final key = _surahKeys[targetSurahId];
          final ctx = key?.currentContext;
          if (ctx != null && mounted) {
            Scrollable.ensureVisible(
              ctx,
              alignment: 0.2,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            ).catchError((e) => print('Fine-tuning scroll failed: $e'));
          }
        });
      } else {
        await Future.delayed(const Duration(milliseconds: 50));
        if (_scrollController.hasClients) {
          await _scrollController.animateTo(
            finalOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      }
    } catch (e) {
      print('Scroll error: $e');
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(finalOffset);
      }
    }
  }

  // Tutorial methods
  Future<void> _loadKhatmaTutorialState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _khatmaTutorialSeen = prefs.getBool('khatma_tutorial_seen') ?? false;
    });
  }

  Future<void> _markKhatmaTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('khatma_tutorial_seen', true);
    setState(() {
      _khatmaTutorialSeen = true;
    });
  }

  void _startKhatmaTutorial() {
    setState(() {
      _isTutorialActive = true;
      _tutorialStep = 0;
    });
    _showTutorialStep();
  }

  Widget _buildTutorialDialog() {
    final isEnglish = Globals.languageState ?? true;
    String title, message, buttonText;
    IconData icon;

    switch (_tutorialStep) {
      case 0:
        title = isEnglish
            ? 'Khatma Button - Inactive State'
            : 'زر الختمة - الحالة غير نشطة';
        message = isEnglish
            ? 'This is the Khatma button when inactive (no active Khatma). It shows "Start Khatma" with a bookmark icon. Tap it to begin a new Quran completion journey!'
            : '! هذا هو زر الختمة عندما يكون غير نشط (لا يوجد ختم نشط). يعرض "ابدأ ختمة" مع أيقونة الإشارة المرجعية. اضغط عليه لبدء رحلة ختم القرآن الجديدة';
        icon = Icons.bookmark_add;
        buttonText = isEnglish ? 'Next' : 'التالي';
        break;
      case 1:
        title = isEnglish
            ? 'Khatma Button - Active State'
            : 'زر الختمة - الحالة نشطة';
        message = isEnglish
            ? 'Now the button is in active state! It shows "Stop Khatma" with a stop icon. Your reading progress is automatically saved when you read. Tap to pause your current Khatma.'
            : '.الآن الزر في الحالة النشطة! يعرض "إيقاف الختمة" مع أيقونة التوقف. يتم حفظ تقدمك في القراءة تلقائياً عند القراءة. اضغط لإيقاف الختمة الحالية مؤقتاً';
        icon = Icons.stop_circle;
        buttonText = isEnglish ? 'Next' : 'التالي';
        break;
      case 2:
        title = isEnglish
            ? 'Khatma Button - Paused State'
            : 'زر الختمة - الحالة مؤقتة';
        message = isEnglish
            ? 'Now the button is in paused state! It shows "Continue Khatma" with a book icon. Your Khatma progress is saved. Tap to continue reading from where you left off.'
            : '. الآن الزر في الحالة المؤقتة! يعرض "أكمل الختمة" مع أيقونة الكتاب. تم حفظ تقدم الختمة. اضغط لمتابعة القراءة من حيث توقفت';
        icon = Icons.menu_book;
        buttonText = isEnglish ? 'Got it!' : '! فهمت';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(
          bottom: 100, left: 40, right: 40), // تجنب التداخل مع FAB
      constraints: const BoxConstraints(minHeight: 120),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with animation
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                )
                    .animate()
                    .scale(delay: 200.ms, duration: 300.ms)
                    .then()
                    .shimmer(
                        delay: 600.ms,
                        duration: 1000.ms,
                        color: Colors.white.withOpacity(0.3)),

                const SizedBox(height: 16),

                // Title and message
                Column(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.getFont(
                        isEnglish ? 'Roboto' : 'Tajawal',
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
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: GoogleFonts.getFont(
                        isEnglish ? 'Roboto' : 'Tajawal',
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                  ],
                ),

                const SizedBox(height: 20),

                // Step indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index == _tutorialStep
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                const SizedBox(height: 20),

                // Button
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        setState(() {
                          if (_tutorialStep < 2) {
                            _tutorialStep++;
                            _showTutorialStep(); // تحديث المحتوى
                          } else {
                            _endTutorial();
                          }
                        });
                      },
                      child: Center(
                        child: Text(
                          buttonText,
                          style: GoogleFonts.getFont(
                            isEnglish ? 'Roboto' : 'Tajawal',
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 500.ms);
  }

  void _showTutorialStep() {
    if (!_isTutorialActive || !mounted) return;

    setState(() {
      _isFabHighlighted = true;
      _showTutorialOverlay = true;
      _tutorialDialogContent = _buildTutorialDialog();

      // تحديث حالة الزر التوضيحية
      switch (_tutorialStep) {
        case 0:
          _khatmaState = 'inactive';
          break;
        case 1:
          _khatmaState = 'active';
          break;
        case 2:
          _khatmaState = 'paused';
          break;
      }
    });
  }

  void _endTutorial() {
    setState(() {
      _isTutorialActive = false;
      _tutorialStep = 0;
      _isFabHighlighted = false;
      _showTutorialOverlay = false;
      _tutorialDialogContent = null;
    });
    _markKhatmaTutorialSeen();
    _loadKhatmaState();
  }

  Future<void> _loadChapters() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final data = await SurahsListServices.loadLocalChapters();
      setState(() {
        chapters = data.chapters;
        filteredChapters = data.chapters;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      _showErrorSnackbar(
          isEnglish ? "Failed to load Surahs" : "فشل تحميل السور");
    }
  }

  Future<void> _loadLastClickedSurah() async {
    final prefs = await SharedPreferences.getInstance();
    final lastClickedId = prefs.getInt('last_clicked_surah');
    setState(() {
      lastClickedSurahId = lastClickedId;
    });
  }

  Future<void> _saveLastClickedSurah(int surahId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_clicked_surah', surahId);
    setState(() {
      lastClickedSurahId = surahId;
    });
  }

  Future<void> _loadFavoriteSurahs() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];

    setState(() {
      favoriteSurahIds = {};
      for (var entry in favorites) {
        final parts = entry.split(':');
        if (parts.length == 2) {
          final id = int.tryParse(parts[0]);
          if (id != null) {
            favoriteSurahIds[id] = parts[1];
          }
        }
      }
    });
  }

  Future<void> _toggleFavorite(Chapter chapter) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (favoriteSurahIds.containsKey(chapter.id)) {
        favoriteSurahIds.remove(chapter.id);
      } else {
        favoriteSurahIds[chapter.id] =
            '${chapter.nameSimple} | ${chapter.nameArabic}';
      }
    });

    await prefs.setStringList(
      'favorites',
      favoriteSurahIds.entries
          .map((entry) => '${entry.key}:${entry.value}')
          .toList(),
    );
  }

  void _filterChapters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredChapters = chapters?.where((chapter) {
        final name = isEnglish ? chapter.nameSimple : chapter.nameArabic;
        return name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ).animate().fadeIn().slideY(begin: -1) as SnackBar,
    );
  }

  void _navigateToSurahDetail(Chapter chapter) {
    _saveLastClickedSurah(chapter.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurahDetailPage(
          chapter.nameSimple,
          chapter.id,
          chapter.nameArabic,
          openSource: _khatmaState == 'active' ? 'khatma' : 'surah_list',
        ),
      ),
    ).then((_) async {
      await _loadKhatmaState();
      if (mounted) setState(() {});
    });
  }

  Widget _buildSurahItem(Chapter chapter, int index) {
    final itemKey = _surahKeys.putIfAbsent(chapter.id, () => GlobalKey());
    final isFavorite = favoriteSurahIds.containsKey(chapter.id);
    final surahNames = isFavorite
        ? favoriteSurahIds[chapter.id]!.split('|')
        : [chapter.nameSimple, chapter.nameArabic];

    final revelationPlace = (chapter.revelationPlace.toLowerCase() == "makkah")
        ? (isEnglish ? "Makkeah" : "مكية")
        : (isEnglish ? "Madaneah" : "مدنية");

    final versesCountText = isEnglish
        ? "${chapter.versesCount} verses"
        : "${Globals.toArabicNumber(chapter.versesCount.toString())} آيات";

    final direction = isEnglish ? TextDirection.ltr : TextDirection.rtl;

    return Directionality(
      textDirection: direction,
      child: Card(
        key: itemKey,
        color: const Color(0xFFF8F5EF),
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToSurahDetail(chapter),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          isEnglish
                              ? chapter.id.toString()
                              : Globals.toArabicNumber(chapter.id.toString()),
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ),
                      if (_khatmaState == 'active' &&
                          _khatmaLastSurahId == chapter.id)
                        const Positioned(
                          top: 0,
                          right: 0,
                          child: Icon(
                            Icons.bookmark,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEnglish ? surahNames[0] : surahNames[1],
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: fontFamily,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.place,
                            size: 14,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            revelationPlace,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 14,
                              fontFamily: fontFamily,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.menu_book,
                            size: 14,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            versesCountText,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 14,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? primaryColor : secondaryTextColor,
                  ),
                  onPressed: () => _toggleFavorite(chapter),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: (index * 1).ms).slideX(
            begin: isEnglish ? -0.2 : 0.2,
            curve: Curves.easeOut,
          ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: primaryColor,
      elevation: 0,
      title: isSearching
          ? Directionality(
              textDirection: Globals.languageState!
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: fontFamily,
                ),
                decoration: InputDecoration(
                  hintText: isEnglish ? "Search Surah..." : "ابحث عن سورة...",
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontFamily: fontFamily,
                  ),
                  border: InputBorder.none,
                ),
              ),
            )
          : Text(
              isEnglish ? "Al Quran" : "القرآن الكريم",
              style: TextStyle(
                fontFamily: fontFamily,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 26,
              ),
            ).animate().fadeIn(duration: 300.ms),
      centerTitle: true,
      leading: isSearching
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                setState(() {
                  isSearching = false;
                  _searchController.clear();
                  filteredChapters = chapters;
                });
              },
            )
          : IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context))
              .animate()
              .fadeIn(duration: 300.ms),
      actions: [
        if (!isSearching)
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                isSearching = true;
              });
            },
          ).animate().fadeIn(duration: 300.ms),
        if (isSearching)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              setState(() {
                isSearching = false;
                _searchController.clear();
                filteredChapters = chapters;
              });
            },
          ).animate().fadeIn(duration: 300.ms),
      ],
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: primaryColor, size: 48),
            const SizedBox(height: 16),
            Text(
              isEnglish ? "Error loading data" : "خطأ في تحميل البيانات",
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadChapters,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isEnglish ? "Retry" : "إعادة المحاولة",
                style: TextStyle(
                  fontFamily: fontFamily,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if ((chapters == null || chapters!.isEmpty) &&
        (filteredChapters == null || filteredChapters!.isEmpty)) {
      return Center(
        child: Text(
          isEnglish ? "No Surahs Available" : "لا توجد سور متاحة",
          style: TextStyle(
            fontSize: 18,
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
      );
    }

    final isFilteredEmpty =
        filteredChapters != null && filteredChapters!.isEmpty;

    return Directionality(
      textDirection: textDirection,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: RefreshIndicator(
          color: primaryColor,
          onRefresh: _loadChapters,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 16, bottom: 80),
            itemCount: isFilteredEmpty ? 0 : filteredChapters!.length,
            itemBuilder: (context, index) {
              final chapter = filteredChapters![index];
              return _buildSurahItem(chapter, index);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool khatmaInactive = _khatmaState == 'inactive';
    final bool khatmaActive = _khatmaState == 'active';
    final bool khatmaPaused = _khatmaState == 'paused';

    final IconData fabIcon = khatmaInactive
        ? Icons.bookmark_add
        : (khatmaActive ? Icons.stop_circle : Icons.menu_book);

    final String fabLabel = khatmaInactive
        ? (isEnglish ? 'Start Khatma' : 'ابدأ ختمة')
        : (khatmaActive
            ? (isEnglish ? 'Stop Khatma' : 'إيقاف الختمة')
            : (isEnglish ? 'Continue Khatma' : 'أكمل الختمة'));

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            _buildBody(),
            if (_showTutorialOverlay)
              Container(
                color: Colors.black.withOpacity(0.7), // طبقة التعتيم
              ),
            if (_showTutorialOverlay && _tutorialDialogContent != null)
              Center(
                child: _tutorialDialogContent!,
              ),
          ],
        ),
        floatingActionButton: Animate(
          effects: [
            if (_isFabHighlighted) ...[
              ScaleEffect(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 600.ms,
                curve: Curves.easeInOut,
              ),
              ShimmerEffect(
                duration: 1200.ms,
                color: Colors.white.withOpacity(0.5),
              ),
              BoxShadowEffect(
                duration: 800.ms,
              ),
            ],
          ],
          child: FloatingActionButton.extended(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            onPressed: () async {
              if (khatmaInactive) {
                await _startNewKhatma();
                await _loadKhatmaState();
                await _continueKhatma();
                return;
              }

              if (khatmaActive) {
                await _setKhatmaState('paused');
                await _loadKhatmaState();
                return;
              }

              if (khatmaPaused) {
                await _setKhatmaState('active');
                await _loadKhatmaState();
                await _continueKhatma();
                return;
              }
            },
            icon: Icon(fabIcon),
            label: Text(fabLabel,
                style: TextStyle(
                    fontFamily: fontFamily, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
