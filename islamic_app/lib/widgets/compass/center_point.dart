import 'dart:math';

import 'package:flutter/material.dart';

class CenterPoint extends StatefulWidget {
  final double size;
  final bool isActive;
  final Color? primaryColor;
  final Color? secondaryColor;

  const CenterPoint({
    super.key,
    this.size = 24,
    this.isActive = false,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  State<CenterPoint> createState() => _CenterPointState();
}

class _CenterPointState extends State<CenterPoint> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = widget.primaryColor ?? theme.primaryColor;
    final secondary = widget.secondaryColor ?? theme.colorScheme.secondary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isActive ? _pulseAnimation.value : 1.0,
          child: Transform.rotate(
            angle: widget.isActive ? _rotateAnimation.value : 0,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withOpacity(0.9),
                    primary.withOpacity(0.7),
                    secondary.withOpacity(0.8),
                  ],
                  stops: const [0.1, 0.5, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                  if (widget.isActive)
                    BoxShadow(
                      color: primary.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: widget.size * 0.1,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Inner circle
                  Container(
                    width: widget.size * 0.5,
                    height: widget.size * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.3),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  
                  // Center dot
                  Container(
                    width: widget.size * 0.2,
                    height: widget.size * 0.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  
                  // Crosshair lines
                  if (widget.isActive) ...[
                    Container(
                      width: widget.size * 0.8,
                      height: 1,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    Container(
                      width: 1,
                      height: widget.size * 0.8,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}