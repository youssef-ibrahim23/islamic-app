import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:islamic_app/Services/Ahadith.dart';
import 'package:islamic_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  _HadithScreenState createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  String ReferenceUrl = "https://sunnah.com/search?q=Hadith+Abu+Dawud";

  List<Hadith> _hadiths = [];
  bool _isLoading = false;

  int? currentPage = 1;

  @override
  void initState() {
    super.initState();
    loadCurrentPage(); // Call to load the page when the screen is initialized
  }

  Future<void> loadCurrentPage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    currentPage = await sharedPreferences.getInt("Page") ??
        1; // If no page saved, default to page 1

    _fetchHadiths(); // Now we fetch the Hadiths after loading the page number
  }

  Future<void> _fetchHadiths() async {
    setState(() {
      _isLoading = true;
    });

    final hadiths = await HadithApi.fetchHadiths(currentPage!);

    setState(() {
      _hadiths = hadiths;
      _isLoading = false;
    });

    print(_hadiths);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AwesomeDialog(
            context: context,
            dialogBackgroundColor: Color(0xFF0b3d27),
            dialogType: DialogType.info,
            body: Column(
              children: [
                Text(
                  languageState! ? 'About Abu-Dawud' : 'عن أبي داود',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: languageState! ? 'cursive' : 'Lateef',
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            btnCancelText: languageState! ? "Renew" : 'تجديد',
            btnCancelColor: Colors.blue,
            btnOkText: languageState! ? "Reference Website" : 'موقع مرجعي',
            btnOkOnPress: () async {
              Uri url = Uri.parse(ReferenceUrl);
              await launchUrl(url, mode: LaunchMode.externalApplication);
            },
            btnCancelOnPress: () async {
              // Increment currentPage and save it
              setState(() {
                currentPage = currentPage! + 1;
              });

              SharedPreferences sharedPreferences =
                  await SharedPreferences.getInstance();
              await sharedPreferences.setInt("Page", currentPage!);

              // Fetch the Hadiths for the updated page
              _fetchHadiths();
            },
          ).show();
        },
        child: Icon(Icons.web, color: Colors.black),
      ),
      backgroundColor: const Color(0xFF0b3d27),
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.1,
        surfaceTintColor: const Color(0xFF0b3d27),
        shadowColor: const Color(0xFF0b3d27),
        foregroundColor: const Color(0xFF0b3d27),
        backgroundColor: const Color(0xFF0b3d27),
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_backspace_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          languageState! ? 'Ahadith' : 'الاحاديث',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.08,
            fontFamily: languageState! ? 'Cursive' : 'Lateef',
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.greenAccent,
              ),
            )
          : ListView.builder(
              itemCount: _hadiths.length,
              itemBuilder: (context, index) {
                final hadith = _hadiths[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hadith.arabicText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(
                        color: Colors.white,
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
