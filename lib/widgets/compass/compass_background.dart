import 'dart:math';

import 'package:flutter/material.dart';
import 'package:islamic_app/widgets/app_them.dart';

class CompassBackground extends StatelessWidget {
  final double size;
  final Color? baseColor;
  final Color? accentColor;
  final bool showDetails;

  const CompassBackground({
    super.key,
    required this.size,
    this.baseColor,
    this.accentColor,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = baseColor ?? theme.cardColor;
    final accent = accentColor ?? theme.primaryColor;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: accent.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
        gradient: RadialGradient(
          colors: [
            base.withOpacity(0.95),
            base.withOpacity(0.7),
            base.withOpacity(0.5),
          ],
          stops: const [0.3, 0.7, 1.0],
          center: Alignment.center,
          radius: 0.8,
        ),
      ),
      child: Stack(
        children: [
          // Outer metallic ring
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withOpacity(0.9),
                width: 8,
              ),
            ),
          ),
          
          // Inner metallic ring
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withOpacity(0.8),
                width: 2,
              ),
            ),
          ),
          
          // Decorative elements
          if (showDetails) ...[
            // Compass center point
            Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent,
                      accent.withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                ),
              ),
            ),
            
            // Cardinal direction indicators
            ..._buildCardinalIndicators(accent),
            
            // Radial lines
            ..._buildRadialLines(accent),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildCardinalIndicators(Color accent) {
    return ['N', 'E', 'S', 'W'].map((direction) {
      double angle;
      switch (direction) {
        case 'N': angle = 0; break;
        case 'E': angle = 90; break;
        case 'S': angle = 180; break;
        case 'W': angle = 270; break;
        default: angle = 0;
      }
      
      return Transform.rotate(
        angle: angle * (pi / 180),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: size * 0.05),
            child: Container(
              width: 3,
              height: 20,
              color: direction == 'N' ? Colors.red : accent.withOpacity(0.7),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildRadialLines(Color accent) {
    List<Widget> lines = [];
    for (int i = 0; i < 360; i += 30) {
      if (i % 90 == 0) continue; // Skip cardinal directions
      
      lines.add(
        Transform.rotate(
          angle: i * (pi / 180),
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: size * 0.05),
              child: Container(
                width: 1,
                height: 15,
                color: accent.withOpacity(0.4),
              ),
            ),
          ),
        ),
      );
    }
    return lines;
  }
}