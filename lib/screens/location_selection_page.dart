// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/services/location_services.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/location.dart';
import 'package:islamic_app/widgets/location/drop_down.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  bool isLoading = false;

  Future<void> _loadInitialSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCountryEn = prefs.getString('countryEnglish');
    final savedGovEn = prefs.getString('governorateEnglish');

    final countryToUse = Globals.selectedCountry ?? savedCountryEn;
    final govToUse = Globals.selectedGovernorate ?? savedGovEn;

    if (!mounted) return;
    setState(() {
      if (countryToUse != null && availableCountries.contains(countryToUse)) {
        Globals.selectedCountry = countryToUse;
        Globals.showGovernorates = true;
      } else {
        Globals.selectedCountry = null;
        Globals.showGovernorates = false;
      }

      if (Globals.selectedCountry == null) {
        Globals.selectedGovernorate = null;
      } else {
        final govs = Locations.arabCountriesEnglish[Globals.selectedCountry!] ??
            <String>[];
        Globals.selectedGovernorate =
            (govToUse != null && govs.contains(govToUse)) ? govToUse : null;
      }
    });
  }

  // Only show Saudi Arabia and Egypt
  static const List<String> availableCountries = ['Saudi Arabia', 'Egypt'];

  // Timezone mapping for each country
  static const Map<String, String> countryTimezones = {
    'Saudi Arabia': 'Asia/Riyadh',
    'Egypt': 'Africa/Cairo',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialSelection();
    });
  }

  @override
  void dispose() {
    // Clear any pending state changes
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = Globals.languageState!;
    final TextDirection textDirection =
        isEnglish ? TextDirection.ltr : TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEnglish ? 'Select Location' : 'اختر الموقع',
          style: GoogleFonts.getFont(
            'Scheherazade New',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: textDirection,
        child: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withOpacity(0.1),
                secondaryColor.withOpacity(0.3),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      const Icon(Icons.location_on,
                          size: 60, color: primaryColor),
                      const SizedBox(height: 16),
                      Text(
                        isEnglish
                            ? 'Please select your country to get accurate prayer times'
                            : 'الرجاء تحديد دولتك للحصول على أوقات الصلاة الدقيقة',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.getFont(
                          'Scheherazade New',
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                // Country Dropdown with limited options
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.flag, color: primaryColor),
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
                          value: Globals.selectedCountry,
                          isExpanded: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: primaryColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          items: availableCountries.map((String country) {
                            return DropdownMenuItem<String>(
                              value: country,
                              child: Text(
                                isEnglish
                                    ? country
                                    : _getArabicCountryName(country),
                                style: GoogleFonts.getFont('Scheherazade New',
                                    fontSize: 16),
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              Globals.selectedCountry = newValue;
                              Globals.selectedGovernorate = null;
                              Globals.showGovernorates = true;
                            });
                          },
                          hint: Text(
                            isEnglish ? 'Choose your country' : 'اختر دولتك',
                            style: GoogleFonts.getFont('Scheherazade New'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Governorate Dropdown (only if country selected)
                if (Globals.showGovernorates && Globals.selectedCountry != null)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: DropDown.buildGovernorateDropdown(
                      isEnglish: isEnglish,
                      selectedCountry: Globals.selectedCountry!,
                      selectedGovernorate: (Locations.arabCountriesEnglish[
                                      Globals.selectedCountry!] ??
                                  <String>[])
                              .contains(Globals.selectedGovernorate)
                          ? Globals.selectedGovernorate
                          : null,
                      onChanged: (newValue) {
                        setState(() {
                          Globals.selectedGovernorate = newValue;
                        });
                      },
                    ),
                  ),

                const Spacer(),

                // Continue Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 4,
                      shadowColor: primaryColor.withOpacity(0.3),
                    ),
                    onPressed: () async {
                      if (Globals.selectedCountry == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEnglish
                                  ? 'Please select a country'
                                  : 'الرجاء اختيار دولة',
                              style: GoogleFonts.getFont('Scheherazade New'),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() => isLoading = true);
                      try {
                        // Set timezone based on selected country
                        await _setTimezoneForCountry(Globals.selectedCountry!);

                        await LocationService.saveLocation(
                          country: Globals.selectedCountry!,
                          governorate: Globals.selectedGovernorate ?? 'Default',
                        );

                        // Set flag to indicate we're coming from location selection
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool(
                            'comingFromLocationSelection', true);

                        if (!mounted) return;

                        // Return true to indicate location was saved successfully
                        Navigator.pop(context, true);
                        setState(() {});
                      } finally {
                        if (mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isEnglish ? 'Change Location' : 'تغيير الموقع',
                            style: GoogleFonts.getFont(
                              'Scheherazade New',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getArabicCountryName(String englishCountry) {
    switch (englishCountry) {
      case 'Saudi Arabia':
        return 'السعودية';
      case 'Egypt':
        return 'مصر';
      default:
        return englishCountry;
    }
  }

  Future<void> _setTimezoneForCountry(String country) async {
    try {
      final timezone = countryTimezones[country];
      if (timezone != null) {
        print('🔍 Setting timezone for $country to $timezone');
        // Note: In a real app, you would use timezone package to set the timezone
        // For now, this is just logging the intended timezone
      }
    } catch (e) {
      print('❌ Error setting timezone: $e');
    }
  }
}
