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

  final azkarKeys = const [
    'أذكار الصباح',
    'أذكار المساء',
    'أذكار بعد السلام من الصلاة المفروضة',
    'تسابيح',
    'أذكار النوم',
    'أذكار الاستيقاظ',
    'أدعية قرآنية',
    'أدعية الأنبياء',
  ];

  late final bool isEnglish;

  @override
  void initState() {
    super.initState();
    isEnglish = Globals.languageState ?? true;
    _tabController = TabController(length: azkarKeys.length, vsync: this);
    _initializeAzkarData();
    _setStatusBar(primaryColor);
  }

  Future<void> _initializeAzkarData() async {
    await AzkarService.initPrefs();
    final data = await AzkarService.loadAzkarData();
    azkarData = Future.value(data);
    if (mounted) setState(() {}); // Ensures future is ready
  }

  @override
  void dispose() {
    _tabController.dispose();
    _setStatusBar(Colors.transparent);
    super.dispose();
  }

  void _setStatusBar(Color color) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(screenWidth),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(double screenWidth) {
    return AppBar(
      backgroundColor: primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text(
        isEnglish ? "Azkar" : "الأذكار",
        style: GoogleFonts.getFont(
          isEnglish ? 'Roboto' : 'Tajawal',
          fontSize: screenWidth * 0.06,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Directionality(
          textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.6),
            indicatorColor: highlightColor,
            indicatorWeight: 3,
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            tabAlignment: TabAlignment.start,
            tabs: _buildTabs(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTabs() {
    final List<String> tabLabels = [
      isEnglish ? "Morning" : 'أذكار الصباح',
      isEnglish ? "Evening" : 'أذكار المساء',
      isEnglish ? "After Prayer" : 'أذكار بعد الصلاة',
      isEnglish ? "Praises" : 'تسابيح',
      isEnglish ? "Sleep" : 'أذكار النوم',
      isEnglish ? "Wake Up" : 'أذكار الاستيقاظ',
      isEnglish ? "Quranic" : 'أدعية قرآنية',
      isEnglish ? "Prophets" : 'أدعية الأنبياء',
    ];

    return tabLabels.map((text) {
      return Padding(
        padding: EdgeInsets.only(
          right: isEnglish ? 0 : 8,
          left: isEnglish ? 8 : 0,
        ),
        child: Text(
          text,
          style: GoogleFonts.getFont(
            isEnglish ? 'Roboto' : 'Tajawal',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildContent() {
    if (azkarData == null) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    return FutureBuilder<Map<String, List<Azkar>>>(
      future: azkarData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
        }

        if (snapshot.hasError) {
          return Message(
            text: isEnglish ? 'Error loading azkar' : 'خطأ في تحميل الأذكار',
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Message(
            text: isEnglish ? 'No azkar available' : 'لا توجد أذكار متاحة',
          );
        }

        final data = snapshot.data!;
        return TabBarView(
          controller: _tabController,
          children: azkarKeys.map((key) {
            return AzkarList.buildAzkarList(key, data[key] ?? []);
          }).toList(),
        );
      },
    );
  }
}
