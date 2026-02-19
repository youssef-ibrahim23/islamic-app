// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/hadith_services.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/hadiths/hadith_card.dart';
import 'package:islamic_app/widgets/hadiths/info_dialog.dart';
import 'package:islamic_app/widgets/hadiths/navigation_buttons.dart';
import 'package:islamic_app/widgets/hadiths/range_header.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  _HadithScreenState createState() => _HadithScreenState();
}

final ScrollController _scrollController = ScrollController();

class _HadithScreenState extends State<HadithScreen> {
  @override
  void initState() {
    super.initState();
    HadithService.loadInitialRange(_setLoading, _refreshUI);
  }

  void _setLoading(bool loading) {
    setState(() => Globals.hadithIsLoading = loading);
  }

  void _refreshUI() {
    setState(() {});
    _scrollController.jumpTo(0); // Optional
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = Globals.languageState!;
    final size = MediaQuery.of(context).size;
    final bool isPortrait = size.height > size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => InfoDialog.showInfoDialog(context),
        backgroundColor: primaryColor,
        elevation: 4,
        child: const Icon(Icons.info_outline, color: Colors.white),
      ),
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        title: Text(
          Globals.collectionName,
          style: TextStyle(
            color: Colors.white,
            fontSize: isPortrait ? size.width * 0.06 : size.height * 0.06,
            fontWeight: FontWeight.bold,
            fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
          ),
        ),
      ),
      body: Directionality(
          textDirection: TextDirection.rtl,
          child: _buildBody(isEnglish, size, isPortrait)),
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.rtl,
        child: NavigationButtons(
          isEnglish: isEnglish,
          onHadithsLoaded: _refreshUI,
        ),
      ),
    );
  }

  Widget _buildBody(bool isEnglish, Size size, bool isPortrait) {
    if (Globals.hadithIsLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
          strokeWidth: 3,
        ),
      );
    }

    if (Globals.hadiths.isEmpty) {
      return Center(
        child: Text(
          isEnglish
              ? 'No hadiths in this range'
              : 'لا توجد أحاديث في هذا النطاق',
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: isPortrait ? size.width * 0.05 : size.height * 0.05,
            fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
        image: AssetImage('assets/images/background.jpg'),
        fit: BoxFit.cover,
        opacity: 0.9,
      )),
      child: Column(
        children: [
          RangeHeader(
            isEnglish: isEnglish,
            isPortrait: isPortrait,
          ),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.all(isPortrait ? 12 : 24),
              itemCount: Globals.hadiths.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final hadith = Globals.hadiths[index];
                return HadithCard(
                  hadith: hadith,
                  isEnglish: isEnglish,
                  isPortrait: isPortrait,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
