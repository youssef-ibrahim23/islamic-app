// widgets/compass/qibla_indicator.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:islamic_app/widgets/app_them.dart';

class QiblaIndicator extends StatelessWidget {
  final double angle;
  final double compassSize;

  const QiblaIndicator({
    super.key,
    required this.angle,
    required this.compassSize,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle * (pi / 180) * -1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: compassSize * 0.35,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
          Container(
            width: compassSize * 0.1,
            height: compassSize * 0.1,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.navigation,
                color: Colors.white,
                size: compassSize * 0.06,
              ),
            ),
          ),
        ],
      ),
    );
  }
}