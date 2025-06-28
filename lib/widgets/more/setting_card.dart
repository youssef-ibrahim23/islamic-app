import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/widgets/app_them.dart';

class SettingCardWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Size size;
  final bool isPortrait;

  const SettingCardWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.children,
    required this.size,
    required this.isPortrait,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: primaryColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: isPortrait ? 20 : 18,
                      fontWeight: FontWeight.w600,
                      fontFamily:
                          Globals.languageState! ? 'Roboto' : 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 20, endIndent: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}
