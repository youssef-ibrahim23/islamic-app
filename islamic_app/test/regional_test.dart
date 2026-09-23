import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/date_services.dart';

void main() {
  print('=== Testing Regional Hijri Date Adjustment ===');
  
  // Test 1: No country selected (should show standard calculation)
  Globals.selectedCountry = null;
  final defaultDate = DateService.getCurrentHijriDate();
  print('No country selected: $defaultDate');
  
  // Test 2: Saudi Arabia (no adjustment - reference)
  Globals.selectedCountry = 'Saudi Arabia';
  final saudiDate = DateService.getCurrentHijriDate();
  print('Saudi Arabia: $saudiDate');
  
  // Test 3: Egypt (-1 day adjustment)
  Globals.selectedCountry = 'Egypt';
  final egyptDate = DateService.getCurrentHijriDate();
  print('Egypt: $egyptDate');
  
  // Test 4: UAE (no adjustment)
  Globals.selectedCountry = 'UAE';
  final uaeDate = DateService.getCurrentHijriDate();
  print('UAE: $uaeDate');
  
  // Test 5: Check adjustment values
  print('\n=== Adjustment Values ===');
  print('Saudi Arabia adjustment: ${Globals.hijriDateAdjustment}');
  Globals.selectedCountry = 'Egypt';
  print('Egypt adjustment: ${Globals.hijriDateAdjustment}');
  Globals.selectedCountry = 'UAE';
  print('UAE adjustment: ${Globals.hijriDateAdjustment}');
  
  print('\n=== Test Complete ===');
  print('If you are in Egypt, the app should now show 7 Ramadan instead of 8 Ramadan.');
}
