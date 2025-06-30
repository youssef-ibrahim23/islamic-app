// widgets/compass/calibration_widget.dart
import 'package:flutter/material.dart';
import 'package:islamic_app/widgets/app_them.dart';

class CalibrationWidget extends StatefulWidget {
  final bool isEnglish;
  final bool isCalibrating;
  final VoidCallback onCalibrate;

  const CalibrationWidget({
    super.key,
    required this.isEnglish,
    required this.isCalibrating,
    required this.onCalibrate,
  });

  @override
  State<CalibrationWidget> createState() => _CalibrationWidgetState();
}

class _CalibrationWidgetState extends State<CalibrationWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: widget.isCalibrating
          ? _buildCalibrationMessage()
          : _buildCalibrationButton(),
    );
  }

  Widget _buildCalibrationMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5EF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFF8F5EF),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: primaryColor, size: 24),
          const SizedBox(width: 10),
          Text(
            widget.isEnglish
                ? "Move your phone in a figure 8 pattern"
                : "حرك هاتفك في شكل رقم 8",
            style: TextStyle(
              color: primaryColor,
              fontFamily: widget.isEnglish ? 'Roboto' : 'Tajawal',
              fontSize: 16,
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
    );
  }

  Widget _buildCalibrationButton() {
    return TextButton(
      onPressed: widget.onCalibrate,
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFFF8F5EF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Color(0xFFF8F5EF),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 14,
        ),
        shadowColor: Colors.black.withOpacity(0.3),
        elevation: 5,
      ),
      child: Text(
        widget.isEnglish ? "Calibrate Compass" : "معايرة البوصلة",
        style: TextStyle(
          color: primaryColor,
          fontFamily: widget.isEnglish ? 'Roboto' : 'Tajawal',
          fontSize: 18,
          shadows: [
            Shadow(
              blurRadius: 5,
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(1, 1),
            ),
          ],
        ),
      ),
    );
  }
}