import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/widgets/app_them.dart';

class CombinedDateWidget extends StatelessWidget {
  final String gregorianDate;
  final String hijriDate;

  const CombinedDateWidget({
    Key? key,
    required this.gregorianDate,
    required this.hijriDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    gregorianDate,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey.withOpacity(0.3),
                ),
                Expanded(
                  child: Text(
                    hijriDate,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
