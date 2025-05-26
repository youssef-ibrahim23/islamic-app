import 'package:flutter/material.dart';
import 'package:islamic_app/Home.dart';
import 'package:islamic_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Services/Quran.dart';
import 'BottomBar.dart';
import 'SurahP.dart';

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

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  final QuranAPIService _apiService = QuranAPIService();
  List<dynamic>? surahs;
  List<dynamic>? filteredSurahs;
  Map<int, String> favoriteSurahIds =
      {}; // Map to store ID and names (simple|arabic)
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSurahList();
    loadFavorites();
    _searchController.addListener(_filterSurahs);
  }

  Future<void> saveLastSurah(int id, String name, String arabicName) async {
    
    final prefs = await SharedPreferences.getInstance();

    
    
    await prefs.setInt('lastSurahId', id);
    await prefs.setString('lastSurahName', name);
    await prefs.setString('lastSurahArabicName', arabicName);

    // Set the current Surah name based on language state
    setState(() {
      currentSora = languageState! ? name : arabicName;
    });
    
    print("Saved last Surah: $name (ID: $id)");
  }

  // Fetch the Surah List
  Future<void> fetchSurahList() async {
    try {
      final data = await _apiService.getSurahList();
      setState(() {
        surahs = data;
        filteredSurahs = data;
      });
    } catch (e) {
      print("Error fetching Surah list: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              languageState! ? "Failed to load Surahs" : "فشل تحميل السور"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Load favorites from SharedPreferences
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];

    setState(() {
      favoriteSurahIds = {
        for (var entry in favorites)
          int.parse(entry.split(':')[0]):
              entry.split(':')[1] // ID -> simpleName|arabicName
      };
    });
  }



  // Toggle favorite Surah
  Future<void> toggleFavorite(
      int surahId, String surahNameSimple, String surahNameArabic) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (favoriteSurahIds.containsKey(surahId)) {
        favoriteSurahIds.remove(surahId);
      } else {
        // Store both names separated by a delimiter (|) for simple and arabic names
        favoriteSurahIds[surahId] = '$surahNameSimple | $surahNameArabic';
      }
    });

    // Save to SharedPreferences
    prefs.setStringList(
      'favorites',
      favoriteSurahIds.entries
          .map((entry) => '${entry.key}:${entry.value}')
          .toList(),
    );
  }

  // Filter surahs based on search input
  void _filterSurahs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredSurahs = surahs?.where((surah) {
        final name =
            languageState! ? surah['name_simple'] : surah['name_arabic'];
        return name.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Show the search dialog
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0b3d27),
          title: Center(
            child: Text(
              languageState! ? "Search" : "بحث",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontFamily: languageState! ? 'Cursive' : 'Lateef',
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          content: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: languageState! ? "Enter Surah Name" : "أدخل اسم السورة",
              hintStyle: TextStyle(
                color: Colors.white,
                fontFamily: languageState! ? 'Cursive' : 'Lateef',
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.greenAccent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _searchController.clear();
                Navigator.pop(context);
              },
              child: Text(
                languageState! ? "Close" : "الغاء",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: languageState! ? 'Cursive' : 'Lateef',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                languageState! ? "Search" : "بحث",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: languageState! ? 'Cursive' : 'Lateef',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00796B),
        onPressed: _showSearchDialog,
        child: const Icon(Icons.search, color: Colors.white),
      ),
      backgroundColor: const Color(0xFF0b3d27),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0b3d27),
        shadowColor: const Color(0xFF0b3d27),
        foregroundColor: const Color(0xFF0b3d27),
        surfaceTintColor: const Color(0xFF0b3d27),
        title: Text(
          languageState! ? "Al Quran" : "القرآن",
          style: TextStyle(
            fontFamily: languageState! ? 'Cursive' : 'Lateef',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.08,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(Icons.keyboard_backspace_rounded, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BottomBar()),
            );
          },
        ),
      ),
      body: filteredSurahs == null
          ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            )
          : filteredSurahs!.isEmpty
              ? Center(
                  child: Text(
                    languageState! ? "No Surahs found" : "لا توجد سور",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: languageState! ? 'Cursive' : 'Lateef',
                    ),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  itemCount: filteredSurahs!.length,
                  itemBuilder: (context, index) {
                    final surah = filteredSurahs![index];
                    final isFavorite =
                        favoriteSurahIds.containsKey(surah['id']);
                    final surahNames = isFavorite
                        ? favoriteSurahIds[surah['id']]!.split('|')
                        : [surah['name_simple'], surah['name_arabic']];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: const Color(0xFF0b3d27),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 5,
                      child: languageState! ? ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF00796B),
                          child: Text(
                            surah['id'].toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          languageState!
                              ? surahNames[0]
                              : surahNames[1], // Show name based on language
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: languageState! ? '' : 'Lateef',
                          ),
                        ),
                        subtitle: Text(
                          (surah['revelation_place'] == "makkah")
                              ? languageState!
                                  ? "Makkah"
                                  : "مكة"
                              : languageState!
                                  ? "El Madinah"
                                  : "المدينة",
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: languageState! ? '' : 'Lateef',
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.white,
                          ),
                          onPressed: () => toggleFavorite(
                            surah['id'],
                            surah['name_simple'],
                            surah['name_arabic'],
                          ),
                        ),
                        onTap: () {
                          saveLastSurah(surah['id'], surah['name_simple'],
                              surah['name_arabic']);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SurahDetailPage(
                                surah['name_simple'],
                                surah['id'],
                                surah['name_arabic'],
                              ),
                            ),
                          );
                        },
                      ) : ListTile(
                        leading: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.white,
                          ),
                          onPressed: () => toggleFavorite(
                            surah['id'],
                            surah['name_simple'],
                            surah['name_arabic'],
                          ),
                        ),
                        title: Text(
                          textAlign: TextAlign.end,
                          languageState!
                              ? surahNames[0]
                              : surahNames[1], // Show name based on language
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: languageState! ? '' : 'Lateef',
                          ),
                        ),
                        subtitle: 
                        
                        Text(
                          textAlign : TextAlign.end,
                          (surah['revelation_place'] == "makkah")
                              ? languageState!
                                  ? "Makkah"
                                  : "مكة"
                              : languageState!
                                  ? "El Madinah"
                                  : "المدينة",
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: languageState! ? '' : 'Lateef',
                          ),
                        ),
                        trailing: CircleAvatar(
                          backgroundColor: const Color(0xFF00796B),
                          child: Text(
                            toArabicNumber(surah['id'].toString()),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ), 
                        onTap: () {
                          saveLastSurah(surah['id'], surah['name_simple'],
                              surah['name_arabic']);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SurahDetailPage(
                                surah['name_simple'],
                                surah['id'],
                                surah['name_arabic'],
                              ),
                            ),
                          );
                        },
                      )
                    );
                  },
                ),
    );
  }
}
