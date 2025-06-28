import 'dart:math';

import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/widgets/app_them.dart';

class Compasswidget {
  static Widget buildCompassWidget(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              Globals.languageState! ? "Qibla Compass" : "بوصلة القبلة",
              style: TextStyle(
                fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Compass background
                  Image.asset('assets/compass.jpg', width: 180),

                  // Qibla direction indicator
                  Transform.rotate(
                    angle: (Globals.qiblaDirection ?? 0) * (pi / 180) * -1,
                    child: Image.asset('assets/kaaba_icon.png', width: 40),
                  ),

                  // Current direction indicator
                  Transform.rotate(
                    angle: (Globals.compassHeading ?? 0) * (pi / 180) * -1,
                    child: const Icon(Icons.navigation,
                        size: 30, color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              Globals.languageState!
                  ? "Direction: ${Globals.compassHeading?.toStringAsFixed(1) ?? '0'}°"
                  : "الاتجاه: ${Globals.compassHeading?.toStringAsFixed(1) ?? '0'}°",
              style: TextStyle(
                fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
                fontSize: 16,
                color: textColor,
              ),
            ),
            if (!Globals.hasPermissions)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  Globals.languageState!
                      ? "Location permission required"
                      : "يطلب إذن الموقع",
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
