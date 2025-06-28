import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/date_services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CombinedDateWidget extends StatelessWidget {
  final Color cardColor;
  final Color textColor;
  final double elevation;
  final bool showIcons;

  const CombinedDateWidget({
    super.key,
    required this.cardColor,
    required this.textColor,
    this.elevation = 4,
    this.showIcons = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = Globals.languageState!;
    final String dayName = DateService.getCurrentDayName();
    final String gregorianDate = DateService.getCurrentGregorianDate();
    final String hijriDate = DateService.getCurrentHijriDate();

    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Day name with animation
            Text(
              dayName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
                height: 1.3,
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),
            
            const SizedBox(height: 8),
            
            // Divider with animation
            Divider(
              color: Colors.grey.withOpacity(0.3),
              thickness: 1,
              height: 1,
              indent: 16,
              endIndent: 16,
            ).animate().scaleX(begin: 0, duration: 400.ms),
            
            const SizedBox(height: 12),
            
            // Date row with icons and animations
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildDateColumn(
                      date: gregorianDate,
                      icon: Icons.calendar_today,
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Colors.grey.withOpacity(0.3),
                    indent: 4,
                    endIndent: 4,
                  ),
                  Expanded(
                    child: _buildDateColumn(
                      date: hijriDate,
                      icon: Icons.mosque,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildDateColumn({
    required String date,
    IconData? icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcons && icon != null)
          Icon(
            icon,
            size: 20,
            color: textColor.withOpacity(0.8),
          ).animate().fadeIn(delay: 300.ms),
        if (showIcons && icon != null) const SizedBox(height: 4),
        const SizedBox(height: 4),
        Text(
          date,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}