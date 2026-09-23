import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final bool isEnglish;
  final bool isPortrait;

  const HeaderWidget({
    super.key,
    required this.isEnglish,
    required this.isPortrait,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Container(
      width: double.infinity,
      height: isPortrait ? size.height * 0.25 : size.height * 0.35,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.6),
            Colors.transparent,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            isEnglish ? 'Favorites' : 'المفضلة',
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
            isEnglish ? 'Your favorite surahs' : 'السور المفضلة لديك',
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
          SizedBox(height: isPortrait ? 30 : 40),
        ],
      ),
    );
  }
}