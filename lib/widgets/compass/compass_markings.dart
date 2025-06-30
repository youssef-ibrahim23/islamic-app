// widgets/compass/compass_markings.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:islamic_app/widgets/app_them.dart';

class CompassMarkings extends StatelessWidget {
  final double size;
  final bool isEnglish;

  const CompassMarkings({super.key, required this.size, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    const List<String> directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
    const List<String> arabicDirections = ["ش", "ش ق", "ق", "ج ق", "ج", "ج غ", "غ", "ش غ"];

    List<Widget> markings = [];

    for (int i = 0; i < 360; i += 45) {
      final isCardinal = i % 45 == 0;
      final index = i ~/ 45;

      markings.add(
        Transform.rotate(
          angle: i * pi / 180,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: isCardinal
                  ? Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: i == 0 ? Colors.red.withOpacity(0.3) : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        isEnglish ? directions[index] : arabicDirections[index],
                        style: TextStyle(
                          fontSize: isCardinal ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: i == 0 ? Colors.red : primaryColor,
                          shadows: i == 0
                              ? [
                                  Shadow(
                                    blurRadius: 5,
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(1, 1),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    )
                  : Container(
                      width: 2.5,
                      height: 18,
                      color: primaryColor.withOpacity(0.8),
                    ),
            ),
          ),
        ),
      );
    }

    for (int i = 0; i < 360; i += 10) {
      if (i % 45 == 0) continue;

      markings.add(
        Transform.rotate(
          angle: i * pi / 180,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Container(
                width: 1.5,
                height: i % 30 == 0 ? 15 : 10,
                color: primaryColor.withOpacity(i % 30 == 0 ? 0.8 : 0.6),
              ),
            ),
          ),
        ),
      );
    }

    return Stack(children: markings);
  }
}