// lib/widgets/counter_widgets.dart

import 'package:flutter/material.dart';

class CounterButton extends StatelessWidget {
  final bool isPressed;
  final VoidCallback onTap;
  final double size;
  final Color color;

  const CounterButton({
    super.key,
    required this.isPressed,
    required this.onTap,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {},
      onTapUp: (_) => onTap(),
      onTapCancel: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: size,
        height: size * 0.3,
        decoration: BoxDecoration(
          color: isPressed ? color.withOpacity(0.8) : color,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            if (!isPressed)
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Center(
          child: Icon(Icons.add, color: Colors.white, size: size * 0.2),
        ),
      ),
    );
  }
}
