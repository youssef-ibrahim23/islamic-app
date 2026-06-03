import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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
import 'package:islamic_app/location.dart';

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
  bool _checkingPermission = false; // Changed to false - no loading
  bool _showLocationInfo = false;
  bool _compassSensorAvailable = false;
  bool _sensorChecked = false;
  bool _compassError = false;
  bool _isCalculatingQibla = false; // Add Qibla calculation state

  Position? _currentPosition;
  double? _storedLatitude;
  double? _storedLongitude;
  String? _placeName;
  bool _isLoadingLocation = false;

  StreamSubscription<Position>? _positionStream;
  StreamSubscription<QiblahDirection>? _qiblahSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    _checkCompassSensor();
    _checkLocationPermission();
    _startLocationUpdates();
    _loadStoredLocation(); // Load stored location

    // Show calculating dialog after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCalculatingQiblaDialog();
    });
  }

  Future<void> _checkCompassSensor() async {
    try {
      // Check if compass sensor is available by trying to get Qiblah direction
      _qiblahSubscription = CompassService.qiblahStream.listen(
        (QiblahDirection direction) {
          if (!_sensorChecked) {
            setState(() {
              _compassSensorAvailable = true;
              _sensorChecked = true;
            });
            // Hide calculating dialog when Qibla is calculated
            _hideCalculatingQiblaDialog();
            _qiblahSubscription?.cancel();
            _qiblahSubscription = null;
          }
        },
        onError: (error) {
          if (!_sensorChecked) {
            setState(() {
              _compassSensorAvailable = false;
              _compassError = true;
              _sensorChecked = true;
            });
            // Hide calculating dialog even on error
            _hideCalculatingQiblaDialog();
            _qiblahSubscription?.cancel();
            _qiblahSubscription = null;
          }
        },
      );

      // Note: We no longer use a timeout to assume sensor is unavailable.
      // Some devices take longer to initialize - we only mark sensor as
      // unavailable if the stream emits an actual error, not on timeout.
      // The calculating dialog will be dismissed when data arrives or on error.
    } catch (e) {
      setState(() {
        _compassSensorAvailable = false;
        _compassError = true;
        _sensorChecked = true;
      });
      // Hide calculating dialog on error
      _hideCalculatingQiblaDialog();
    }
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
    _showPermissionDialog(isEnglish);
  }

  Future<void> _showPermissionDialog(bool isEnglish) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(minHeight: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Decorative pattern
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -15,
                  left: -15,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),

                // Main content
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with icon and title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.locationDot,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              isEnglish
                                  ? 'Location Required'
                                  : 'مطلوب إذن الموقع',
                              style: GoogleFonts.getFont(
                                isEnglish ? 'Roboto' : 'Tajawal',
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Colors.white24),
                      const SizedBox(height: 20),

                      // Message content
                      Text(
                        isEnglish
                            ? 'Location access is required for accurate Qibla direction. Please enable location services in your device settings.'
                            : 'يجب تفعيل خدمات الموقع للحصول على اتجاه القبلة الدقيق. يرجى تفعيل الموقع في إعدادات الجهاز.',
                        style: GoogleFonts.getFont(
                          isEnglish ? 'Roboto' : 'Tajawal',
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 2,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: Text(
                                  isEnglish ? 'Cancel' : 'إلغاء',
                                  style: GoogleFonts.getFont(
                                    isEnglish ? 'Roboto' : 'Tajawal',
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  openAppSettings();
                                },
                                child: Text(
                                  isEnglish ? 'Open Settings' : 'فتح الإعدادات',
                                  style: GoogleFonts.getFont(
                                    isEnglish ? 'Roboto' : 'Tajawal',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Auto-dismiss indicator
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scaleXY(
                          begin: 1.0,
                          end: 0.3,
                          duration: 2000.ms,
                          curve: Curves.easeInOut)
                      .then()
                      .scaleXY(
                          begin: 0.3,
                          end: 1.0,
                          duration: 2000.ms,
                          curve: Curves.easeInOut),
                ),
              ],
            ),
          )
              .animate()
              .slideY(
                  begin: 1.0,
                  end: 0.0,
                  duration: 500.ms,
                  curve: Curves.elasticOut)
              .fadeIn(duration: 500.ms),
        );
      },
    );
  }

  void _showCalculatingQiblaDialog() {
    final isEnglish = Globals.languageState!;

    // Set calculating state
    setState(() {
      _isCalculatingQibla = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(minHeight: 120),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Decorative pattern
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -15,
                  left: -15,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),

                // Main content
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon with animation
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          FontAwesomeIcons.compass,
                          color: Colors.white,
                          size: 28,
                        ),
                      )
                          .animate()
                          .scale(delay: 200.ms, duration: 300.ms)
                          .then()
                          .shimmer(
                              delay: 600.ms,
                              duration: 1000.ms,
                              color: Colors.white.withOpacity(0.3)),

                      const SizedBox(height: 16),

                      // Title and message
                      Column(
                        children: [
                          Text(
                            isEnglish
                                ? 'Calculating Qibla Direction'
                                : 'حساب اتجاه القبلة',
                            style: GoogleFonts.getFont(
                              isEnglish ? 'Roboto' : 'Tajawal',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                          const SizedBox(height: 8),
                          Text(
                            isEnglish
                                ? 'Please wait while we determine the direction of Kaaba'
                                : 'يرجى الانتظار بينما نحدد اتجاه الكعبة',
                            style: GoogleFonts.getFont(
                              isEnglish ? 'Roboto' : 'Tajawal',
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Loading indicator
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 20,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                              .animate()
                              .slideX(
                                  begin: -1.0,
                                  end: 1.0,
                                  duration: 1500.ms,
                                  curve: Curves.easeInOut)
                              .then()
                              .slideX(
                                  begin: 1.0,
                                  end: -1.0,
                                  duration: 1500.ms,
                                  curve: Curves.easeInOut),
                        ),
                      ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate()
              .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 500.ms),
        );
      },
    );
  }

  void _hideCalculatingQiblaDialog() {
    if (_isCalculatingQibla && mounted) {
      Navigator.of(context).pop();
      setState(() {
        _isCalculatingQibla = false;
      });
    }
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
    _positionStream?.cancel();
    _qiblahSubscription?.cancel();
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
    _showCalibrationDialog();
  }

  Future<void> _showCalibrationDialog() async {
    final isEnglish = Globals.languageState!;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(minHeight: 280),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Decorative pattern
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -15,
                  left: -15,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),

                // Main content
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with icon and title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.compass,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              isEnglish
                                  ? 'Calibrating Compass'
                                  : 'معايرة البوصلة',
                              style: GoogleFonts.getFont(
                                isEnglish ? 'Roboto' : 'Tajawal',
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Colors.white24),
                      const SizedBox(height: 20),

                      // Message content with animation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            FontAwesomeIcons.arrowsRotate,
                            color: Colors.white,
                            size: 32,
                          )
                              .animate(
                                onPlay: (controller) => controller.repeat(),
                              )
                              .rotate(
                                duration: 2000.ms,
                                curve: Curves.linear,
                              ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              isEnglish
                                  ? 'Move your device in a figure-8 pattern to calibrate the compass'
                                  : 'قم بتحريك الجهاز على شكل رقم 8 لمعايرة البوصلة',
                              style: GoogleFonts.getFont(
                                isEnglish ? 'Roboto' : 'Tajawal',
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.6,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 2,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Auto-dismiss indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isEnglish
                              ? 'Auto-dismissing in 10 seconds...'
                              : 'إغلاق تلقائي بعد 10 ثواني...',
                          style: GoogleFonts.getFont(
                            isEnglish ? 'Roboto' : 'Tajawal',
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Close button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            setState(() => _isCalibrating = false);
                          },
                          child: Text(
                            isEnglish ? 'Close' : 'إغلاق',
                            style: GoogleFonts.getFont(
                              isEnglish ? 'Roboto' : 'Tajawal',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Auto-dismiss indicator
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scaleXY(
                          begin: 1.0,
                          end: 0.3,
                          duration: 2000.ms,
                          curve: Curves.easeInOut)
                      .then()
                      .scaleXY(
                          begin: 0.3,
                          end: 1.0,
                          duration: 2000.ms,
                          curve: Curves.easeInOut),
                ),
              ],
            ),
          )
              .animate()
              .slideY(
                  begin: 1.0,
                  end: 0.0,
                  duration: 500.ms,
                  curve: Curves.elasticOut)
              .fadeIn(duration: 500.ms),
        );
      },
    ).then((_) {
      setState(() => _isCalibrating = false);
    });
  }

  Future<String?> _getPlaceName(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final country = placemark.country ?? '';
        final locality = placemark.locality ?? '';
        final administrativeArea = placemark.administrativeArea ?? '';
        final subAdministrativeArea = placemark.subAdministrativeArea ?? '';
        final isEnglish = Globals.languageState!;

        // Try to find matching location in Locations class
        String? translatedPlaceName;

        // Check if we have a matching governorate in our Locations data
        final arabCountries = Locations.arabCountriesEnglish;

        // Try to match by locality first
        if (locality.isNotEmpty) {
          for (final entry in arabCountries.entries) {
            final countryName = entry.key;
            final governorates = entry.value;

            // Find matching governorate (case-insensitive)
            final matchingGov = governorates.firstWhere(
              (gov) => gov.toLowerCase() == locality.toLowerCase(),
              orElse: () => '',
            );

            if (matchingGov.isNotEmpty) {
              if (!isEnglish) {
                // Get Arabic translation
                final arabicGov = Locations.englishGovernorateToArabic(
                    countryName, matchingGov);
                if (arabicGov != null) {
                  translatedPlaceName = arabicGov;
                  break;
                }
              } else {
                translatedPlaceName = matchingGov;
                break;
              }
            }
          }
        }

        // If no match found, try administrative area
        if (translatedPlaceName == null && administrativeArea.isNotEmpty) {
          for (final entry in arabCountries.entries) {
            final countryName = entry.key;
            final governorates = entry.value;

            final matchingGov = governorates.firstWhere(
              (gov) => gov.toLowerCase() == administrativeArea.toLowerCase(),
              orElse: () => '',
            );

            if (matchingGov.isNotEmpty) {
              if (!isEnglish) {
                final arabicGov = Locations.englishGovernorateToArabic(
                    countryName, matchingGov);
                if (arabicGov != null) {
                  translatedPlaceName = arabicGov;
                  break;
                }
              } else {
                translatedPlaceName = matchingGov;
                break;
              }
            }
          }
        }

        // If still no match, use geocoding result with possible country translation
        if (translatedPlaceName == null) {
          final parts = [
            locality,
            subAdministrativeArea,
            administrativeArea,
            country,
          ].where((part) => part.isNotEmpty).toList();

          if (parts.isNotEmpty) {
            // Try to translate country name
            String finalCountry = country;
            if (!isEnglish && country.isNotEmpty) {
              final arabicCountry = Locations.arabicCountryFromEnglish(country);
              if (arabicCountry != country) {
                finalCountry = arabicCountry;
              }
            }

            translatedPlaceName = parts.map((part) {
              if (part == country && finalCountry != country) {
                return finalCountry;
              }
              return part;
            }).join(', ');
          }
        }

        return translatedPlaceName;
      }
    } catch (e) {
      print('Error getting place name: $e');
    }
    return null;
  }

  Future<void> _showLocationDialog() async {
    final lat = _currentPosition?.latitude ?? _storedLatitude;
    final lng = _currentPosition?.longitude ?? _storedLongitude;
    final isEnglish = Globals.languageState!;

    if (lat == null || lng == null) return;

    setState(() => _isLoadingLocation = true);

    final placeName = await _getPlaceName(lat, lng);

    if (!mounted) return;
    setState(() => _isLoadingLocation = false);

    await _showBeautifulLocationDialog(isEnglish, lat, lng, placeName);
  }

  Future<void> _showBeautifulLocationDialog(
      bool isEnglish, double lat, double lng, String? placeName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(minHeight: 320),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Decorative pattern
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -15,
                  left: -15,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),

                // Main content
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with icon and title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.mapLocationDot,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              isEnglish
                                  ? 'Location Information'
                                  : 'معلومات الموقع',
                              style: GoogleFonts.getFont(
                                isEnglish ? 'Roboto' : 'Tajawal',
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Colors.white24),
                      const SizedBox(height: 20),

                      // Place name
                      if (placeName != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                isEnglish ? 'Place' : 'المكان',
                                style: GoogleFonts.getFont(
                                  isEnglish ? 'Roboto' : 'Tajawal',
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                placeName,
                                style: GoogleFonts.getFont(
                                  isEnglish ? 'Roboto' : 'Tajawal',
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 2,
                                      offset: const Offset(1, 1),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Coordinates
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isEnglish ? 'Latitude' : 'خط العرض',
                                  style: GoogleFonts.getFont(
                                    isEnglish ? 'Roboto' : 'Tajawal',
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  lat.toStringAsFixed(6),
                                  style: GoogleFonts.getFont(
                                    isEnglish ? 'Roboto' : 'Tajawal',
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 2,
                                        offset: const Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isEnglish ? 'Longitude' : 'خط الطول',
                                  style: GoogleFonts.getFont(
                                    isEnglish ? 'Roboto' : 'Tajawal',
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  lng.toStringAsFixed(6),
                                  style: GoogleFonts.getFont(
                                    isEnglish ? 'Roboto' : 'Tajawal',
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 2,
                                        offset: const Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Close button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(
                            isEnglish ? 'Close' : 'إغلاق',
                            style: GoogleFonts.getFont(
                              isEnglish ? 'Roboto' : 'Tajawal',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Auto-dismiss indicator
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scaleXY(
                          begin: 1.0,
                          end: 0.3,
                          duration: 2000.ms,
                          curve: Curves.easeInOut)
                      .then()
                      .scaleXY(
                          begin: 0.3,
                          end: 1.0,
                          duration: 2000.ms,
                          curve: Curves.easeInOut),
                ),
              ],
            ),
          )
              .animate()
              .slideY(
                  begin: 1.0,
                  end: 0.0,
                  duration: 500.ms,
                  curve: Curves.elasticOut)
              .fadeIn(duration: 500.ms),
        );
      },
    );
  }

  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

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
            color: primaryColor.withOpacity(0.8),
            blurRadius: 5,
            spreadRadius: 2,
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

  Widget _buildSensorUnavailableMessage(bool isEnglish) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withOpacity(0.8),
            Colors.red.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning icon
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              FontAwesomeIcons.triangleExclamation,
              color: Colors.white,
              size: 40,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scaleXY(
                  begin: 1.0,
                  end: 1.2,
                  duration: 1000.ms,
                  curve: Curves.easeInOut)
              .then()
              .scaleXY(
                  begin: 1.2,
                  end: 1.0,
                  duration: 1000.ms,
                  curve: Curves.easeInOut),
          const SizedBox(height: 20),

          // Title
          Text(
            isEnglish
                ? 'Compass Sensor Not Available'
                : 'مستشعر البوصلة غير متوفر',
            style: GoogleFonts.getFont(
              isEnglish ? 'Roboto' : 'Tajawal',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),

          // Message
          Text(
            isEnglish
                ? 'Your device does not have a compass sensor. The compass functionality requires a magnetic sensor to determine Qibla direction accurately.'
                : 'جهازك لا يحتوي على مستشعر بوصلة. تتطلب وظيفة البوصلة مستشعرًا مغناطيسيًا لتحديد اتجاه القبلة بدقة.',
            style: GoogleFonts.getFont(
              isEnglish ? 'Roboto' : 'Tajawal',
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              height: 1.6,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Alternative suggestion
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  isEnglish ? 'Alternative:' : 'بديل:',
                  style: GoogleFonts.getFont(
                    isEnglish ? 'Roboto' : 'Tajawal',
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isEnglish
                      ? 'Use the sun position or a physical compass to find Qibla direction. You can still access location information.'
                      : 'استخدم موقع الشمس أو بوصلة مادية للعثور على اتجاه القبلة. لا يزال بإمكانك الوصول إلى معلومات الموقع.',
                  style: GoogleFonts.getFont(
                    isEnglish ? 'Roboto' : 'Tajawal',
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Location button (still available)
          ElevatedButton.icon(
            onPressed: _showLocationDialog,
            icon: Icon(
              _isLoadingLocation
                  ? FontAwesomeIcons.spinner
                  : FontAwesomeIcons.locationDot,
              size: 16,
              color: Colors.white,
            )
                .animate(
                  onPlay: (controller) => _isLoadingLocation
                      ? controller.repeat()
                      : controller.stop(),
                )
                .rotate(
                  duration: _isLoadingLocation ? 1000.ms : 0.ms,
                  curve: Curves.linear,
                ),
            label: Text(
              isEnglish ? 'View Location' : 'عرض الموقع',
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
    )
        .animate()
        .slideY(
            begin: 0.3, end: 0.0, duration: 600.ms, curve: Curves.elasticOut)
        .fadeIn(duration: 600.ms);
  }

  Widget _buildCompassContent(bool isEnglish, double compassSize) {
    // Show sensor unavailable message if compass sensor is not available
    if (_sensorChecked && !_compassSensorAvailable) {
      return _buildSensorUnavailableMessage(isEnglish);
    }

    if (_checkingPermission) {
      return _buildLoadingIndicator(compassSize);
    }

    if (_permissionDenied) {
      return PermissionDeniedWidget(isEnglish: isEnglish);
    }

    // Always show compass immediately with default angle if no data yet
    return StreamBuilder<QiblahDirection>(
      stream: CompassService.qiblahStream,
      builder: (context, snapshot) {
        double qiblaDirection = _currentQiblahAngle;

        if (snapshot.hasData) {
          qiblaDirection = snapshot.data!.qiblah;
          if (_currentQiblahAngle != qiblaDirection) {
            _animateCompass(qiblaDirection);
          }
        } else if (snapshot.hasError) {
          // Keep showing current angle even on error
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
                      onPressed: _showLocationDialog,
                      icon: Icon(
                        _isLoadingLocation
                            ? FontAwesomeIcons.spinner
                            : FontAwesomeIcons.locationDot,
                        size: 16,
                        color: Colors.white,
                      )
                          .animate(
                            onPlay: (controller) => _isLoadingLocation
                                ? controller.repeat()
                                : controller.stop(),
                          )
                          .rotate(
                            duration: _isLoadingLocation ? 1000.ms : 0.ms,
                            curve: Curves.linear,
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.8),
              Colors.white.withOpacity(0.1),
            ],
          ),
          image: const DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
            opacity: 0.9,
          ),
        ),
        child: Column(
          children: [
            CompassHeader(isEnglish: isEnglish, isPortrait: isPortrait),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCompassContent(isEnglish, compassSize),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
