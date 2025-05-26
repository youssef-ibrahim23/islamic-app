import 'package:flutter/material.dart';
import 'package:islamic_app/Model/Azkar.dart';
import 'package:islamic_app/Services/Azkar.dart';
import 'package:islamic_app/main.dart';

class AzkarPage extends StatefulWidget {
  const AzkarPage({super.key});

  @override
  State<AzkarPage> createState() => _AzkarPageState();
}

class _AzkarPageState extends State<AzkarPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late Future<ApiModel?> apiData;
  final ApiService service = ApiService();

  List<Tab> myTabs = <Tab>[
    Tab(text: languageState! ? "Morning remembrance" : 'أذكار الصباح'),
    Tab(text: languageState! ? "Evening remembrances" : 'أذكار المساء'),
    Tab(text: languageState! ? "Remembrances after peace" : 'أذكار بعد السلام'),
    Tab(text: languageState! ? "Praises" : 'تسابيح'),
    Tab(text: languageState! ? "Remembrance of sleep" : 'أذكار النوم'),
    Tab(text: languageState! ? "Remembrances of waking up" : 'أذكار الاستيقاظ'),
  ];
  List<dynamic> azkarAsSabah = [
    [
      {
        "category": "أذكار الصباح",
        "count": "1",
        "description": "",
        "reference": "",
        "content":
            "أَصْـبَحْنا وَأَصْـبَحَ المُـلْكُ لله وَالحَمدُ لله ، لا إلهَ إلاّ اللّهُ وَحدَهُ لا شَريكَ لهُ، لهُ المُـلكُ ولهُ الحَمْـد، وهُوَ على كلّ شَيءٍ قدير"
      },
      {
        "category": "أذكار الصباح",
        "count": "1",
        "description":
            "من قالها موقنا بها حين يمسى ومات من ليلته دخل الجنة وكذلك حين يصبح.",
        "reference": "",
        "content":
            "اللّهـمَّ أَنْتَ رَبِّـي لا إلهَ إلاّ أَنْتَ ، خَلَقْتَنـي وَأَنا عَبْـدُك ، وَأَنا عَلـى عَهْـدِكَ وَوَعْـدِكَ ما اسْتَـطَعْـت ، أَعـوذُبِكَ مِنْ شَـرِّ ما صَنَـعْت ، أَبـوءُ لَـكَ بِنِعْـمَتِـكَ عَلَـيَّ وَأَبـوءُ بِذَنْـبي فَاغْفـِرْ لي فَإِنَّـهُ لا يَغْـفِرُ الذُّنـوبَ إِلاّ أَنْتَ ."
      },
      {
        "category": "أذكار الصباح",
        "count": "3",
        "description":
            "من قالها حين يصبح وحين يمسى كان حقا على الله أن يرضيه يوم القيامة.",
        "reference": "",
        "content":
            "رَضيـتُ بِاللهِ رَبَّـاً وَبِالإسْلامِ ديـناً وَبِمُحَـمَّدٍ صلى الله عليه وسلم نَبِيّـاً. "
      },
      {
        "category": "أذكار الصباح",
        "count": "4",
        "description": "من قالها أعتقه الله من النار.",
        "reference": "",
        "content":
            "اللّهُـمَّ إِنِّـي أَصْبَـحْتُ أُشْـهِدُك ، وَأُشْـهِدُ حَمَلَـةَ عَـرْشِـك ، وَمَلَائِكَتَكَ ، وَجَمـيعَ خَلْـقِك ، أَنَّـكَ أَنْـتَ اللهُ لا إلهَ إلاّ أَنْـتَ وَحْـدَكَ لا شَريكَ لَـك ، وَأَنَّ ُ مُحَمّـداً عَبْـدُكَ وَرَسـولُـك."
      }
    ],
    {
      "category": "أذكار الصباح",
      "count": "7",
      "description": "من قالها كفاه الله ما أهمه من أمر الدنيا والأخرة.",
      "reference": "",
      "content":
          "حَسْبِـيَ اللَّهُ لا إلهَ إلاّ هُوَ عَلَـيهِ تَوَكَّـلتُ وَهُوَ رَبُّ العَرْشِ العَظـيم."
    },
    {
      "category": "أذكار الصباح",
      "count": "3",
      "description": "لم يضره من الله شيء.",
      "reference": "",
      "content":
          "بِسـمِ اللهِ الذي لا يَضُـرُّ مَعَ اسمِـهِ شَيءٌ في الأرْضِ وَلا في السّمـاءِ وَهـوَ السّمـيعُ العَلـيم."
    },
    {
      "category": "أذكار الصباح",
      "count": "1",
      "description": "",
      "reference": "",
      "content":
          "اللّهُـمَّ بِكَ أَصْـبَحْنا وَبِكَ أَمْسَـينا ، وَبِكَ نَحْـيا وَبِكَ نَمُـوتُ وَإِلَـيْكَ النُّـشُور."
    },
    {
      "category": "أذكار الصباح",
      "count": "1",
      "description": "",
      "reference": "",
      "content":
          "أَصْبَـحْـنا عَلَى فِطْرَةِ الإسْلاَمِ، وَعَلَى كَلِمَةِ الإِخْلاَصِ، وَعَلَى دِينِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ، وَعَلَى مِلَّةِ أَبِينَا إبْرَاهِيمَ حَنِيفاً مُسْلِماً وَمَا كَانَ مِنَ المُشْرِكِينَ."
    },
    {
      "category": "أذكار الصباح",
      "count": "3",
      "description": "",
      "reference": "",
      "content":
          "سُبْحـانَ اللهِ وَبِحَمْـدِهِ عَدَدَ خَلْـقِه ، وَرِضـا نَفْسِـه ، وَزِنَـةَ عَـرْشِـه ، وَمِـدادَ كَلِمـاتِـه."
    },
    {
      "category": "أذكار الصباح",
      "count": "3",
      "description": "",
      "reference": "",
      "content":
          "اللّهُـمَّ عافِـني في بَدَنـي ، اللّهُـمَّ عافِـني في سَمْـعي ، اللّهُـمَّ عافِـني في بَصَـري ، لا إلهَ إلاّ أَنْـتَ."
    },
    {
      "category": "أذكار الصباح",
      "count": "3",
      "description": "",
      "reference": "",
      "content":
          "اللّهُـمَّ إِنّـي أَعـوذُ بِكَ مِنَ الْكُـفر ، وَالفَـقْر ، وَأَعـوذُ بِكَ مِنْ عَذابِ القَـبْر ، لا إلهَ إلاّ أَنْـتَ."
    },
    {
      "category": "أذكار الصباح",
      "count": "1",
      "description": "",
      "reference": "",
      "content":
          "اللّهُـمَّ إِنِّـي أسْـأَلُـكَ العَـفْوَ وَالعـافِـيةَ في الدُّنْـيا وَالآخِـرَة ، اللّهُـمَّ إِنِّـي أسْـأَلُـكَ العَـفْوَ وَالعـافِـيةَ في ديني وَدُنْـيايَ وَأهْـلي وَمالـي ، اللّهُـمَّ اسْتُـرْ عـوْراتي وَآمِـنْ رَوْعاتـي ، اللّهُـمَّ احْفَظْـني مِن بَـينِ يَدَيَّ وَمِن خَلْفـي وَعَن يَمـيني وَعَن شِمـالي ، وَمِن فَوْقـي ، وَأَعـوذُ بِعَظَمَـتِكَ أَن أُغْـتالَ مِن تَحْتـي."
    },
    {
      "category": "أذكار الصباح",
      "count": "3",
      "description": "",
      "reference": "",
      "content":
          "يَا حَيُّ يَا قيُّومُ بِرَحْمَتِكَ أسْتَغِيثُ أصْلِحْ لِي شَأنِي كُلَّهُ وَلاَ تَكِلْنِي إلَى نَفْسِي طَـرْفَةَ عَيْنٍ."
    },
    {
      "category": "أذكار الصباح",
      "count": "1",
      "description": "",
      "reference": "",
      "content":
          "أَصْبَـحْـنا وَأَصْبَـحْ المُـلكُ للهِ رَبِّ العـالَمـين ، اللّهُـمَّ إِنِّـي أسْـأَلُـكَ خَـيْرَ هـذا الـيَوْم ، فَـتْحَهُ ، وَنَصْـرَهُ ، وَنـورَهُ وَبَـرَكَتَـهُ ، وَهُـداهُ ، وَأَعـوذُ بِـكَ مِـنْ شَـرِّ ما فـيهِ وَشَـرِّ ما بَعْـدَه."
    },
    {
      "category": "أذكار الصباح",
      "count": "1",
      "description": "",
      "reference": "",
      "content":
          "اللّهُـمَّ عالِـمَ الغَـيْبِ وَالشّـهادَةِ فاطِـرَ السّـمَاوَاتِ وَالأرْضِ رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ ، أَشْهَدُ أَنْ لا إلهَ إِلاّ أَنتَ ، أَعـوذُ بِكَ مِن شَرِّ نَفْسِي وَشَرِّ الشَّيْطانِ وَشَرِّ كُلِّ دَابَّةٍ أَنتَ آخِذٌ بِناصِيَتِهَا ، إِنَّ رَبِّي عَلَى صِرَاطٍ مُسْتَقِيم."
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: myTabs.length, vsync: this); // Initialize TabController
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      apiData = service.fetchData();
    } catch (e) {
      print("Error fetching Azkar data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        backgroundColor: const Color(0xFF0b3d27),
        appBar: AppBar(
          toolbarHeight: screenHeight * 0.1,
          title: Column(
            children: [
              Text(
                languageState! ? "Al Azkar" : "الأذكار",
                style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: languageState! ? 'cursive' : "lateef"),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              )
            ],
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.keyboard_backspace_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: const Color(0xFF0b3d27),
          bottom: TabBar(
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            unselectedLabelColor: Colors.white,
            labelColor: Colors.white,
            indicatorColor: Colors.greenAccent, // Add custom indicator color
            controller: _tabController,
            tabs: myTabs,
            labelStyle: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: FutureBuilder<ApiModel?>(
            future: apiData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator(color: Colors.greenAccent));
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No Data Available'));
              } else {
                final apiModel = snapshot.data!;
                return TabBarView(
                  controller: _tabController,
                  children: [
                    buildAzkarCategory(azkarAsSabah),
                    buildAzkarCategory(apiModel.tentacled),
                    buildAzkarCategory(apiModel.indigo),
                    buildAzkarCategory(apiModel.indecent),
                    buildAzkarCategory(apiModel.sticky),
                    buildAzkarCategory(apiModel.purple),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildAzkarCategory(List<dynamic> items) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: items
              .asMap()
              .entries
              .skip(1)
              // Skip the first item or adjust as per your requirement
              .where((entry) {
            final item = entry.value;
            // Add conditions to exclude certain types or values
            if (item is Empty) {
              return true; // Keep this type
            } else if (item is Map<String, dynamic>) {
              return item['content'] != null && item['content'].isNotEmpty;
            } else {
              return false; // Exclude unsupported or unwanted types
            }
          }).map((entry) {
            final item = entry.value;
            if (item is Empty) {
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: const Color(0xFF0b3d27),
                elevation: 10,
                child: ListTile(
                  title: Text(
                    item.content,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  subtitle: Text(
                    item.reference,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              );
            } else if (item is Map<String, dynamic>) {
              final content = item['content'] ?? "No Content";
              final reference = item['reference'] ?? "No Reference";
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: const Color(0xFF0b3d27),
                elevation: 8,
                child: ListTile(
                  title: Text(
                    textAlign: TextAlign.center,
                    content,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  subtitle: Text(
                    reference,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              );
            } else {
              return SizedBox.shrink(); // Exclude unsupported or unwanted items
            }
          }).toList(),
        ),
      ),
    );
  }
}
