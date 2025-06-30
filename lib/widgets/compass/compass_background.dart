// widgets/compass/compass_background.dart
import 'package:flutter/material.dart';
import 'package:islamic_app/widgets/app_them.dart';

class CompassBackground extends StatelessWidget {
  final double size;

  const CompassBackground({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.7),
        ],
      ),
      border: Border.all(
        color: primaryColor.withOpacity(0.9),
        width: 8,
      ),
    ),
  );
}
}