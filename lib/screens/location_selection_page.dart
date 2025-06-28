// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/prayer_times.dart';
import 'package:islamic_app/services/location_services.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/widgets/location/drop_down.dart';

class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = Globals.languageState!;
    final TextDirection textDirection = isEnglish ? TextDirection.ltr : TextDirection.rtl;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
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
        body: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/background.jpg'),
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
                      const Icon(Icons.location_on, size: 60, color: primaryColor),
                      const SizedBox(height: 16),
                      Text(
                        isEnglish
                            ? 'Please select your location to get accurate prayer times'
                            : 'الرجاء تحديد موقعك للحصول على أوقات الصلاة الدقيقة',
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

                // Country Dropdown
                DropDown.buildCountryDropdown(
                  isEnglish: isEnglish,
                  selectedCountry: Globals.selectedCountry,
                  onChanged: (newValue) {
                    setState(() {
                      Globals.selectedCountry = newValue;
                      Globals.selectedGovernorate = null;
                      Globals.showGovernorates = true;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Governorate Dropdown
                if (Globals.showGovernorates && Globals.selectedCountry != null)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: DropDown.buildGovernorateDropdown(
                      isEnglish: isEnglish,
                      selectedCountry: Globals.selectedCountry!,
                      selectedGovernorate: Globals.selectedGovernorate,
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
                    onPressed: Globals.selectedCountry != null && Globals.selectedGovernorate != null
                        ? () async {
                            setState(() => isLoading = true);

                            try {
                              await LocationService.saveLocation(
                                country: Globals.selectedCountry!,
                                governorate: Globals.selectedGovernorate!,
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PrayerTimesPage(),
                                ),
                              );
                            } finally {
                              if (mounted) {
                                setState(() => isLoading = false);
                              }
                            }
                          }
                        : null,
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
                            isEnglish ? 'Continue to Prayer Times' : 'المتابعة لمواقيت الصلاة',
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
}
