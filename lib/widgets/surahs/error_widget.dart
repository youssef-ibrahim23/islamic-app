import 'package:flutter/material.dart';
import 'package:islamic_app/widgets/app_them.dart';

class ErrorrWidget extends StatelessWidget {
  final bool isEnglish;
  final VoidCallback onRetry;

  const ErrorrWidget({
    super.key,
    required this.isEnglish,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: primaryColor, size: 48),
          const SizedBox(height: 16),
          Text(
            isEnglish ? "Error loading data" : "خطأ في تحميل البيانات",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              isEnglish ? "Retry" : "إعادة المحاولة",
              style: TextStyle(
                fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}