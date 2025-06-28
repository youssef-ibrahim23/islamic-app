import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/screens/verses.dart';
import 'package:islamic_app/widgets/app_them.dart';

class DailyAyatCard extends StatelessWidget {
  const DailyAyatCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurahDetailPage(
              Globals.currentSora,
              Globals.surahId,
              Globals.currentSora,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: AssetImage('assets/ayah.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black.withOpacity(0.4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Directionality(
                textDirection:
                    Globals.languageState! ? TextDirection.ltr : TextDirection.rtl,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      child: Text(
                        Globals.languageState!
                            ? "This is the Scripture whereof there is no doubt, a guidance unto those who ward off (evil)"
                            : "ذلك الكتاب لا ريب فيه هدى للمتقين",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Globals.languageState! ? 20 : 24,
                          color: Colors.white,
                          fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
                          height: 1.6,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: Globals.languageState!
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: Globals.languageState!
                          ? [
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_back_ios,
                                  size: 16, color: accentColor),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  Globals.currentSora,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: Globals.languageState!
                                        ? 'Roboto'
                                        : 'Tajawal',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ]
                          : [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  Globals.currentSora,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: Globals.languageState!
                                        ? 'Roboto'
                                        : 'Tajawal',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 16, color: accentColor),
                            ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
