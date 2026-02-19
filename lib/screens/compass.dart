import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/compass_service.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/compass/compass_background.dart';
import 'package:islamic_app/widgets/compass/compass_markings.dart';
import 'package:islamic_app/widgets/compass/kaaba_indicator.dart';
import 'package:islamic_app/widgets/compass/qibla_indicator.dart';
import 'package:islamic_app/widgets/compass/center_point.dart';
import 'package:islamic_app/widgets/compass/compass_header.dart';
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
  final double _deviceOrientation = 0;
  bool _isCalibrating = false;
  bool _permissionDenied = false;
  bool _checkingPermission = true;
  bool _showLocationInfo = false;

  Position? _currentPosition;
  double? _storedLatitude;
  double? _storedLongitude;

  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    _checkLocationPermission();
    _startLocationUpdates();
    _loadStoredLocation(); // Load stored location
  }

  Future<void> _loadStoredLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble("lat");
    final lng = prefs.getDouble("lng");

    if (lat != null && lng != null) {
      setState(() {
        _storedLatitude = lat;
        _storedLongitude = lng;
      });
    }
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

  void _startLocationUpdates() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });
  }

  void _showPermissionDeniedDialog() {
    final isEnglish = Globals.languageState!;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: isEnglish ? 'Permission Required' : 'مطلوب إذن',
      desc: isEnglish
          ? 'Location access is required for accurate Qibla direction. Please enable location services.'
          : 'يجب تفعيل خدمات الموقع للحصول على اتجاه القبلة الدقيق.',
      btnCancelText: isEnglish ? 'Cancel' : 'إلغاء',
      btnOkText: isEnglish ? 'Open Settings' : 'فتح الإعدادات',
      btnCancelOnPress: () {},
      btnOkOnPress: () => openAppSettings(),
    ).show();
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
      duration: 800.ms,
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
    _positionStream?.cancel();
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
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: Globals.languageState! ? 'Calibrating' : 'جاري المعايرة',
      desc: Globals.languageState!
          ? 'Please move your device in a figure-8 pattern'
          : 'قم بتحريك الجهاز على شكل رقم 8',
      autoHide: const Duration(seconds: 10),
    ).show().then((_) {
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
          Colors.black.withOpacity(0.8),
          Colors.white.withOpacity(0.1),
        ],
      ),
      image: const DecorationImage(
        image: AssetImage("assets/images/background.jpg"),
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
            color: primaryColor.withOpacity(0.4),
            blurRadius: 25,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -_deviceOrientation * (pi / 180),
            child: CompassBackground(size: compassSize),
          ),
          Transform.rotate(
            angle: -_deviceOrientation * (pi / 180),
            child: CompassMarkings(
                size: compassSize, isEnglish: Globals.languageState!),
          ),
          KaabaIndicator(
              angle: angle + _deviceOrientation, compassSize: compassSize),
          QiblaIndicator(
              angle: angle + _deviceOrientation, compassSize: compassSize),
          const CenterPoint(),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(
          begin: 0.2,
          curve: Curves.easeOutQuad,
        );
  }

  Widget _buildLocationInfo() {
    final lat = _currentPosition?.latitude ?? _storedLatitude;
    final lng = _currentPosition?.longitude ?? _storedLongitude;

    if (lat == null || lng == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Globals.languageState! ? 'Latitude:' : 'خط العرض:',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Text(
                lat.toStringAsFixed(6),
                style: GoogleFonts.poppins(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Globals.languageState! ? 'Longitude:' : 'خط الطول:',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Text(
                lng.toStringAsFixed(6),
                style: GoogleFonts.poppins(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompassContent(bool isEnglish, double compassSize) {
    if (_checkingPermission) {
      return _buildLoadingIndicator(compassSize);
    }

    if (_permissionDenied) {
      return PermissionDeniedWidget(isEnglish: isEnglish);
    }

    return StreamBuilder<QiblahDirection>(
      stream: CompassService.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                FontAwesomeIcons.triangleExclamation,
                color: Colors.amber,
                size: 40,
              ),
              const SizedBox(height: 16),
              Text(
                isEnglish ? 'Error loading compass' : 'خطأ في تحميل البوصلة',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          );
        }

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
                if (_showLocationInfo) _buildLocationInfo(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _startCalibration,
                      icon: const Icon(
                        FontAwesomeIcons.compass,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        isEnglish ? 'Calibrate' : 'معايرة',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showLocationInfo = !_showLocationInfo;
                        });
                      },
                      icon: Icon(
                        _showLocationInfo
                            ? FontAwesomeIcons.locationArrow
                            : FontAwesomeIcons.locationDot,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        isEnglish ? 'Location' : 'الموقع',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
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
