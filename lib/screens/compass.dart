import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/widgets/app_them.dart';

class CompassPage extends StatefulWidget {
  const CompassPage({super.key});

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  late Animation<double> _angleAnimation;
  double _lastQiblahAngle = 0;
  double _currentQiblahAngle = 0;
  bool _isCalibrating = false;

  @override
    @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // <-- Added observer
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _angleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  void _animateCompass(double newAngle) {
    _lastQiblahAngle = _currentQiblahAngle;
    _currentQiblahAngle = newAngle;
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // <-- Remove observer
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Optional: Add handling if needed
    if (state == AppLifecycleState.paused) {
      // Pause sensor or animations if necessary
    } else if (state == AppLifecycleState.resumed) {
      // Resume things
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = Globals.languageState!;
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;
    final compassSize = isPortrait ? size.width * 0.8 : size.height * 0.7;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: _buildBackgroundDecoration(),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isEnglish, isPortrait),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      _buildCompassContent(isEnglish, compassSize),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(0.8),
          Colors.white.withOpacity(0.1),
        ],
      ),
      image: const DecorationImage(
        image: AssetImage("assets/background.jpg"),
        fit: BoxFit.cover,
        opacity: 0.9,
      ),
    );
  }

  Widget _buildHeader(bool isEnglish, bool isPortrait) {
    return Container(
      width: double.infinity,
      height: isPortrait ? 120 : 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.6),
            Colors.transparent,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isEnglish ? 'Qibla Compass' : 'بوصلة القبلة',
            style: TextStyle(
              color: Colors.white,
              fontSize: isPortrait ? 32 : 28,
              fontWeight: FontWeight.bold,
              fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isEnglish ? 'Find the direction to Kaaba' : 'ابحث عن اتجاه الكعبة',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isPortrait ? 16 : 14,
              fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
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
    ).animate().fadeIn().slideY(
          begin: 0.1,
          curve: Curves.easeOutQuad,
        );
  }

  Widget _buildCompassContent(bool isEnglish, double compassSize) {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingIndicator(compassSize);
        }

        final qiblaDirection = snapshot.data!.qiblah;
        if (_currentQiblahAngle != qiblaDirection) {
          _animateCompass(qiblaDirection);
        }

        return AnimatedBuilder(
          animation: _angleAnimation,
          builder: (context, child) {
            final animatedAngle = _lerpDouble(
              _lastQiblahAngle,
              _currentQiblahAngle,
              _angleAnimation.value,
            );

            return Column(
              children: [
                _buildCompass(animatedAngle, compassSize),
                const SizedBox(height: 20),
                _buildDirectionInfoCard(animatedAngle, isEnglish),
                const SizedBox(height: 25),
                _buildCalibrationWidget(isEnglish),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingIndicator(double compassSize) {
    return SizedBox(
      width: compassSize,
      height: compassSize,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          strokeWidth: 4,
        ),
      ),
    );
  }

  Widget _buildCompass(double angle, double compassSize) {
    return Container(
      width: compassSize,
      height: compassSize,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 25,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildCompassBackground(compassSize),
          ..._buildCompassMarkings(compassSize),
          _buildKaabaIndicator(angle, compassSize),
          _buildQiblaIndicator(angle, compassSize),
          _buildCenterPoint(),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(
          begin: 0.2,
          curve: Curves.easeOutQuad,
        );
  }

  Widget _buildCompassBackground(double compassSize) {
    return Container(
      width: compassSize,
      height: compassSize,
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

  Widget _buildKaabaIndicator(double angle, double compassSize) {
    return Transform.rotate(
      angle: angle * (pi / 180) * -1,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: compassSize * 0.05),
          child: _buildKaabaIcon(compassSize * 0.15),
        ),
      ),
    );
  }

  Widget _buildQiblaIndicator(double angle, double compassSize) {
    return Transform.rotate(
      angle: angle * (pi / 180) * -1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: compassSize * 0.35,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
          Container(
            width: compassSize * 0.1,
            height: compassSize * 0.1,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.navigation,
                color: Colors.white,
                size: compassSize * 0.06,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterPoint() {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionInfoCard(double angle, bool isEnglish) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F5EF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
          
        ),
        child: Column(
          children: [
            Text(
              isEnglish ? "Direction to Kaaba" : "اتجاه الكعبة",
              style: TextStyle(
                fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "${angle.toStringAsFixed(1)}° ${_getDirectionName(angle, isEnglish)}",
              style: TextStyle(
                fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(
            begin: 0.2,
            curve: Curves.easeOutQuad,
          ),
    );
  }

  Widget _buildCalibrationWidget(bool isEnglish) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: _isCalibrating
          ? _buildCalibrationMessage(isEnglish)
          : _buildCalibrationButton(isEnglish),
    );
  }

  Widget _buildCalibrationMessage(bool isEnglish) {
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
            isEnglish
                ? "Move your phone in a figure 8 pattern"
                : "حرك هاتفك في شكل رقم 8",
            style: TextStyle(
              color: primaryColor,
              fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
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

  Widget _buildCalibrationButton(bool isEnglish) {
    return TextButton(
      onPressed: _startCalibration,
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
        isEnglish ? "Calibrate Compass" : "معايرة البوصلة",
        style: TextStyle(
          color: primaryColor,
          fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
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

  void _startCalibration() {
    setState(() => _isCalibrating = true);
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) setState(() => _isCalibrating = false);
    });
  }

  String _getDirectionName(double degrees, bool isEnglish) {
    if (degrees >= 337.5 || degrees < 22.5) {
      return isEnglish ? "North" : "شمال";
    } else if (degrees >= 22.5 && degrees < 67.5) {
      return isEnglish ? "Northeast" : "شمال شرق";
    } else if (degrees >= 67.5 && degrees < 112.5) {
      return isEnglish ? "East" : "شرق";
    } else if (degrees >= 112.5 && degrees < 157.5) {
      return isEnglish ? "Southeast" : "جنوب شرق";
    } else if (degrees >= 157.5 && degrees < 202.5) {
      return isEnglish ? "South" : "جنوب";
    } else if (degrees >= 202.5 && degrees < 247.5) {
      return isEnglish ? "Southwest" : "جنوب غرب";
    } else if (degrees >= 247.5 && degrees < 292.5) {
      return isEnglish ? "West" : "غرب";
    } else {
      return isEnglish ? "Northwest" : "شمال غرب";
    }
  }

  Widget _buildKaabaIcon(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF5D4037),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 20,
            spreadRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF8D6E63),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Kaaba structure
          Container(
            width: size * 0.8,
            height: size * 0.8,
            decoration: BoxDecoration(
              color: const Color(0xFF3E2723),
              border: Border.all(
                color: Colors.grey[800]!,
                width: 2,
              ),
            ),
          ),
          // Kaaba door
          Positioned(
            bottom: size * 0.15,
            child: Container(
              width: size * 0.3,
              height: size * 0.4,
              decoration: BoxDecoration(
                color: const Color(0xFF5D4037),
                border: Border.all(
                  color: Colors.grey[700]!,
                  width: 1.5,
                ),
              ),
            ),
          ),
          // Kaaba text
          Positioned(
            top: size * 0.1,
            child: Text(
              "🕋",
              style: TextStyle(fontSize: size * 0.5, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCompassMarkings(double size) {
    const List<String> directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
    const List<String> arabicDirections = ["ش", "ش ق", "ق", "ج ق", "ج", "ج غ", "غ", "ش غ"];
    final bool isEnglish = Globals.languageState!;

    List<Widget> markings = [];

    // Cardinal directions
    for (int i = 0; i < 360; i += 45) {
      final isCardinal = i % 45 == 0;
      final index = i ~/ 45;

      markings.add(
        Transform.rotate(
          angle: i * pi / 180,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: isCardinal
                  ? Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: i == 0 ? Colors.red.withOpacity(0.3) : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        isEnglish ? directions[index] : arabicDirections[index],
                        style: TextStyle(
                          fontSize: isCardinal ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: i == 0 ? Colors.red : primaryColor,
                          shadows: i == 0
                              ? [
                                  Shadow(
                                    blurRadius: 5,
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(1, 1),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    )
                  : Container(
                      width: 2.5,
                      height: 18,
                      color: primaryColor.withOpacity(0.8),
                    ),
            ),
          ),
        ),
      );
    }

    // Degree markings
    for (int i = 0; i < 360; i += 10) {
      if (i % 45 == 0) continue; // Skip cardinal directions

      markings.add(
        Transform.rotate(
          angle: i * pi / 180,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Container(
                width: 1.5,
                height: i % 30 == 0 ? 15 : 10,
                color: primaryColor.withOpacity(i % 30 == 0 ? 0.8 : 0.6),
              ),
            ),
          ),
        ),
      );
    }

    return markings;
  }

  double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}