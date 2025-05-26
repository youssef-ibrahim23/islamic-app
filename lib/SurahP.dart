import 'package:flutter/material.dart';
import 'package:islamic_app/QuranP.dart';
import 'package:islamic_app/Services/Quran.dart';
import 'package:islamic_app/main.dart';

class SurahDetailPage extends StatefulWidget {
  final int surahId;
  final String surahName;
  final String arabicName;

  const SurahDetailPage(this.surahName, this.surahId, this.arabicName,
      {super.key});

  @override
  _SurahDetailPageState createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  final QuranAPIService _apiService = QuranAPIService();
  List<dynamic>? verses;
  bool isLoading = true;

  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchVerses();
  }

  Future<void> fetchVerses() async {
    try {
      final data = await _apiService.getVersesForSurah(widget.surahId);
      setState(() {
        verses = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching verses: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.keyboard_backspace_rounded,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        title: Text(
          languageState!
              ? widget.surahName
              : widget
                  .arabicName, // Display the correct Surah name based on the language
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'cursive',
            fontSize: screenWidth * 0.08,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: const Color(0xFF0b3d27),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0b3d27),
              ),
            )
          : verses == null
              ? Center(
                  child: Text(
                    errorMessage.isEmpty ? "No verses found" : errorMessage,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                    ),
                  ),
                )
              : Column(
                children: [
                  SizedBox(height:screenHeight*0.03 ,),
                  Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "بسم الله الرحمن الرحيم",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'UthmanicScriptHafs',
                                  ),
                                  textAlign: TextAlign.right, // Align to the right
                                ),
                                
                              ],
                            ),
                          ),
                        ),
                  Expanded(
                    child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: verses!.length,
                        itemBuilder: (context, index) {
                          final verse = verses![index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    verse['text_uthmani'],
                                    
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'UthmanicScriptHafs',
                                    ),
                                    textAlign: TextAlign.right, // Align to the right
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "الأية ${toArabicNumber((index + 1).toString())}",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ),
                ],
              ),
    );
  }
}
