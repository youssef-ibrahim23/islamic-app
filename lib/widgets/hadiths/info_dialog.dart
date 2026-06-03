import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/hadith_services.dart';
import 'package:islamic_app/widgets/app_them.dart';

class InfoDialog {
  static void showInfoDialog(BuildContext context) {
    final isEnglish = Globals.languageState!;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(minHeight: 320),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Decorative pattern
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -15,
                  left: -15,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),

                // Main content
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with icon and title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.bookOpen,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text(
                                isEnglish
                                    ? 'About Sahih Bukhari'
                                    : 'عن صحيح البخاري',
                                style: GoogleFonts.getFont(
                                  isEnglish ? 'Roboto' : 'Tajawal',
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Colors.white24),
                      const SizedBox(height: 20),

                      // Current range info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              isEnglish ? 'Current Range' : 'النطاق الحالي',
                              style: GoogleFonts.getFont(
                                isEnglish ? 'Roboto' : 'Tajawal',
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isEnglish
                                  ? 'Hadiths ${Globals.currentRangeStart}-${Globals.currentRangeEnd}'
                                  : 'الأحاديث من ${HadithService.convertNumbersToArabic(Globals.currentRangeStart.toString(), isEnglish)} إلى ${HadithService.convertNumbersToArabic(Globals.currentRangeEnd.toString(), isEnglish)}',
                              style: GoogleFonts.getFont(
                                isEnglish ? 'Roboto' : 'Tajawal',
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 2,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        isEnglish
                            ? 'Sahih al-Bukhari is one of the most authentic collections of hadith in Islam. It contains over 7,000 hadiths narrated by the Prophet Muhammad (peace be upon him) and compiled by Imam Bukhari.'
                            : 'صحيح البخاري هو أحد أصح كتب الحديث النبوي في الإسلام. يحتوي على أكثر من 7,000 حديث رواه النبي محمد (صلى الله عليه وسلم) وجمعها الإمام البخاري.',
                        style: GoogleFonts.getFont(
                          isEnglish ? 'Roboto' : 'Tajawal',
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 2,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Close button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(
                            isEnglish ? 'Close' : 'إغلاق',
                            style: GoogleFonts.getFont(
                              isEnglish ? 'Roboto' : 'Tajawal',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Auto-dismiss indicator
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scaleXY(
                          begin: 1.0,
                          end: 0.3,
                          duration: 2000.ms,
                          curve: Curves.easeInOut)
                      .then()
                      .scaleXY(
                          begin: 0.3,
                          end: 1.0,
                          duration: 2000.ms,
                          curve: Curves.easeInOut),
                ),
              ],
            ),
          )
              .animate()
              .slideY(
                  begin: 1.0,
                  end: 0.0,
                  duration: 500.ms,
                  curve: Curves.elasticOut)
              .fadeIn(duration: 500.ms),
        );
      },
    );
  }
}
