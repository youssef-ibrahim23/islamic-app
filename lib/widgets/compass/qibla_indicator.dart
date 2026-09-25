import 'dart:math';
import 'package:flutter/material.dart';

class QiblaIndicator extends StatelessWidget {
  final double angle;
  final double compassSize;
  final bool isActive;

  const QiblaIndicator({
    super.key,
    required this.angle,
    required this.compassSize,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle * (pi / 180) * -1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Enhanced pointer line with glow effect
          _buildPointerLine(),
          const SizedBox(height: 2),
          // Improved compass base with pulsing animation
          _buildCompassBase(),
        ],
      ),
    );
  }

  Widget _buildPointerLine() {
    return Container(
      width: 6,
      height: compassSize * 0.4,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.9),
            Colors.red.withOpacity(0.7),
            Colors.red.withOpacity(0.4),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.5),
            blurRadius: isActive ? 20 : 10,
            spreadRadius: isActive ? 3 : 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Inner glow effect
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Decorative notches
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassBase() {
    return Container(
      width: compassSize * 0.15,
      height: compassSize * 0.15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.red.shade800,
            Colors.red.shade900,
          ],
          stops: const [0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(isActive ? 0.7 : 0.3),
            blurRadius: isActive ? 25 : 15,
            spreadRadius: isActive ? 5 : 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner circle
          Container(
            width: compassSize * 0.08,
            height: compassSize * 0.08,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          // Qibla icon with animation
          Icon(
            Icons.explore,
            color: Colors.white,
            size: compassSize * 0.08,
          ),
          // Pulsing animation (only when active)
          if (isActive)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: 0.6,
                duration: const Duration(milliseconds: 1500),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.3),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}