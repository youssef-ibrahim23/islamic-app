import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/location.dart';
import 'package:islamic_app/widgets/app_them.dart';

class DropDown {

  static Widget buildCountryDropdown({
    required bool isEnglish,
    required String? selectedCountry,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  isEnglish ? 'Select Country' : 'اختر الدولة',
                  style: GoogleFonts.getFont(
                    'Scheherazade New',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCountry,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: Location().arabCountries.keys.map((String country) {
                return DropdownMenuItem<String>(
                  value: country,
                  child: Text(
                    country,
                    style: GoogleFonts.getFont('Scheherazade New', fontSize: 16),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              hint: Text(
                isEnglish ? 'Choose your country' : 'اختر دولتك',
                style: GoogleFonts.getFont('Scheherazade New'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildGovernorateDropdown({
    required bool isEnglish,
    required String selectedCountry,
    required String? selectedGovernorate,
    required ValueChanged<String?> onChanged,
  }) {
    final governorates = Location().arabCountries[selectedCountry] ?? [];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_city, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  isEnglish ? 'Select City/Governorate' : 'اختر المدينة / المحافظة',
                  style: GoogleFonts.getFont(
                    'Scheherazade New',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedGovernorate,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: governorates.map((String governorate) {
                return DropdownMenuItem<String>(
                  value: governorate,
                  child: Text(
                    governorate,
                    style: GoogleFonts.getFont('Scheherazade New', fontSize: 16),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              hint: Text(
                isEnglish ? 'Choose your city' : 'اختر مدينتك',
                style: GoogleFonts.getFont('Scheherazade New'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
