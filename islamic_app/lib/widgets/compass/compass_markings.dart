import 'dart:math';
import 'package:flutter/material.dart';

class CompassMarkings extends StatelessWidget {
  final double size;
  final bool isEnglish;
  final Color? primaryColor;
  final Color? secondaryColor;

  const CompassMarkings({
    super.key,
    required this.size,
    required this.isEnglish,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = primaryColor ?? theme.primaryColor;
    final secondary = secondaryColor ?? theme.colorScheme.secondary;

    const List<String> directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
    const List<String> arabicDirections = ["ش", "ش ق", "ق", "ج ق", "ج", "ج غ", "غ", "ش غ"];

    List<Widget> markings = [];

    // Add degree markings (every 5 degrees)
    for (int i = 0; i < 360; i += 5) {
      final isCardinal = i % 45 == 0;
      final isMajor = i % 15 == 0;
      
      if (isCardinal) continue; // Handle cardinals separately

      markings.add(
        Transform.rotate(
          angle: i * pi / 180,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: isMajor ? 10 : 15),
              child: Container(
                width: isMajor ? 2 : 1,
                height: isMajor ? 20 : 12,
                decoration: BoxDecoration(
                  color: isMajor 
                      ? primary.withOpacity(0.8)
                      : secondary.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Add cardinal directions
    for (int i = 0; i < 360; i += 45) {
      final index = i ~/ 45;
      final isNorth = i == 0;

      markings.add(
        Transform.rotate(
          angle: i * pi / 180,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isNorth ? primary.withOpacity(0.3) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isNorth 
                      ? Border.all(color: primary.withOpacity(0.5), width: 1.5)
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEnglish ? directions[index] : arabicDirections[index],
                      style: TextStyle(
                        fontSize: isNorth ? 20 : 16,
                        fontWeight: isNorth ? FontWeight.bold : FontWeight.w600,
                        color: isNorth ? primary : secondary,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    if (isNorth)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Add inner decorative ring
    markings.add(
      Positioned.fill(
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: size * 0.7,
            height: size * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primary.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );

    // Add degree numbers (every 30 degrees)
    for (int i = 0; i < 360; i += 30) {
      if (i % 90 == 0) continue; // Skip where we have cardinal directions

      markings.add(
        Transform.rotate(
          angle: i * pi / 180,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Transform.rotate(
                angle: -i * pi / 180, // Keep text upright
                child: Text(
                  '$i°',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondary.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Stack(children: markings);
  }
}