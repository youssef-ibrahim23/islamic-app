import 'package:flutter/material.dart';
import 'package:islamic_app/BottomBar.dart';
import 'package:islamic_app/Services/Database.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:islamic_app/Home.dart';
import 'package:islamic_app/PayerTimesP.dart';
import 'package:islamic_app/main.dart';
import 'Profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

TextEditingController updateName = TextEditingController();
String? email;
String? selectedCountry;

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  Map<String, String> arabicCountriesMainGovernoratee = {
    "الجزائر": "الجزائر",
    "البحرين": "المنامة",
    "جزر القمر": "موروني",
    "جيبوتي": "جيبوتي",
    "مصر": "القاهرة",
    "العراق": "بغداد",
    "الأردن": "عمان",
    "الكويت": "مدينة الكويت",
    "لبنان": "بيروت",
    "ليبيا": "طرابلس",
    "موريتانيا": "نواكشوط",
    "المغرب": "الرباط",
    "عمان": "مسقط",
    "فلسطين": "رام الله",
    "قطر": "الدوحة",
    "السعودية": "الرياض",
    "الصومال": "مقديشو",
    "السودان": "الخرطوم",
    "سوريا": "دمشق",
    "تونس": "تونس",
    "الإمارات العربية المتحدة": "أبو ظبي",
    "اليمن": "صنعاء"
  };

  Map<String, String> arabicCountriesMainGovernorate = {
    "Algeria": "Algiers",
    "Bahrain": "Manama",
    "Comoros": "Moroni",
    "Djibouti": "Djibouti City",
    "Egypt": "Cairo",
    "Iraq": "Baghdad",
    "Jordan": "Amman",
    "Kuwait": "Kuwait City",
    "Lebanon": "Beirut",
    "Libya": "Tripoli",
    "Mauritania": "Nouakchott",
    "Morocco": "Rabat",
    "Oman": "Muscat",
    "Palestine": "Ramallah",
    "Qatar": "Doha",
    "Saudi Arabia": "Riyadh",
    "Somalia": "Mogadishu",
    "Sudan": "Khartoum",
    "Syria": "Damascus",
    "Tunisia": "Tunis",
    "United Arab Emirates": "Abu Dhabi",
    "Yemen": "Sana'a"
  };

  @override
  void initState() {
    super.initState();
    updateName.text = Name.text;
    selectedCountry = country.text;
    email = FirebaseAuth.instance.currentUser?.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0b3d27),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_backspace_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        toolbarHeight: screenHeight * 0.1,
        backgroundColor: const Color(0xFF0b3d27),
        centerTitle: true,
        elevation: 0,
        title: Text(
          languageState! ? "Update Profile" : 'اتغير الملف الشخصي',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.08,
            fontFamily: languageState! ? 'Cursive' : 'Lateef',
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.44,
            ),
            Container(
                width: double.infinity,
                height: screenHeight * 0.4,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black)),
                child: Column(
                  children: [
                    SizedBox(
                      height: screenHeight * 0.04,
                    ),
                    _buildTextField(languageState! ? "Name" : "الاسم",
                        screenWidth, updateName),
                    SizedBox(height: screenHeight * 0.06),
                   SizedBox(
  width: screenWidth * 0.9,
  child: DropdownButtonFormField<String>(
    decoration: InputDecoration(
      labelText: languageState! ? "Select your Country" : "المدينة",
      labelStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    ),
    dropdownColor: Colors.white,
    style: const TextStyle(color: Colors.black),
    value: selectedCountry,
    items: (languageState!
        ? arabicCountriesMainGovernorate.keys
        : arabicCountriesMainGovernoratee.keys)
      .map((country) {
        return DropdownMenuItem<String>(
          value: country,
          child: Directionality( // Ensures text alignment inside the dropdown
            textDirection: languageState! ? TextDirection.ltr : TextDirection.rtl,
            child: Text(country, textAlign: languageState! ? TextAlign.left : TextAlign.right),
          ),
        );
      }).toList(),
    onChanged: (value) {
      setState(() {
        selectedCountry = value;
      });
    },
  ),
),

                    SizedBox(height: screenHeight * 0.06),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.white,
                        elevation: 4,
                        backgroundColor: const Color(0xFF0b3d27),
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.3,
                            vertical: screenHeight * 0.02),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        var result = await DB.update(
                            "UPDATE USERS SET USERNAME = '${updateName.text}', country = '${selectedCountry}' WHERE EMAIL = '${email}'");

                        if (result != 0) {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.success,
                            animType: AnimType.rightSlide,
                            title: languageState! ? 'Success' : 'نجاح',
                            desc: languageState!
                                ? "Profile updated successfully."
                                : 'تم تغير المعلومات بنجاح',
                            btnOkOnPress: () {
                              Name.text = updateName.text;
                              country.text = selectedCountry!;
                              acountName = updateName.text;
                              Country = selectedCountry;
                              Governorate = 
                                  arabicCountriesMainGovernorate.keys.contains(Country) ? arabicCountriesMainGovernorate[Country] : arabicCountriesMainGovernoratee[Country];
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const BottomBar()),
                              );
                            },
                          ).show();
                        } else {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.error,
                            animType: AnimType.rightSlide,
                            title: languageState! ? 'Error' : 'خطاء',
                            desc: languageState!
                                ? "Failed to update profile."
                                : 'خطاء في تغير المعلومات',
                            btnOkOnPress: () {},
                          ).show();
                        }
                      },
                      child: Text(
                        languageState! ? "Save Changes" : 'حفظ التغييرات',
                        style: TextStyle(
                          fontFamily: languageState! ? 'Cursive' : 'Lateef',
                          color: Colors.white,
                          fontSize: languageState! ? screenWidth * 0.03 : screenWidth*0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }

Widget _buildTextField(
  String label,
  double screenWidth,
  TextEditingController controller,
  
) {
  return Container(
    width: screenWidth * 0.9,
    child: TextFormField(
      
      controller: controller,
      textAlign: languageState! ? TextAlign.left : TextAlign.right, // Align text content
      textDirection: languageState! ? TextDirection.ltr : TextDirection.rtl, // Align label
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        alignLabelWithHint: true, // Ensures the label moves properly
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      style: const TextStyle(color: Colors.black),
    ),
  );
}

}
