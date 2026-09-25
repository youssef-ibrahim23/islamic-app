import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/date_services.dart';

void main() {
  print('=== Regional Hijri Date Test ===');

  // Test with Saudi Arabia (no adjustment)
  Globals.selectedCountry = 'Saudi Arabia';
  final saudiHijri = DateService.getCurrentHijriDate();
  print('Saudi Arabia: $saudiHijri');

  // Test with Egypt (-1 day adjustment)
  Globals.selectedCountry = 'Egypt';
  final egyptHijri = DateService.getCurrentHijriDate();
  print('Egypt: $egyptHijri');

  // Test with UAE (no adjustment)
  Globals.selectedCountry = 'UAE';
  final uaeHijri = DateService.getCurrentHijriDate();
  print('UAE: $uaeHijri');

  // Test with default (no country selected)
  Globals.selectedCountry = null;
  final defaultHijri = DateService.getCurrentHijriDate();
  print('Default (no country): $defaultHijri');

  print('=== Test Complete ===');
}
