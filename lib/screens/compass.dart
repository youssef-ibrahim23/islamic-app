import 'dart:math';
import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/widgets/app_them.dart';

class CompassPage extends StatefulWidget {
  const CompassPage({super.key});

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  @override
  Widget build(BuildContext context) {
    final bool isEnglish = Globals.languageState!;
    final size = MediaQuery.of(context).size;
    final bool isPortrait = size.height > size.width;

    return Directionality(
      textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withOpacity(0.8),
                Colors.white.withOpacity(0.1),
              ],
            ),
            image: const DecorationImage(
              image: AssetImage("assets/background.jpg"),
              fit: BoxFit.cover,
              opacity: 0.9,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isEnglish ? "Qibla Compass" : "بوصلة القبلة",
                style: TextStyle(
                  fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              Container(
                width: isPortrait ? size.width * 0.95 : size.height * 0.95,
                height: isPortrait ? size.width * 0.95 : size.height * 0.95,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Circular compass background image
                    ClipOval(
                      child: Image.asset(
                        'assets/compass.png',
                        fit: BoxFit.cover,
                        width: isPortrait ? size.width * 0.95 : size.height * 0.95,
                        height: isPortrait ? size.width * 0.95 : size.height * 0.95,
                      ),
                    ),

                    // Rotating arrow
                    Transform.rotate(
                      angle: (Globals.qiblaDirection ?? 0) * (pi / 180) * -1,
                      child: const Icon(Icons.navigation, size: 50, color: Colors.red),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),
              Text(
                isEnglish
                    ? "Direction: ${Globals.compassHeading?.toStringAsFixed(1) ?? '0'}°"
                    : "الاتجاه: ${Globals.compassHeading?.toStringAsFixed(1) ?? '0'}°",
                style: TextStyle(
                  fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                  fontSize: 18,
                  color: primaryColor,
                ),
              ),
              if (!Globals.hasPermissions)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    isEnglish
                        ? "Location permission required"
                        : "يطلب إذن الموقع",
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
