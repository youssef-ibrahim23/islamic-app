import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/models/Azkar.dart';
import 'package:islamic_app/services/azkar_services.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/azkar/azkar_list.dart';
import 'package:islamic_app/widgets/azkar/message.dart';

class AzkarPage extends StatefulWidget {
  const AzkarPage({super.key});

  @override
  State<AzkarPage> createState() => _AzkarPageState();
}

class _AzkarPageState extends State<AzkarPage> with TickerProviderStateMixin {
  late TabController _tabController;
  Future<Map<String, List<Azkar>>>? azkarData;

  final List<String> azkarKeys = [
    'أذكار الصباح',
    'أذكار المساء',
    'أذكار بعد السلام من الصلاة المفروضة',
    'تسابيح',
    'أذكار النوم',
    'أذكار الاستيقاظ',
    'أدعية قرآنية',
    'أدعية الأنبياء',
  ];

  List<Tab> get myTabs => <Tab>[
        Tab(text: Globals.languageState! ? "Morning" : 'أذكار الصباح'),
        Tab(text: Globals.languageState! ? "Evening" : 'أذكار المساء'),
        Tab(text: Globals.languageState! ? "After Prayer" : 'أذكار بعد الصلاة'),
        Tab(text: Globals.languageState! ? "Praises" : 'تسابيح'),
        Tab(text: Globals.languageState! ? "Sleep" : 'أذكار النوم'),
        Tab(text: Globals.languageState! ? "Wake Up" : 'أذكار الاستيقاظ'),
        Tab(text: Globals.languageState! ? "Quranic" : 'أدعية قرآنية'),
        Tab(text: Globals.languageState! ? "Prophets" : 'أدعية الأنبياء'),
      ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
    _initialize();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: primaryColor,
    ));
  }

  Future<void> _initialize() async {
    await AzkarService.initPrefs();
    final data = await AzkarService.loadAzkarData();
    setState(() {
      azkarData = Future.value(data); // So it won't rebuild repeatedly
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          Globals.languageState! ? "Azkar" : "الأذكار",
          style: GoogleFonts.getFont(
            Globals.languageState! ? 'Roboto' : 'Tajawal',
            fontSize: screenWidth * 0.06,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: primaryColor,
            width: double.infinity,
            child: Directionality(
              textDirection: Globals.languageState!
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.6),
                indicatorColor: highlightColor,
                indicatorWeight: 3,
                padding: EdgeInsets.zero,
                labelPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                tabAlignment: TabAlignment.start,
                tabs: myTabs.map((tab) {
                  return Container(
                    padding: EdgeInsets.only(
                      right: Globals.languageState! ? 0 : 8,
                      left: Globals.languageState! ? 8 : 0,
                    ),
                    child: Text(
                      tab.text!,
                      style: GoogleFonts.getFont(
                        Globals.languageState! ? 'Roboto' : 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: azkarData == null
              ? const Center(
                  child: CircularProgressIndicator(color: primaryColor))
              : FutureBuilder<Map<String, List<Azkar>>>(
                  future: azkarData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: primaryColor));
                    } else if (snapshot.hasError) {
                      return Message(
                        text: Globals.languageState!
                            ? 'Error loading azkar'
                            : 'خطأ في تحميل الأذكار',
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Message(
                        text: Globals.languageState!
                            ? 'No azkar available'
                            : 'لا توجد أذكار متاحة',
                      );
                    } else {
                      final data = snapshot.data!;
                      return TabBarView(
                        controller: _tabController,
                        children: azkarKeys.map((key) {
                          return AzkarList.buildAzkarList(data[key] ?? []);
                        }).toList(),
                      );
                    }
                  },
                ),
        ),
      ),
    );
  }
}
