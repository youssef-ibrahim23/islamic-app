import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget page;
  final Color primaryColor;
  final Color cardColor;
  final Color textColor;
  final Color backgroundColor;
  final double? size; // Optional size parameter
  final double? iconSize; // Optional icon size
  final List<BoxShadow>? customShadows; // Custom shadows
  final Border? border; // Optional border

  const CategoryItem({
    super.key,
    required this.icon,
    required this.label,
    required this.page,
    required this.primaryColor,
    required this.cardColor,
    required this.textColor,
    required this.backgroundColor,
    this.size,
    this.iconSize,
    this.customShadows,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final itemSize = size ?? screenWidth * 0.28;
    final iconSize = this.iconSize ?? 32;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      splashColor: primaryColor.withOpacity(0.2),
      highlightColor: primaryColor.withOpacity(0.1),
      child: Container(
        width: itemSize,
        height: itemSize,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: border,
          boxShadow: customShadows ?? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
              spreadRadius: 1,
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F5EF), // Cream background
              Color(0xFFF8F5EF),
            ],
            stops: [0.1, 0.9],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: primaryColor,
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
                    fontSize: _calculateFontSize(label, itemSize),
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateFontSize(String text, double containerSize) {
    // Adjust font size based on container size and text length
    final baseSize = containerSize * 0.12; // Base size relative to container
    final lengthFactor = text.length > 10 ? 0.9 : 1.0;
    return baseSize * lengthFactor;
  }
}