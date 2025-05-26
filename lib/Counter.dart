import 'package:flutter/material.dart';
import 'package:islamic_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _counter = 0;

  // Load counter value from Shared Preferences
  void _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('counter') ?? 0; // Default to 0 if not found
    });
  }

  // Save counter value to Shared Preferences
  void _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('counter', _counter);
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    _saveCounter(); // Save the updated counter value
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
    _saveCounter(); // Save the reset counter value
  }

  @override
  void initState() {
    super.initState();
    _loadCounter(); // Load counter when the screen initializes
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
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.1,
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
        title: Text(
          languageState! ? "Counter" : "تسابيح",
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.09,
            fontFamily: languageState! ? 'cursive' : 'Lateef',
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(50),
              child: Container(
                width: screenWidth * 0.8,
                height: screenHeight * 0.28,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: Text(
                    languageState!
                        ? '$_counter'
                        : toArabicNumber(_counter.toString()),
                    style: TextStyle(
                      fontSize: screenWidth * 0.25,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0b3d27),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            ElevatedButton(
              onPressed: _resetCounter,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0b3d27),
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.1,
                    vertical: screenHeight * 0.02),
              ),
              child: Text(
                languageState! ? 'Reset' : 'اعادة',
                style:
                    TextStyle(fontSize: screenWidth * 0.05, color: Colors.red),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            ElevatedButton.icon(
              onPressed: _incrementCounter,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                '',
                style: TextStyle(
                    fontFamily: 'cursive',
                    fontSize: screenWidth * 0.055,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0b3d27),
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.1,
                    vertical: screenHeight * 0.02),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }
}
