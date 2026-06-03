import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/widgets/app_them.dart';

class TajweedMarksPage extends StatefulWidget {
  const TajweedMarksPage({super.key});

  @override
  State<TajweedMarksPage> createState() => _TajweedMarksPageState();
}

class _TajweedMarksPageState extends State<TajweedMarksPage> {
  Map<String, dynamic> tajweedData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTajweedData();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: primaryColor),
    );
  }

  Future<void> _loadTajweedData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/tajweed.json');
      final data = json.decode(response);
      setState(() {
        tajweedData = data['tajweed_marks'] ?? {};
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool get isEnglish => Globals.languageState ?? true;
  String get fontFamily => isEnglish ? 'Roboto' : 'Tajawal';

  String _getCategoryTitle(String category) {
    final Map<String, String> titles = {
      'waqf': isEnglish ? 'Waqf (Stopping) Marks' : 'علامات الوقف',
      'tajweed': isEnglish ? 'Tajweed Rules' : 'أحكام التجويد',
      'special': isEnglish ? 'Special Symbols' : 'رموز خاصة',
      'harakat': isEnglish ? 'Harakat (Vowel Marks)' : 'الحركات',
      'special_rules': isEnglish ? 'Special Rules' : 'أحكام خاصة',
    };
    return titles[category] ?? category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          isEnglish ? 'Tajweed Marks' : 'علامات التجويد',
          style: GoogleFonts.getFont(
            fontFamily,
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : Directionality(
                textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: tajweedData.length,
                  itemBuilder: (context, index) {
                    final category = tajweedData.keys.elementAt(index);
                    final items = tajweedData[category] as List<dynamic>? ?? [];
                    return _buildCategorySection(category, items);
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildCategorySection(String category, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Text(
            _getCategoryTitle(category),
            style: GoogleFonts.getFont(
              fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
        ...items.map((item) => _buildTajweedCard(item)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTajweedCard(dynamic item) {
    final symbol = item['symbol'] ?? '';
    final name = item['name'] ?? '';
    final description = item['description'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F5EF),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  symbol,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 28,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.getFont(
                      fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.getFont(
                      fontFamily,
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
