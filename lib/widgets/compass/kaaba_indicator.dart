// widgets/compass/kaaba_indicator.dart
import 'dart:math';
import 'package:flutter/material.dart';

class KaabaIndicator extends StatelessWidget {
  final double angle;
  final double compassSize;

  const KaabaIndicator({
    super.key,
    required this.angle,
    required this.compassSize,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle * (pi / 180) * -1,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: compassSize * 0.05),
          child: _buildKaabaIcon(compassSize * 0.15),
        ),
      ),
    );
  }

  Widget _buildKaabaIcon(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF5D4037),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF8D6E63),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.8,
            height: size * 0.8,
            decoration: BoxDecoration(
              color: const Color(0xFF3E2723),
              border: Border.all(
                color: Colors.grey[800]!,
                width: 2,
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.15,
            child: Container(
              width: size * 0.3,
              height: size * 0.4,
              decoration: BoxDecoration(
                color: const Color(0xFF5D4037),
                border: Border.all(
                  color: Colors.grey[700]!,
                  width: 1.5,
                ),
              ),
            ),
          ),
          Positioned(
            top: size * 0.1,
            child: Image.asset(
              'assets/images/kaaba.png', // Path to your image asset
              width: size * 0.7,
              height: size * 0.7,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
