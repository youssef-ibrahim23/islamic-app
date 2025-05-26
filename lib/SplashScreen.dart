import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:islamic_app/BottomBar.dart';
import 'package:islamic_app/Login.dart';
import 'package:islamic_app/PayerTimesP.dart';
import 'package:islamic_app/SignUp.dart';
import 'package:islamic_app/Welcome.dart';
import 'package:islamic_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Services/Database.dart';
import 'Home.dart';
import 'Profile.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
    _loadLanguageState();
  }

  Future<void> _loadLanguageState() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    languageState = await sharedPreferences.getBool("language") ?? false;
  }

  Future<void> _initializeApp() async {
    await Firebase.initializeApp();
    _startNavigationAfterDelay();
  }

  void _startNavigationAfterDelay() {
    Timer(const Duration(seconds: 3), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;

      if (hasSeenWelcome) {
        _navigateToHomeOrLogin();
      } else {
        await prefs.setBool('hasSeenWelcome', true);
        _navigateToWelcome();
      }
    });
  }

  void _navigateToHomeOrLogin() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null ) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login_P()),
      );
    } else {
      String? email = FirebaseAuth.instance.currentUser?.email;
      print(email);

      try {
        // Assuming DB.select is a method that returns user data
        String query =
            "SELECT EMAIL, USERNAME, country FROM USERS WHERE EMAIL = '${email}'";
        List<Map<String, dynamic>> data =
            await DB.select(query); // Use async await for database operations

        if (data.isNotEmpty) {
          String userName = data[0]['USERNAME'];
          String userCountry = data[0]['country'];

          // Assuming you store the user data somewhere
          setState(() {
            Email.text = email!;
            Name.text = userName;
            country.text = userCountry;
            acountName = userName;
            Country = data[0]['country'];
            Governorate = arabicCountriesMainGovernorate.keys.contains(Country) ? arabicCountriesMainGovernorate[Country] : arabicCountriesMainGovernoratee[Country];
            print("$Country , $Governorate");
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomBar()),
          );
        } else {
          _navigateToLogin();
        }
      } catch (e) {
        print("Error fetching user data: $e");
        _navigateToLogin();
      }
    }
  }

  void _navigateToWelcome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Welcome_P()),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login_P()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset("assets/ic_launcher.png", fit: BoxFit.cover),
      ),
    );
  }
}
