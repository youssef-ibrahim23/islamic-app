import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:islamic_app/Services/Payers.dart';
import 'package:islamic_app/main.dart'; // For formatting time

String? Country = "Egypt";
String? Governorate = "Cairo";

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  _PrayerTimesPageState createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  final AladhanAPIService _apiService = AladhanAPIService();
  Map<String, dynamic>? prayerTimes;
  Timer? _timer;
  String nextPrayer = '';
  String nextPrayerTime = '';
  String timeRemaining = '';
  String? nextArabicPrayer;

  @override
  void initState() {
    super.initState();
    _initializePrayerTimes();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializePrayerTimes() async {
    try {
      final data = await _apiService.getPrayerTimes(Governorate!, Country!);
      if (data['data'] == null || data['data']['timings'] == null) {
        throw Exception("Invalid prayer times data");
      }

      setState(() {
        prayerTimes = data['data']['timings'];
      });

      _calculateNextPrayer();
    } catch (e) {
      print("Error fetching prayer times: $e");
      setState(() {
        nextPrayer = languageState! ? "Error" : 'خطاء';
        nextPrayerTime = "Unable to fetch data";
        timeRemaining = "";
      });
    }
  }

  void _calculateNextPrayer() {
    final now = DateTime.now().toUtc();
    final timings = prayerTimes!;
    DateTime? nextPrayerDateTime;

    List<String> islamicPrayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (var prayer in islamicPrayers) {
      final prayerTimeString = timings[prayer];

      if (prayerTimeString == null || !prayerTimeString.contains(':')) {
        print("Skipping invalid time for $prayer: $prayerTimeString");
        continue;
      }

      final prayerTimeParts = prayerTimeString.split(':');
      final prayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(prayerTimeParts[0]),
        int.parse(prayerTimeParts[1]),
      );

      if (prayerDateTime.isAfter(now)) {
        setState(() {
          nextPrayer = prayer;
          nextPrayerTime = prayerTimeString;
          nextArabicPrayer =
              _getArabicPrayerName(prayer); // Set Arabic prayer name here
        });
        nextPrayerDateTime = prayerDateTime;
        break;
      }
    }

    if (nextPrayerDateTime == null) {
      final tomorrow = now.add(Duration(days: 1));
      final firstPrayerTimeString = timings['Fajr'];
      if (firstPrayerTimeString != null &&
          firstPrayerTimeString.contains(':')) {
        final prayerTimeParts = firstPrayerTimeString.split(':');
        nextPrayerDateTime = DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          int.parse(prayerTimeParts[0]),
          int.parse(prayerTimeParts[1]),
        );

        setState(() {
          nextPrayer = 'Fajr';
          nextPrayerTime = firstPrayerTimeString;
          nextArabicPrayer =
              _getArabicPrayerName('Fajr'); // Set Arabic prayer name here
        });
      }
    }

    if (nextPrayerDateTime == null) {
      setState(() {
        nextPrayer = "Prayer times unavailable";
        nextPrayerTime = "Please try again later";
        timeRemaining = "";
      });
    } else {
      _updateTimeRemaining(nextPrayerDateTime);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _updateTimeRemaining(nextPrayerDateTime!);
      });
    }
  }

  void _updateTimeRemaining(DateTime nextPrayerDateTime) {
    final now = DateTime.now().toUtc();
    final difference = nextPrayerDateTime.difference(now);

    if (difference.isNegative) {
      setState(() {
        timeRemaining = languageState!
            ? 'Next prayer is $nextPrayer at $nextPrayerTime'
            : " $nextPrayerTime في $nextArabicPrayer الصلاة القادمة هي";
      });
    } else {
      setState(() {
        final hours = difference.inHours;
        final minutes = difference.inMinutes % 60;
        final seconds = difference.inSeconds % 60;

        timeRemaining = '${hours.toString().padLeft(2, '0')}:'
            '${minutes.toString().padLeft(2, '0')}:'
            '${seconds.toString().padLeft(2, '0')}';
      });
    }
  }

  String _getArabicPrayerName(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return 'الفجر';
      case 'Dhuhr':
        return 'الظهر';
      case 'Asr':
        return 'العصر';
      case 'Maghrib':
        return 'المغرب';
      case 'Isha':
        return 'العشاء';
      default:
        return '';
    }
  }

  String convertTo12HourFormat(String time24) {
    try {
      final time = DateFormat("HH:mm").parse(time24);
      return DateFormat( languageState! ? "hh:mm a" : "hh:mm").format(time);
    } catch (e) {
      print("Error converting time: $e");
      return time24;
    }
  }

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
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0b3d27),
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.keyboard_backspace_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF0b3d27),
        foregroundColor: const Color(0xFF0b3d27),
        surfaceTintColor: const Color(0xFF0b3d27),
        centerTitle: true,
        title: Text(
          languageState! ? "Prayer Times" : 'مواعيد الصلاة',
          style: TextStyle(
            fontFamily: languageState! ? 'Cursive' : 'lateef',
            color: Colors.white,
            fontSize: screenWidth * 0.07,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        elevation: 5,
      ),
      body: prayerTimes == null
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.greenAccent,
                strokeWidth: 3,
              ),
            )
          : Column(
              children: [
                SizedBox(height: screenHeight * 0.05),
                Text(
                  languageState!
                      ? 'Next prayer is $nextPrayer at $nextPrayerTime'
                      : " الصلاة القادمة هي $nextArabicPrayer في ${toArabicNumber(nextPrayerTime)}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: languageState!
                        ? screenWidth * 0.06
                        : screenWidth * 0.08,
                    fontFamily: languageState! ? 'Cursive' : 'Lateef',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                Text(
                  languageState! ? timeRemaining : toArabicNumber(timeRemaining),
                  style: TextStyle(
                    letterSpacing: 10,
                    color: Colors.white,
                    fontSize: screenWidth * 0.1,
                    fontFamily: 'Cursive',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListView(
                      children: prayerTimes!.entries.map((entry) {
                        String prayerName = entry.key;
                        String prayerTime = convertTo12HourFormat(entry.value);

                        return (prayerName == 'Fajr' ||
                                prayerName == 'Dhuhr' ||
                                prayerName == 'Asr' ||
                                prayerName == 'Maghrib' ||
                                prayerName == 'Isha')
                            ? Card(
                                margin:
                                    const EdgeInsets.only(top: 2, bottom: 25.0),
                                color: Colors.white,
                                child: languageState! ?  ListTile(
                                  title: Text(
                                    languageState!
                                        ? prayerName
                                        : _getArabicPrayerName(prayerName),
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  subtitle: Text(
                                    prayerTime,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      color: Colors.black,
                                    ),
                                  ),
                                  leading: const Icon(
                                    Icons.access_time,
                                    color: Colors.black,
                                  ),
                                ) : ListTile(

                                  title: Text(
                                    textAlign: TextAlign.end,
                                    languageState!
                                        ? prayerName
                                        : _getArabicPrayerName(prayerName),
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  subtitle: Text(
                                    textAlign: TextAlign.end,
                                    toArabicNumber(prayerTime),
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      color: Colors.black,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.access_time,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            : const SizedBox(height: 0);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
