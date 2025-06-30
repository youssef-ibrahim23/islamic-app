import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/compass_service.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/compass/compass_background.dart';
import 'package:islamic_app/widgets/compass/compass_markings.dart';
import 'package:islamic_app/widgets/compass/kaaba_indicator.dart';
import 'package:islamic_app/widgets/compass/qibla_indicator.dart';
import 'package:islamic_app/widgets/compass/center_point.dart';
import 'package:islamic_app/widgets/compass/compass_header.dart';
import 'package:islamic_app/widgets/compass/direction_info_card.dart';
import 'package:islamic_app/widgets/compass/calibration_widget.dart';
import 'package:islamic_app/widgets/compass/permission_denied_widget.dart';

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
  bool _permissionDenied = false;
  bool _checkingPermission = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    if (!mounted) return;
    
    setState(() {
      _checkingPermission = true;
      _permissionDenied = false;
    });

    try {
      final status = await Permission.location.status;

      if (status.isGranted) {
        
        _initializeCompass();
      } else {
        final result = await Permission.location.request();
        if (result.isGranted) {
          
          _initializeCompass();
        } else {
          
          if (!mounted) return;
          setState(() {
            _permissionDenied = true;
            _checkingPermission = false;
          });

          if (await Permission.location.isPermanentlyDenied) {
            _showPermissionDeniedDialog();
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _permissionDenied = true;
        _checkingPermission = false;
      });
    } finally {
      if (_checkingPermission && mounted) {
        setState(() => _checkingPermission = false);
      }
    }
  }

  Future<void> _showPermissionDeniedDialog() async {
    final isEnglish = Globals.languageState!;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEnglish ? 'Permission Required' : 'مطلوب إذن'),
        content: Text(
          isEnglish
              ? 'Location access is permanently denied. Please open app settings and enable location permission.'
              : 'تم رفض إذن الموقع نهائيًا. يرجى فتح إعدادات التطبيق وتمكين إذن الموقع.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isEnglish ? 'Cancel' : 'إلغاء'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: Text(isEnglish ? 'Open Settings' : 'فتح الإعدادات'),
          ),
        ],
      ),
    );
  }

  void _initializeCompass() {
    if (!mounted) return;
    setState(() {
      _permissionDenied = false;
      _checkingPermission = false;
    });
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
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  void _startCalibration() {
    setState(() => _isCalibrating = true);
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) setState(() => _isCalibrating = false);
    });
  }

  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

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
          CompassBackground(size: compassSize),
          CompassMarkings(size: compassSize, isEnglish: Globals.languageState!),
          KaabaIndicator(angle: angle, compassSize: compassSize),
          QiblaIndicator(angle: angle, compassSize: compassSize),
          const CenterPoint(),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(
          begin: 0.2,
          curve: Curves.easeOutQuad,
        );
  }

  Widget _buildCompassContent(bool isEnglish, double compassSize) {
    if (_checkingPermission) {
      return _buildLoadingIndicator(compassSize);
    }

    if (_permissionDenied) {
       return PermissionDeniedWidget(
    isEnglish: isEnglish,
    
  );
    }

    return StreamBuilder<QiblahDirection>(
      stream: CompassService.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              isEnglish ? 'Error loading compass' : 'خطأ في تحميل البوصلة',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        if (!snapshot.hasData) {
           return PermissionDeniedWidget(
    isEnglish: isEnglish,
    
  );
          
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
                DirectionInfoCard(angle: animatedAngle, isEnglish: isEnglish),
                const SizedBox(height: 25),
                CalibrationWidget(
                  isEnglish: isEnglish,
                  isCalibrating: _isCalibrating,
                  onCalibrate: _startCalibration,
                ),
              ],
            );
          },
        );
      },
    );
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
              CompassHeader(isEnglish: isEnglish, isPortrait: isPortrait),
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
}