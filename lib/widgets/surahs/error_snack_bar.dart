import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ErrorSnackBar {
  static void show(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ).animate().fadeIn().slideY(begin: -1);

    ScaffoldMessenger.of(context).showSnackBar(snackBar as SnackBar);
  }
}
