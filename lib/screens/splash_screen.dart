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
  bool _imagePrecached = false;

  @override
  void initState() {
    super.initState();
    _loadLanguageState();
    _precacheAssetsAndNavigate();
  }

  Future<void> _loadLanguageState() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Globals.languageState = sharedPreferences.getBool("language") ?? false;
  }

  Future<void> _precacheAssetsAndNavigate() async {
    // ✅ Ensure widget tree is ready for precaching
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await precacheImage(const AssetImage('assets/background.jpg'), context);
      _imagePrecached = true;

      // Wait for the rest of splash duration (if needed)
      await Future.delayed(const Duration(seconds: 2));

      _navigateToHome();
    });
  }

  void _navigateToHome() {
    if (_imagePrecached) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomBar()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(
          image: AssetImage("assets/ic_launcher.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
