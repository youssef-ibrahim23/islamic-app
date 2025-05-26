import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'SplashScreen.dart';
import 'Home.dart';
import 'Login.dart';
import 'Counter.dart';
import 'SurahP.dart';
import 'duaaP.dart';

bool? languageState = false;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDialogOpen = true;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
  }

  Future<void> _initializeFirebaseMessaging() async {
    try {
      await _requestNotificationPermissions();
      _setupNotificationHandlers();
    } catch (e) {
      print('Error initializing Firebase Messaging: $e');
    }
  }

  Future<void> _requestNotificationPermissions() async {
    try {
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print("Notification permission granted");
      } else {
        print("Notification permission denied");
      }
    } catch (e) {
      print('Error requesting notification permission: $e');
    }
  }

  void _setupNotificationHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundNotification);
    _checkInitialMessage();
  }

  Future<void> _handleForegroundNotification(RemoteMessage message) async {
    try {
      String title = message.notification?.title ?? 'Islamic App';
      String body =
          message.notification?.body ?? 'You have a new notification.';

      if (!_isDialogOpen && mounted) {
        _isDialogOpen = true;
        final double screenWidth = MediaQuery.of(context).size.width;
        AwesomeDialog(
          dialogBackgroundColor: const Color(0xFF0b3d27),
          context: navigatorKey.currentContext!,
          dialogType: DialogType.info,
          title: title,
          titleTextStyle: TextStyle(
              color: Colors.white,
              fontFamily: 'cursive',
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold),
          desc: body,
          descTextStyle: TextStyle(
              color: Colors.white,
              fontFamily: 'cursive',
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold),
          btnCancelOnPress: () {
            _isDialogOpen = false;
          },
          btnOkOnPress: () {
            navigatorKey.currentState
                ?.push(MaterialPageRoute(builder: (context) => AzkarPage()));
            _isDialogOpen = false;
          },
        ).show();
      }
    } catch (e) {
      print('Error handling foreground notification: $e');
    }
  }

  Future<void> _handleBackgroundNotification(RemoteMessage message) async {
    try {
      String type = message.data['Type'] ?? '';
      if (!navigatorKey.currentState!.mounted) {
        print('Navigator not mounted; skipping navigation');
        return;
      }

      if (type == 'Azkar') {
        navigatorKey.currentState
            ?.push(MaterialPageRoute(builder: (context) => AzkarPage()));
      } else if (type == 'Al-Kahf') {
        navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => SurahDetailPage('Al-Kahf', 18, 'الكهف')));
      } else if (type == 'Dhikr') {
        navigatorKey.currentState
            ?.push(MaterialPageRoute(builder: (context) => Counter()));
      } else {
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          navigatorKey.currentState
              ?.push(MaterialPageRoute(builder: (context) => Login_P()));
        } else {
          navigatorKey.currentState
              ?.push(MaterialPageRoute(builder: (context) => HomePage()));
        }
      }
    } catch (e) {
      print('Error handling background notification: $e');
    }
  }

  Future<void> _checkInitialMessage() async {
    try {
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();

      if (initialMessage != null) {
        String type = initialMessage.data['Type'] ?? '';
        if (type == 'Azkar') {
          navigatorKey.currentState
              ?.push(MaterialPageRoute(builder: (context) => AzkarPage()));
        } else if (type == 'Al-Kahf') {
          navigatorKey.currentState?.push(MaterialPageRoute(
              builder: (context) => SurahDetailPage('Al-Kahf', 18, 'الكهف')));
        } else if (type == 'Dhikr') {
          navigatorKey.currentState
              ?.push(MaterialPageRoute(builder: (context) => Counter()));
        } else {
          User? user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            navigatorKey.currentState
                ?.push(MaterialPageRoute(builder: (context) => Login_P()));
          } else {
            navigatorKey.currentState
                ?.push(MaterialPageRoute(builder: (context) => HomePage()));
          }
        }
      }
    } catch (e) {
      print('Error checking initial message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      navigatorKey: navigatorKey, // Attach the global navigator key
      home: SplashScreen(),
    );
  }
}
