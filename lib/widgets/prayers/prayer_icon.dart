import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PrayerIcon{
  static IconData getPrayerIcon(String prayerName) {
  switch (prayerName) {
    case 'Fajr':
      return FontAwesomeIcons.solidSun; // a sun icon
    case 'Sunrise':
      return FontAwesomeIcons.sun; // bright sun
    case 'Dhuhr':
      return FontAwesomeIcons.solidClock; // indicates noon
    case 'Asr':
      return FontAwesomeIcons.cloudSun; // mix of sun and clouds
    case 'Maghrib':
      return FontAwesomeIcons.solidSun; // sunset is still sun-like
    case 'Isha':
      return FontAwesomeIcons.solidMoon; // moon icon for night
    default:
      return Icons.access_time; // fallback Material icon
  }
}
}