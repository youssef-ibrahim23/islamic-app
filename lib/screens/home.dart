// ignore_for_file: unnecessary_const

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/services/home_services.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/home/category_item.dart';
import 'package:islamic_app/widgets/home/combined_date_widget.dart';
import 'package:islamic_app/widgets/home/daily_ayat_card.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/screens/azkar.dart';
import 'package:islamic_app/screens/surahs_list.dart';
import 'package:islamic_app/screens/hadith.dart';
import 'package:islamic_app/screens/counter.dart';
import 'package:islamic_app/screens/calender.dart';
import 'package:islamic_app/screens/prayer_times.dart';
import 'package:islamic_app/screens/verses.dart';
import 'package:shared_preferences/shared_preferences.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  late Future<Map<String, dynamic>> _surahFuture;
  bool _currentLanguageState = false;
  bool _backgroundReady = true; // Start with background ready
  Map<String, dynamic>? _cachedSurahData;
  bool _deviceCountryInitialized = false;
  static bool _khatmaPopupShownForSession =
      false; // Track popup shown per app session

  @override
  void initState() {
    super.initState();
    _currentLanguageState = Globals.languageState ?? false;
    _surahFuture = _fetchSurahData();
    _prepareBackground();
    _initializeDeviceCountry();
    _loadUserHijriAdjustment();

    // Check for Khatma mode after a short delay to ensure UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkKhatmaModeAndShowPopup();
    });
  }

  Future<void> _loadUserHijriAdjustment() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      Globals.userHijriAdjustment = prefs.getInt('user_hijri_adjustment') ?? 0;
    });
  }

  Future<void> _initializeDeviceCountry() async {
    try {
      // Wait a bit for app initializer to complete device country detection
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if device country is already set
      if (Globals.deviceCountry != null) {
        if (mounted) {
          setState(() {
            _deviceCountryInitialized = true;
          });
        }
        return;
      }

      // If not set, try to detect it manually
      final prefs = await SharedPreferences.getInstance();
      final savedDeviceCountry = prefs.getString('device_country');

      if (savedDeviceCountry != null) {
        Globals.deviceCountry = savedDeviceCountry;
      } else {
        // Fallback to Egypt if no country is detected
        Globals.deviceCountry = 'Egypt';
        await prefs.setString('device_country', 'Egypt');
      }

      if (mounted) {
        setState(() {
          _deviceCountryInitialized = true;
        });
      }
    } catch (e) {
      // Fallback to Egypt on error
      Globals.deviceCountry = 'Egypt';
      if (mounted) {
        setState(() {
          _deviceCountryInitialized = true;
        });
      }
    }
  }

  void _prepareBackground() async {
    try {
      // Check if background was preloaded from splash screen
      final prefs = await SharedPreferences.getInstance();
      final backgroundPreloaded =
          prefs.getBool('background_preloaded') ?? false;
      final backgroundFullyCached =
          prefs.getBool('background_fully_cached') ?? false;
      final loadTimestamp = prefs.getString('background_load_timestamp');

      // Verify the background is actually ready
      bool isActuallyReady = false;
      if (backgroundPreloaded &&
          backgroundFullyCached &&
          loadTimestamp != null) {
        // Verify the image is actually cached by attempting to load it
        isActuallyReady = await _verifyBackgroundCached();
      }

      // Show background only if it's verified as ready
      if (mounted) {
        setState(() {
          _backgroundReady = isActuallyReady || backgroundPreloaded;
        });
      }

      // If background wasn't properly preloaded, load it now
      if (!isActuallyReady) {
        await _loadBackgroundNow();
        if (mounted) {
          setState(() {
            _backgroundReady = true;
          });
        }
      }

      // Clear the flags for next app launch
      await prefs.remove('background_preloaded');
      await prefs.remove('background_fully_cached');
      await prefs.remove('background_load_timestamp');
    } catch (e) {
      // If there's an error, still show the background after loading it
      await _loadBackgroundNow();
      if (mounted) {
        setState(() {
          _backgroundReady = true;
        });
      }
    }
  }

  // Verify that the background image is actually cached
  Future<bool> _verifyBackgroundCached() async {
    try {
      const imageProvider = AssetImage('assets/images/background.jpg');
      final stream = imageProvider.resolve(ImageConfiguration());

      final completer = Completer<bool>();
      final listener = ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        onError: (Object exception, StackTrace? stackTrace) {
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      );

      stream.addListener(listener);
      return await completer.future.timeout(const Duration(seconds: 1));
    } catch (e) {
      return false;
    }
  }

  // Load background image if not ready
  Future<void> _loadBackgroundNow() async {
    try {
      const imageProvider = AssetImage('assets/images/background.jpg');
      final stream = imageProvider.resolve(ImageConfiguration());

      final completer = Completer<void>();
      final listener = ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onError: (Object exception, StackTrace? stackTrace) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
      );

      stream.addListener(listener);
      await completer.future.timeout(const Duration(seconds: 3));
    } catch (e) {
      // Continue even if loading fails
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Globals.routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);

    // Check if language has changed and reload data if needed
    _checkLanguageChange();
  }

  void _checkLanguageChange() {
    final newLanguageState = Globals.languageState ?? false;
    if (_currentLanguageState != newLanguageState) {
      _currentLanguageState = newLanguageState;
      // Clear cache and reload only if language actually changed
      _cachedSurahData = null;
      setState(() {
        _surahFuture = _fetchSurahData();
      });
    }
  }

  Future<Map<String, dynamic>> _fetchSurahData() async {
    // Return cached data if available
    if (_cachedSurahData != null) {
      return _cachedSurahData!;
    }

    // Fetch and cache the data
    final data = await HomeServices.loadLastSurahAsync();
    _cachedSurahData = data;
    return data;
  }

  /// Check if user is in Khatma mode and show continuation popup
  Future<void> _checkKhatmaModeAndShowPopup() async {
    try {
      // Only check once per app session
      if (_khatmaPopupShownForSession) return;

      final prefs = await SharedPreferences.getInstance();

      // Check if Khatma mode is enabled and active
      final khatmaEnabled = prefs.getBool('khatma_enabled') ?? false;
      final khatmaState = prefs.getString('khatma_state') ?? 'inactive';

      // Only show popup if Khatma is enabled and active, and hasn't been shown yet
      if (khatmaEnabled && khatmaState == 'active') {
        // Get last Khatma reading position
        final khatmaGen = prefs.getInt('khatma_gen') ?? 0;
        final lastSurahId = prefs.getInt('khatma_${khatmaGen}_last_surah') ?? 1;
        final lastPage = prefs.getInt('khatma_${khatmaGen}_last_page') ?? 0;

        // Show popup after a short delay for better UX
        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          _showKhatmaContinuePopup(lastSurahId, lastPage);
        }
      }
    } catch (e) {
      print('Error checking Khatma mode: $e');
    }
  }

  /// Show popup to continue Khatma reading
  void _showKhatmaContinuePopup(int lastSurahId, int lastPage) async {
    final isEnglish = Globals.languageState ?? false;

    // Mark as shown for this session
    _khatmaPopupShownForSession = true;

    // Get surah data for proper navigation
    final surahData = await _getSurahData(lastSurahId);

    showDialog(
      context: context,
      barrierDismissible: false, // User must make a choice
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(minHeight: 120),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF8B0000), // primaryColor
                  const Color(0xFF8B0000).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B0000).withOpacity(0.3),
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
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                          Icons.menu_book_rounded,
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
                            isEnglish ? 'Continue Reading' : 'متابعة القراءة',
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
                            isEnglish
                                ? 'You have an active Khatma. Continue from where you left off?'
                                : 'لديك ختم قرآن نشط. متابعة من حيث توقفت؟',
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

                      // Buttons
                      Row(
                        children: [
                          // Later button
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Center(
                                    child: Text(
                                      isEnglish ? 'Later' : 'لاحقاً',
                                      style: GoogleFonts.getFont(
                                        isEnglish ? 'Roboto' : 'Tajawal',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                          const SizedBox(width: 12),

                          // Continue button
                          Expanded(
                            child: Container(
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
                                    Navigator.of(context).pop();

                                    // Navigate to the last read page in Khatma mode
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => SurahDetailPage(
                                          surahData['nameEn'] ??
                                              '', // surahName
                                          lastSurahId, // surahId
                                          surahData['nameAr'] ??
                                              '', // arabicName
                                          openSource: 'khatma',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Center(
                                    child: Text(
                                      isEnglish ? 'Continue' : 'متابعة',
                                      style: GoogleFonts.getFont(
                                        isEnglish ? 'Roboto' : 'Tajawal',
                                        color: const Color(0xFF8B0000),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate()
              .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOutBack),
        );
      },
    );
  }

  /// Get surah data by ID
  Future<Map<String, dynamic>> _getSurahData(int surahId) async {
    try {
      // Try to get from home services first
      if (_cachedSurahData != null && _cachedSurahData!['id'] == surahId) {
        return _cachedSurahData!;
      }

      // Use a predefined map of common surahs for now
      // In a real implementation, you might want to load this from a JSON file
      final Map<int, Map<String, String>> surahNames = {
        1: {'en': 'Al-Fatiha', 'ar': 'الفاتحة'},
        2: {'en': 'Al-Baqarah', 'ar': 'البقرة'},
        3: {'en': 'Aal-E-Imran', 'ar': 'آل عمران'},
        4: {'en': 'An-Nisa', 'ar': 'النساء'},
        5: {'en': 'Al-Maidah', 'ar': 'المائدة'},
        6: {'en': 'Al-Anam', 'ar': 'الأنعام'},
        7: {'en': 'Al-Araf', 'ar': 'الأعراف'},
        8: {'en': 'Al-Anfal', 'ar': 'الأنفال'},
        9: {'en': 'At-Tawbah', 'ar': 'التوبة'},
        10: {'en': 'Yunus', 'ar': 'يونس'},
        11: {'en': 'Hud', 'ar': 'هود'},
        12: {'en': 'Yusuf', 'ar': 'يوسف'},
        13: {'en': 'Ar-Rad', 'ar': 'الرعد'},
        14: {'en': 'Ibrahim', 'ar': 'إبراهيم'},
        15: {'en': 'Al-Hijr', 'ar': 'الحجر'},
        16: {'en': 'An-Nahl', 'ar': 'النحل'},
        17: {'en': 'Al-Isra', 'ar': 'الإسراء'},
        18: {'en': 'Al-Kahf', 'ar': 'الكهف'},
        19: {'en': 'Maryam', 'ar': 'مريم'},
        20: {'en': 'Ta-Ha', 'ar': 'طه'},
        // Add more as needed...
      };

      final surahNamesData = surahNames[surahId];

      if (surahNamesData != null) {
        return {
          'id': surahId,
          'nameEn': surahNamesData['en'] ?? 'Surah $surahId',
          'nameAr': surahNamesData['ar'] ?? 'سورة $surahId',
        };
      }

      // Fallback for other surahs
      return {
        'id': surahId,
        'nameEn': 'Surah $surahId',
        'nameAr': 'سورة $surahId'
      };
    } catch (e) {
      print('Error getting surah data: $e');
      return {
        'id': surahId,
        'nameEn': 'Surah $surahId',
        'nameAr': 'سورة $surahId'
      };
    }
  }

  @override
  void didPopNext() {
    _checkLanguageChange();
    _loadUserHijriAdjustment();
  }

  @override
  void didPop() {
    _checkLanguageChange();
  }

  @override
  void dispose() {
    Globals.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check for language changes on each build
    _checkLanguageChange();

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isEnglish = Globals.languageState ?? false;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: _backgroundReady
              ? const DecorationImage(
                  image: AssetImage('assets/images/background.jpg'),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low, // Speed up rendering
                )
              : null,
          color: _backgroundReady
              ? null
              : const Color(0xFFF8F5EF), // Fallback color
        ),
        child: _backgroundReady
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.06),
                      CombinedDateWidget(
                        key: ValueKey<int>(Globals.userHijriAdjustment),
                        cardColor: cardColor,
                        textColor: textColor,
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
                      SizedBox(height: screenHeight * 0.03),
                      FutureBuilder<Map<String, dynamic>>(
                        future: _surahFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            final data = snapshot.data!;
                            return DailyAyatCard(
                              currentSora: data['name'],
                              currentSoraEn: data['nameEn'],
                              currentSoraAr: data['nameAr'],
                              surahId: data['id'],
                              accentColor: accentColor,
                              cardColor: cardColor,
                              textColor: textColor,
                              ayatTextAr: data['ayatAr'] ??
                                  "ذلك الكتاب لا ريب فيه هدى للمتقين",
                              ayatTextEn: data['ayatEn'] ??
                                  "This is the Scripture whereof there is no doubt, a guidance unto those who ward off (evil)",
                              translationName: data['translationName'],
                              verseNumber: data['verseNumber'],
                            )
                                .animate()
                                .fadeIn(duration: 500.ms)
                                .slideY(begin: 0.2);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      _buildCategoryRow(isEnglish, [
                        _buildAnimatedCategory(
                            FontAwesomeIcons.bookQuran,
                            isEnglish ? "Quran" : "القرآن",
                            const QuranPage(),
                            700),
                        _buildAnimatedCategory(
                            FontAwesomeIcons.handsPraying,
                            isEnglish ? "Azkar" : "الأذكار",
                            const AzkarPage(),
                            800),
                        _buildAnimatedCategory(
                            FontAwesomeIcons.mosque,
                            isEnglish ? "Prayers" : "الصلاة",
                            const PrayerTimesPage(),
                            900),
                      ]),
                      SizedBox(height: screenHeight * 0.025),
                      _buildCategoryRow(isEnglish, [
                        _buildAnimatedCategory(
                            FontAwesomeIcons.kaaba,
                            isEnglish ? "Tasbeh" : "التسبيح",
                            const Counter(),
                            1000),
                        _buildAnimatedCategory(
                            FontAwesomeIcons.calendarDays,
                            isEnglish ? "Calendar" : "التقويم",
                            const EnhancedCalendar(),
                            1100),
                        _buildAnimatedCategory(
                            FontAwesomeIcons.bookOpen,
                            isEnglish ? "Ahadith" : "الأحاديث",
                            const HadithScreen(),
                            1200),
                      ]),
                      SizedBox(height: screenHeight * 0.04),
                    ],
                  ),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B0000)),
                ),
              ),
      ),
    );
  }

  Widget _buildAnimatedCategory(
      IconData icon, String label, Widget page, int durationMs) {
    return CategoryItem(
      icon: icon,
      label: label,
      page: page,
      primaryColor: primaryColor,
      cardColor: cardColor,
      textColor: textColor,
      backgroundColor: backgroundColor,
    ).animate().fadeIn(duration: durationMs.ms).slideY(begin: 0.3);
  }

  Widget _buildCategoryRow(bool isEnglish, List<Widget> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: isEnglish ? items : items.reversed.toList(),
    );
  }
}
