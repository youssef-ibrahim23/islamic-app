// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:islamic_app/screens/bottom_bar.dart';
import 'package:islamic_app/services/app_lunch_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    try {
      // Start both image precaching and app logic
      await Future.wait([
        precacheImage(const AssetImage('assets/background.jpg'), context),
        AppLaunchService.initializeApp(),
      ]);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomBar()),
        );
      }
    } catch (e) {
      debugPrint("❌ Error during splash init: $e");
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
