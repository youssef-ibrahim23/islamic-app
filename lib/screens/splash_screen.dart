// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/screens/bottom_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadLanguageState();
    _startNavigationAfterDelay();
  }

  Future<void> _loadLanguageState() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Globals.languageState = sharedPreferences.getBool("language") ?? false;
  }

  void _startNavigationAfterDelay() {
    Timer(const Duration(seconds: 3), () async {
      _navigateToHome();
    });
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const BottomBar()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset("assets/splash_screen.jpg", fit: BoxFit.cover),
      ),
    );
  }
}
