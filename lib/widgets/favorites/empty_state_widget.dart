import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/screens/surahs_list.dart';

class EmptyStateWidget extends StatelessWidget {
  final bool isEnglish;
  final bool isPortrait;
  final Color primaryColor;
  final Color textColor;

  const EmptyStateWidget({
    super.key,
    required this.isEnglish,
    required this.isPortrait,
    required this.primaryColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QuranPage())),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadowColor: Colors.black.withOpacity(0.2),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F5EF),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: primaryColor.withOpacity(0.5),
                )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .then(delay: 200.ms)
                .shake(),
                const SizedBox(height: 20),
                Text(
                  isEnglish ? 'No favorites yet' : 'لا يوجد مفضلة',
                  style: TextStyle(
                    fontSize: isPortrait ? 22 : 20,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.5),
                const SizedBox(height: 12),
                Text(
                  isEnglish
                      ? 'Tap the heart icon to add surahs'
                      : 'اضغط على أيقونة القلب لإضافة السور المفضلة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isPortrait ? 16 : 14,
                    color: textColor.withOpacity(0.8),
                    fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}