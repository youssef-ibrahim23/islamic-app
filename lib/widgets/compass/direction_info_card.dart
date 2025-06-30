// widgets/compass/direction_info_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/widgets/app_them.dart';

class DirectionInfoCard extends StatelessWidget {
  final double angle;
  final bool isEnglish;

  const DirectionInfoCard({
    super.key,
    required this.angle,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F5EF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              isEnglish ? "Direction to Kaaba" : "اتجاه الكعبة",
              style: TextStyle(
                fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "${angle.toStringAsFixed(1)}° ${_getDirectionName(angle, isEnglish)}",
              style: TextStyle(
                fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(
            begin: 0.2,
            curve: Curves.easeOutQuad,
          ),
    );
  }

  String _getDirectionName(double degrees, bool isEnglish) {
    if (degrees >= 337.5 || degrees < 22.5) {
      return isEnglish ? "North" : "شمال";
    } else if (degrees >= 22.5 && degrees < 67.5) {
      return isEnglish ? "Northeast" : "شمال شرق";
    } else if (degrees >= 67.5 && degrees < 112.5) {
      return isEnglish ? "East" : "شرق";
    } else if (degrees >= 112.5 && degrees < 157.5) {
      return isEnglish ? "Southeast" : "جنوب شرق";
    } else if (degrees >= 157.5 && degrees < 202.5) {
      return isEnglish ? "South" : "جنوب";
    } else if (degrees >= 202.5 && degrees < 247.5) {
      return isEnglish ? "Southwest" : "جنوب غرب";
    } else if (degrees >= 247.5 && degrees < 292.5) {
      return isEnglish ? "West" : "غرب";
    } else {
      return isEnglish ? "Northwest" : "شمال غرب";
    }
  }
}