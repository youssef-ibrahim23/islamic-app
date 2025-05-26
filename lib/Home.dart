import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:islamic_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importing other pages
import 'AhadithPage.dart';
import 'Counter.dart';
import 'QuranP.dart';
import 'SurahP.dart';
import 'duaaP.dart';
import 'hijriDate.dart';
import 'FavoritesPage.dart';
import 'PayerTimesP.dart';

// Declare a global RouteObserver
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Map<String, String> HijiriarabicMonths = {"Sha'aban": "شعبان"};
Map<String, String> GregorianabicMonths = {"February": "فبراير"};

String? acountName;
String currentSora = "Al-Fatiha";
int SurahId = 1;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  @override
  void initState() {
    super.initState();
    loadLastSurah();
  }

  Future<void> loadLastSurah() async {
    final prefs = await SharedPreferences.getInstance();

    final lastSurahId = prefs.getInt('lastSurahId') ?? 1;
    final lastSurahName = prefs.getString('lastSurahName') ?? "Al-Fatiha";
    final lastSurahArabicName =
        prefs.getString("lastSurahArabicName") ?? "الفاتحة";

    setState(() {
      print(languageState);
      currentSora = languageState! ? lastSurahName : lastSurahArabicName;
      SurahId = lastSurahId;
      print("Loaded last Surah: $currentSora (ID: $SurahId)");
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    loadLastSurah();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> monthNamesMap = {
      'January': 'يناير',
      'February': 'فبراير',
      'March': 'مارس',
      'April': 'أبريل',
      'May': 'مايو',
      'June': 'يونيو',
      'July': 'يوليو',
      'August': 'أغسطس',
      'September': 'سبتمبر',
      'October': 'أكتوبر',
      'November': 'نوفمبر',
      'December': 'ديسمبر',
    };

    Map<String, String> dayNamesMap = {
      'Monday': 'الإثنين',
      'Tuesday': 'الثلاثاء',
      'Wednesday': 'الأربعاء',
      'Thursday': 'الخميس',
      'Friday': 'الجمعة',
      'Saturday': 'السبت',
      'Sunday': 'الأحد',
    };

    String toArabicNumber(String input) {
      Map<String, String> arabicNumerals = {
        '0': '٠',
        '1': '١',
        '2': '٢',
        '3': '٣',
        '4': '٤',
        '5': '٥',
        '6': '٦',
        '7': '٧',
        '8': '٨',
        '9': '٩',
      };

      return input.split('').map((char) {
        return arabicNumerals[char] ??
            char; // Replace digits, or keep character if not a digit
      }).join('');
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    String timeStatus = DateFormat("hh:mm a").format(DateTime.now());
    String currentDayName = DateFormat("EEEE").format(DateTime.now());
    int currentDay = DateTime.now().day;
    String currentMonth = DateFormat("MMMM").format(DateTime.now());
    String currentYear = DateFormat("y").format(DateTime.now());
    String currentDate = languageState!
        ? DateFormat('EEEE, MMMM d, y').format(DateTime.now())
        : "  ${dayNamesMap[currentDayName]} ,  ${monthNamesMap[currentMonth]} $currentDay ,  ${toArabicNumber(currentYear)}  ";

    languageState!
        ? HijriCalendar.setLocal("en")
        : HijriCalendar.setLocal("ar");

    HijriCalendar hijriDate = HijriCalendar.now();
    String currentHijriDate =
        '${HijriCalendar.fromDate(DateTime.now()).toFormat("dd MMMM yyyy")}';

    return Scaffold(
      backgroundColor: const Color(0xFF0b3d27),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: const Color(0xFF0b3d27),
        toolbarHeight: screenHeight * 0.1,
        backgroundColor: const Color(0xFF0b3d27),
        title: languageState!
            ? Column(
                children: [
                  SizedBox(height: screenHeight * 0.014),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.01,
                      ),
                      Text(
                        // ignore: unnecessary_string_interpolations
                        languageState!
                            ? "Good ${(timeStatus.contains("PM")) ? "Evening" : "Morning"}"
                            : "${(timeStatus.contains("PM")) ? "مساء الخير" : "صباح الخير"}",
                        style: TextStyle(
                            fontFamily: languageState! ? 'cursive' : 'lateef',
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.01,
                      ),
                      Text(
                        acountName ??
                            "${languageState! ? "No Name" : "لا يوجد اسم"}",
                        style: TextStyle(
                          fontFamily: languageState! ? 'serif' : 'Lateef',
                          wordSpacing: 5,
                          color: Colors.white,
                          fontSize: screenWidth * 0.055,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FavoritesPage()),
                      );
                    },
                  ),
                  SizedBox(
                    width: screenWidth * 0.48,
                  ),
                  Column(
                    children: [
                      SizedBox(height: screenHeight * 0.014),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            // ignore: unnecessary_string_interpolations
                            languageState!
                                ? "Good ${(timeStatus.contains("PM")) ? "Evening" : "Morning"}"
                                : "${(timeStatus.contains("PM")) ? "مساء الخير" : "صباح الخير"}",
                            style: TextStyle(
                                fontFamily:
                                    languageState! ? 'cursive' : 'lateef',
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Row(
                        mainAxisAlignment: languageState!
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                        children: [
                          Container(
                            
                            alignment: Alignment.center,
                            width: screenWidth * 0.3,
                            child: Text(
                              acountName ??
                              "${languageState! ? "No Name" : "لا يوجد اسم"}",
                              style: TextStyle(
                                fontFamily: languageState! ? 'serif' : 'Lateef',
                                wordSpacing: 5,
                                color: Colors.white,
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
        actions: [
          languageState!
              ? Container(
                  width: screenWidth * 0.14,
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FavoritesPage()));
                      },
                      icon: Icon(
                        Icons.favorite,
                        color: Colors.white,
                      )),
                )
              : SizedBox()
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.035),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  currentDate,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: languageState!
                        ? screenWidth * 0.04
                        : screenWidth * 0.053,
                    fontFamily: languageState! ? 'cursive' : 'lateef',
                  ),
                ),
                Text(
                  currentHijriDate,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: languageState!
                          ? screenWidth * 0.04
                          : screenWidth * 0.055,
                      fontFamily: languageState! ? 'cursive' : 'lateef'),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.035),
            Container(
              height: screenHeight * 0.23,
              width: screenWidth * 0.92,
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 4, 46, 28),
                    blurRadius: 3,
                    spreadRadius: 1,
                  )
                ],
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF0b3d27),
              ),
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: screenWidth * 0.4,
                    child: const Icon(
                      FontAwesomeIcons.moon,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: languageState!
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          children: [
                            Text(
                              languageState! ? "Daily Ayat" : "أيات يومية",
                              style: TextStyle(
                                  fontFamily:
                                      languageState! ? 'cursive' : 'lateef',
                                  color: Colors.white,
                                  fontSize: languageState!
                                      ? screenWidth * 0.048
                                      : screenWidth * 0.075),
                            ),
                            SizedBox(
                              width: screenWidth * 0.04,
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: languageState!
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          children: [
                            Text(
                              textAlign: languageState!
                                  ? TextAlign.start
                                  : TextAlign.end,
                              languageState!
                                  ? "This is the Scripture\n whereof there is no\n doubt, a guidance unto\n those who ward off(evil)"
                                  : "ذلك الكتاب\n لا ريب فيه هدى للمتقين",
                              style: TextStyle(
                                  fontSize: languageState!
                                      ? screenWidth * 0.035
                                      : screenWidth * 0.045,
                                  color: Color.fromARGB(255, 158, 158, 158),
                                  fontFamily:
                                      languageState! ? 'serif' : 'lateef'),
                            ),
                            languageState!
                                ? SizedBox()
                                : SizedBox(
                                    width: screenWidth * 0.05,
                                  )
                          ],
                        ),
                        languageState!
                            ? Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SurahDetailPage(
                                              currentSora,
                                              SurahId,
                                              currentSora),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      currentSora,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: languageState!
                                            ? 'cursive'
                                            : 'lateef',
                                        fontSize: screenWidth * 0.04,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SurahDetailPage(currentSora,
                                                    SurahId, currentSora),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.navigate_next,
                                        color: Colors.white,
                                      )),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SurahDetailPage(currentSora,
                                                    SurahId, currentSora),
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.arrow_back_ios_new_outlined,
                                        color: Colors.white,
                                        size: screenWidth * 0.05,
                                      )),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SurahDetailPage(
                                              currentSora,
                                              SurahId,
                                              currentSora),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      currentSora,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: languageState!
                                              ? 'cursive'
                                              : 'lateef',
                                          fontSize: screenWidth * 0.07),
                                    ),
                                  ),
                                  SizedBox(
                                    width: screenWidth * 0.035,
                                  ),
                                ],
                              )
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: screenHeight * 0.025,
            ),
            Row(
              mainAxisAlignment: languageState!
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                languageState!
                    ? SizedBox(
                        width: screenWidth * 0.06,
                      )
                    : SizedBox(),
                Text(
                  languageState! ? "Categories" : "الفئات",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: languageState!
                          ? screenWidth * 0.07
                          : screenWidth * 0.08,
                      fontFamily: languageState! ? 'Cursive' : 'lateef'),
                ),
                languageState!
                    ? SizedBox()
                    : SizedBox(
                        width: screenWidth * 0.06,
                      )
              ],
            ),
            SizedBox(
              height: screenHeight * 0.025,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Category(
                      Icons.menu_book_sharp,
                      languageState! ? "Al Quran" : "القرأن",
                      screenWidth,
                      screenHeight,
                      const QuranPage()),
                  SizedBox(
                    width: screenWidth * 0.06,
                  ),
                  Category(Icons.notes, languageState! ? "Azkar" : "الأذكار",
                      screenWidth, screenHeight, const AzkarPage()),
                  SizedBox(
                    width: screenWidth * 0.06,
                  ),
                  Category(
                      FontAwesomeIcons.mosque,
                      languageState! ? "Prayers" : "الصلاة",
                      screenWidth,
                      screenHeight,
                      const PrayerTimesPage()),
                ],
              ),
            ),
            SizedBox(
              height: screenHeight * 0.03,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Category(
                      Icons.add_outlined,
                      languageState! ? "Counter" : "التسبيح",
                      screenWidth,
                      screenHeight,
                      const Counter()),
                  SizedBox(
                    width: screenWidth * 0.06,
                  ),
                  Category(
                      Icons.calendar_month,
                      languageState! ? "Calendar" : "التقويم",
                      screenWidth,
                      screenHeight,
                      const Calendar_p()),
                  SizedBox(
                    width: screenWidth * 0.06,
                  ),
                  Category(
                      FontAwesomeIcons.placeOfWorship,
                      languageState! ? "Ahadith" : "الأحاديث",
                      screenWidth,
                      screenHeight,
                      const HadithScreen()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget Category(IconData icon, String Label, double screenWidth,
      double screenHeight, Widget navigatTo) {
    return Column(
      children: [
        Container(
          width: screenWidth * 0.27,
          height: screenHeight * 0.1,
          decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(255, 4, 46, 28),
                  blurRadius: 1,
                  spreadRadius: 1,
                )
              ],
              color: const Color(0xFF0b3d27),
              borderRadius: BorderRadius.circular(15),
              border:
                  Border.all(color: Color.fromARGB(255, 4, 46, 28), width: 1)),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => navigatTo));
            },
            icon: Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: screenHeight * 0.02,
        ),
        Text(
          Label,
          style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w500,
              fontFamily: languageState! ? 'cursive' : 'lateef'),
        ),
      ],
    );
  }
}
