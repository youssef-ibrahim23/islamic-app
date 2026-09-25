// lib/screens/counter_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/counter_services.dart';

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  final CounterService _service = CounterService();
  int _counter = 0;
  bool _isPressed = false;
  bool _isLoading = true;
  bool _isTraditionalStyle = true; // Toggle between traditional and modern

  final Color primaryColor = const Color(0xFF8B0000);
  final Color backgroundColor = const Color(0xFFFAFAFA);
  final Color cardColor = Colors.white;
  final Color textColor = const Color(0xFF333333);
  final Color secondaryTextColor = const Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _service.init();
    _counter = await _service.loadCounter();
    setState(() => _isLoading = false);
  }

  Future<void> _incrementCounter() async {
    setState(() {
      _counter++;
      _isPressed = true;
    });

    await _service.saveCounter(_counter);

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _isPressed = false);
    });
  }

  Future<void> _resetCounter() async {
    setState(() => _counter = 0);
    await _service.saveCounter(_counter);
  }

  // Calculate dynamic font size based on number of digits
  double _getDynamicFontSize(int digitCount, double screenSize) {
    // Base size for 1-3 digits
    if (digitCount <= 3) {
      return screenSize * 0.2;
    }

    // Gradually reduce font size for more digits
    // Formula: baseSize * (3 / digitCount) with minimum size
    final baseSize = screenSize * 0.2;
    final scaleFactor = 3.0 / digitCount;
    final calculatedSize = baseSize * scaleFactor;

    // Ensure minimum readable size (10% of screen size)
    final minSize = screenSize * 0.1;
    return calculatedSize > minSize ? calculatedSize : minSize;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: primaryColor,
        title: Text(
          Globals.languageState! ? "Counter" : "تسابيح",
          style: TextStyle(
            color: Colors.white,
            fontSize: isPortrait ? size.width * 0.06 : size.height * 0.06,
            fontWeight: FontWeight.bold,
            fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
              opacity: 0.9,
            ),
          ),
          child: Column(
            children: [
              // Style toggle buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStyleToggle(
                      title: Globals.languageState!
                          ? 'Traditional'
                          : 'تقليدي',
                      icon: Icons.auto_stories,
                      isSelected: _isTraditionalStyle,
                      onTap: () =>
                          setState(() => _isTraditionalStyle = true),
                    ),
                    const SizedBox(width: 16),
                    _buildStyleToggle(
                      title: Globals.languageState! ? 'Modern' : 'حديث',
                      icon: Icons.donut_large,
                      isSelected: !_isTraditionalStyle,
                      onTap: () =>
                          setState(() => _isTraditionalStyle = false),
                    ),
                  ],
                ),
              ),

              // Counter display based on style
              Expanded(
                child: _isTraditionalStyle
                    ? _buildTraditionalSebha(size, isPortrait)
                    : _buildModernCounter(size, isPortrait),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyleToggle({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : primaryColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : primaryColor,
                fontWeight: FontWeight.bold,
                fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraditionalSebha(Size size, bool isPortrait) {
    return GestureDetector(
      onTap: _incrementCounter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Enhanced Traditional Sebha with string and beads
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer decorative ring
              Container(
                width: isPortrait ? size.width * 0.85 : size.height * 0.85,
                height: isPortrait ? size.width * 0.85 : size.height * 0.85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),

              // Main beads circle with string effect
              Container(
                width: isPortrait ? size.width * 0.8 : size.height * 0.8,
                height: isPortrait ? size.width * 0.8 : size.height * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor.withOpacity(0.4),
                    width: 2,
                  ),
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      primaryColor.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // String lines (subtle)
                    ...List.generate(8, (index) {
                      final angle = (index * 45) * 3.14159 / 180;
                      final radius =
                      (isPortrait ? size.width * 0.38 : size.height * 0.38);
                      final x = radius * cos(angle);
                      final y = radius * sin(angle);

                      return Positioned(
                        left: (isPortrait
                            ? size.width * 0.4
                            : size.height * 0.4) +
                            x -
                            1,
                        top: (isPortrait
                            ? size.width * 0.4
                            : size.height * 0.4) +
                            y -
                            40,
                        child: Container(
                          width: 2,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.brown.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      );
                    }),

                    // Enhanced beads with better positioning
                    ...List.generate(33, (index) {
                      final angle = (index * 10.9) * 3.14159 / 180;
                      final radius =
                      (isPortrait ? size.width * 0.32 : size.height * 0.32);
                      final x = radius * cos(angle);
                      final y = radius * sin(angle);
                      final isFilled = index < _counter % 33;

                      return Positioned(
                        left: (isPortrait
                            ? size.width * 0.4
                            : size.height * 0.4) +
                            x -
                            10,
                        top: (isPortrait
                            ? size.width * 0.4
                            : size.height * 0.4) +
                            y -
                            10,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isFilled
                                ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                primaryColor,
                                primaryColor.withOpacity(0.7),
                              ],
                            )
                                : RadialGradient(
                              center: Alignment(-0.3, -0.3),
                              radius: 0.8,
                              colors: [
                                Colors.white.withOpacity(0.9),
                                primaryColor.withOpacity(0.2),
                              ],
                            ),
                            border: Border.all(
                              color: isFilled
                                  ? primaryColor.withOpacity(0.8)
                                  : primaryColor.withOpacity(0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              if (isFilled)
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.4),
                                  blurRadius: 4,
                                  offset: const Offset(1, 1),
                                ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: isFilled
                              ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          )
                              : null,
                        ),
                      );
                    }),

                    // Enhanced top bead with tassel attachment
                    Positioned(
                      top: (isPortrait ? size.width * 0.4 : size.height * 0.4) -
                          35,
                      left:
                      (isPortrait ? size.width * 0.4 : size.height * 0.4) -
                          15,
                      child: Column(
                        children: [
                          // Tassel string
                          Container(
                            width: 30,
                            height: 15,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.brown.withOpacity(0.6),
                                  Colors.brown.withOpacity(0.3),
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                          ),
                          // Top main bead
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  primaryColor,
                                  primaryColor.withOpacity(0.8),
                                ],
                              ),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.6),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Enhanced bottom bead with tassel
                    Positioned(
                      bottom:
                      (isPortrait ? size.width * 0.4 : size.height * 0.4) -
                          40,
                      left:
                      (isPortrait ? size.width * 0.4 : size.height * 0.4) -
                          20,
                      child: Column(
                        children: [
                          // Bottom main bead
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  primaryColor.withOpacity(0.9),
                                  primaryColor,
                                ],
                              ),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.7),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ),
                          ),
                          // Tassel
                          Container(
                            width: 35,
                            height: 25,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.brown.withOpacity(0.7),
                                  Colors.brown.withOpacity(0.4),
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(17),
                                bottomRight: Radius.circular(17),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.brown.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Tassel strings
                                ...List.generate(5, (index) {
                                  final xOffset = (index - 2) * 6.0;
                                  return Positioned(
                                    left: 17.0 + xOffset,
                                    top: 5.0,
                                    child: Container(
                                      width: 2,
                                      height: 15,
                                      decoration: BoxDecoration(
                                        color: Colors.brown.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Enhanced counter display in center
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.95),
                      Colors.white.withOpacity(0.85),
                    ],
                  ),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.8),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Globals.languageState!
                            ? '$_counter'
                            : Globals.toArabicNumber(_counter.toString()),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontFamily:
                          Globals.languageState! ? 'Roboto' : 'Tajawal',
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 2,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '33',
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryColor.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.04),

          // Enhanced reset button with traditional styling
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextButton(
              onPressed: _resetCounter,
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.12,
                  vertical: size.height * 0.025,
                ),
                backgroundColor: Colors.white.withOpacity(0.9),
              ),
              child: Text(
                Globals.languageState! ? 'Reset' : 'إعادة',
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                  fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCounter(Size size, bool isPortrait) {
    return GestureDetector(
      onTap: _incrementCounter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Modern counter display
          Container(
            width: isPortrait ? size.width * 0.6 : size.height * 0.6,
            height: isPortrait ? size.width * 0.6 : size.height * 0.6,
            decoration: BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 3,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    Globals.languageState!
                        ? '$_counter'
                        : Globals.toArabicNumber(_counter.toString()),
                    style: TextStyle(
                      fontSize: _getDynamicFontSize(
                        _counter.toString().length,
                        isPortrait ? size.width : size.height,
                      ),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).scale(),

          SizedBox(height: size.height * 0.05),

          // Modern increment button
          Container(
            width: isPortrait ? size.width * 0.5 : size.height * 0.5,
            height: isPortrait ? size.width * 0.15 : size.height * 0.15,
            decoration: BoxDecoration(
              color: _isPressed ? primaryColor.withOpacity(0.8) : primaryColor,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                if (!_isPressed)
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: isPortrait ? size.width * 0.1 : size.height * 0.1,
              ),
            ),
          ),

          SizedBox(height: size.height * 0.03),

          // Enhanced reset button with traditional styling (same as traditional)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextButton(
              onPressed: _resetCounter,
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.12,
                  vertical: size.height * 0.025,
                ),
                backgroundColor: Colors.white.withOpacity(0.9),
              ),
              child: Text(
                Globals.languageState! ? 'Reset' : 'إعادة',
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                  fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}