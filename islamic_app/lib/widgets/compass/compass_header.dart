// widgets/compass/compass_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CompassHeader extends StatelessWidget {
  final bool isEnglish;
  final bool isPortrait;

  const CompassHeader({
    super.key,
    required this.isEnglish,
    required this.isPortrait,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: isPortrait ? 240 : 150,
      padding: const EdgeInsets.only(top: 40 ),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.black.withOpacity(0.8),
          Colors.white.withOpacity(0.1)
        ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isEnglish ? 'Qibla Compass' : 'بوصلة القبلة',
            style: TextStyle(
              color: Colors.white,
              fontSize: isPortrait ? 32 : 28,
              fontWeight: FontWeight.bold,
              fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isEnglish ? 'Find the direction to Kaaba' : 'ابحث عن اتجاه الكعبة',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isPortrait ? 16 : 14,
              fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
              shadows: [
                Shadow(
                  blurRadius: 5,
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(
          begin: 0.1,
          curve: Curves.easeOutQuad,
        );
  }
}