// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/screens/bottom_bar.dart';
import 'package:islamic_app/services/app_initializer.dart';
import 'package:islamic_app/globals.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Start fast initialization immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fastInitializeAndNavigate();
    });
  }

  Future<void> _fastInitializeAndNavigate() async {
    try {
      // Start critical tasks only for fast navigation
      final results = await Future.wait([
        _preloadBackgroundImage(),
        _initializeCriticalServices(),
      ]);

      // Ensure the image is fully loaded and cached before proceeding
      final imageLoaded = results[0] as bool;
      if (!imageLoaded) {
        // If image failed to load, wait a bit longer then proceed anyway
        await Future.delayed(const Duration(milliseconds: 1000));
      } else {
        // Image loaded successfully, ensure it's fully cached by waiting longer
        await Future.delayed(const Duration(milliseconds: 1500));

        // Preload the image again to ensure it's in cache
        await _ensureImageInCache();

        // Additional verification - try to load the image one more time
        await _verifyImageCached();
      }

      // Store background load status for home page to check
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('background_preloaded', true);
      await prefs.setBool('background_fully_cached', true);
      await prefs.setString(
          'background_load_timestamp', DateTime.now().toIso8601String());

      // Navigate immediately after critical services are ready and image is fully loaded
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomBar()),
        );
      }

      // Continue heavy initialization in background
      _runBackgroundInitialization();
    } catch (e) {
      // If there's an error, still navigate after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomBar()),
        );
      }

      // Continue background initialization even on error
      _runBackgroundInitialization();
    }
  }

  // Ensure the background image is fully cached
  Future<void> _ensureImageInCache() async {
    try {
      // Try to load the image again to ensure it's in the cache
      const imageProvider = AssetImage('assets/images/background.jpg');
      final stream = imageProvider.resolve(ImageConfiguration());

      final completer = Completer<void>();
      final listener = ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onError: (Object exception, StackTrace? stackTrace) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
      );

      stream.addListener(listener);
      await completer.future.timeout(const Duration(seconds: 3));
    } catch (e) {
      // If ensuring cache fails, continue anyway
      print('Warning: Could not ensure image in cache: $e');
    }
  }

  // Additional verification that the image is cached
  Future<void> _verifyImageCached() async {
    try {
      const imageProvider = AssetImage('assets/images/background.jpg');
      final stream = imageProvider.resolve(ImageConfiguration());

      final completer = Completer<bool>();
      final listener = ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        onError: (Object exception, StackTrace? stackTrace) {
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      );

      stream.addListener(listener);
      final isCached =
          await completer.future.timeout(const Duration(seconds: 2));

      if (!isCached) {
        print('Warning: Background image may not be fully cached');
      }
    } catch (e) {
      print('Warning: Could not verify image cache: $e');
    }
  }

  Future<void> _initializeCriticalServices() async {
    try {
      // Only initialize language and basic services needed for UI
      final prefs = await SharedPreferences.getInstance();

      // Set default language
      Globals.languageState = false;
      final savedLanguage = prefs.getBool("language");
      if (savedLanguage != null) {
        Globals.languageState = savedLanguage;
      }

      // Load basic app state
      final savedCountry = prefs.getString('countryEnglish');
      Globals.selectedCountry = savedCountry;

      // Initialize device country for correct date calculation
      await _initializeDeviceCountry();
    } catch (e) {
      // Continue even if critical services fail
      print('Critical services initialization error: $e');
    }
  }

  Future<void> _initializeDeviceCountry() async {
    try {
      // Try to load saved device country first
      final prefs = await SharedPreferences.getInstance();
      final savedDeviceCountry = prefs.getString('device_country');

      if (savedDeviceCountry != null) {
        Globals.deviceCountry = savedDeviceCountry;
        return;
      }

      // If no saved country, set default to Egypt
      Globals.deviceCountry = 'Egypt';
      await prefs.setString('device_country', 'Egypt');
    } catch (e) {
      // Fallback to Egypt on error
      Globals.deviceCountry = 'Egypt';
    }
  }

  Future<void> _runBackgroundInitialization() async {
    try {
      // Run full initialization in background without blocking UI
      unawaited(AppInitializer.initialize());
    } catch (e) {
      print('Background initialization error: $e');
    }
  }

  Future<bool> _preloadBackgroundImage() async {
    try {
      final completer = Completer<bool>();

      // Create image provider
      const imageProvider = AssetImage('assets/images/background.jpg');

      // Load the image and wait for completion
      final stream = imageProvider.resolve(ImageConfiguration());
      final listener = ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        onError: (Object exception, StackTrace? stackTrace) {
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      );

      stream.addListener(listener);

      // Set a shorter timeout for faster loading
      return await completer.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(
          image: AssetImage("assets/images/ic_launcher.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// Helper function to run async operations without awaiting
void unawaited(Future<void> future) {
  // Intentionally not awaiting the future
}
