import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/date_services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CombinedDateWidget extends StatelessWidget {
  final Color cardColor;
  final Color textColor;
  final double elevation;
  final bool showIcons;
  final bool showBackgroundElements;

  const CombinedDateWidget({
    super.key,
    required this.cardColor,
    required this.textColor,
    this.elevation = 6,
    this.showIcons = true,
    this.showBackgroundElements = true,
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
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: textColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      color: const Color(0xFFF8F5EF), // Cream background,
      child: Stack(
        children: [
          // Decorative background elements
          if (showBackgroundElements) ...[
            Positioned(
              top: -10,
              right: -10,
              child: Icon(
                Icons.date_range,
                size: 60,
                color: textColor.withOpacity(0.05),
              ),
            ),
            Positioned(
              bottom: -10,
              left: -10,
              child: Icon(
                Icons.mosque,
                size: 60,
                color: textColor.withOpacity(0.05),
              ),
            ),
          ],
          
          Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Day name with decorative elements
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Decorative underline
                    Positioned(
                      bottom: 0,
                      child: Container(
                        height: 3,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF8B0000).withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Text(
                      dayName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF8B0000),
                        height: 1.3,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF8B0000).withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2),
                
                const SizedBox(height: 10),
                
                // Divider with decorative elements
                Stack(
                  children: [
                    Divider(
                      color: const Color(0xFF8B0000).withOpacity(0.2),
                      thickness: 1,
                      height: 1,
                    ),

                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF8B0000),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.circle,
                          size: 8,
                          color: textColor.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ],
                ).animate().scaleX(begin: 0, duration: 400.ms),
                
                
                
                // Date row with improved layout
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gregorian date
                      _buildDateTile(
                        context,
                        date: gregorianDate,
                        icon: Icons.calendar_month_rounded,
                        label: isEnglish ? "Gregorian" : "الميلادي",
                      ),
                      
                      // Vertical divider with decoration
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: const Color(0xFF8B0000).withOpacity(0.2),
                          indent: 8,
                          endIndent: 8,
                        ),
                      ),
                      
                      // Hijri date
                      _buildDateTile(
                        context,
                        date: hijriDate,
                        icon: Icons.mosque_rounded,
                        label: isEnglish ? "Hijri" : "الهجري",
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTile(
    BuildContext context, {
    required String date,
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcons)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF8B0000).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: const Color(0xFF8B0000),
              ),
            ).animate()
.fadeIn(delay: 300.ms)
.scale(begin: const Offset(0.5, 0.5)),
          
          if (showIcons) const SizedBox(height: 8),
          
          Text(
            label,
            style: TextStyle(
              fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8B0000)
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8B0000) // Dark red,
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}