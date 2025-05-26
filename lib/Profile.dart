import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:islamic_app/UpdateProfile.dart';
import 'package:islamic_app/main.dart';

TextEditingController Name = TextEditingController();
TextEditingController Email = TextEditingController();
TextEditingController country = TextEditingController();

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0b3d27),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: screenHeight * 0.1,
        backgroundColor: const Color(0xFF0b3d27),
        centerTitle: true,
        elevation: 0,
        title: Text(
          languageState! ? "Profile" : "الملف الشخصي",
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.08,
            fontFamily: languageState! ? 'Cursive' : 'Lateef',
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: screenHeight * 0.1,
          ),
          Container(
            height: screenHeight * 0.67,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTextField(languageState! ? "Name" : "الاسم", screenWidth,
                    Name, context),
                SizedBox(height: screenHeight * 0.06),
                _buildTextField(languageState! ? "Email" : "البريد الالكتروني",
                    screenWidth, Email, context),
                SizedBox(height: screenHeight * 0.06),
                _buildTextField(languageState! ? "Country" : "المدينة",
                    screenWidth, country, context),
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
                    if (Email.text.isEmpty || !Email.text.contains('@')) {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.rightSlide,
                        title: 'Invalid Email',
                        desc: 'Please enter a valid email address.',
                        btnOkOnPress: () {},
                      ).show();
                      return;
                    }

                    try {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: Email.text);
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.success,
                        animType: AnimType.rightSlide,
                        title: 'Success',
                        desc:
                            "An email was sent to you to reset your password.",
                        btnOkOnPress: () {},
                      ).show();
                    } on FirebaseAuthException catch (e) {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.rightSlide,
                        title: 'Error',
                        desc: e.message ?? "An error occurred.",
                        btnOkOnPress: () {},
                      ).show();
                    }
                  },
                  child: Text(
                    languageState! ? "Change Password" : "تغير الرقم السري",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.06),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.white,
                    elevation: 4,
                    backgroundColor: const Color(0xFF0b3d27),
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.27,
                        vertical: screenHeight * 0.02),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    updateName.text = Name.text;
                    selectedCountry = country.text;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UpdateProfile()));
                  },
                  child: Text(
                    languageState!
                        ? "Change Information"
                        : "تغير معلومات الملف الشخصي",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  
Widget _buildTextField(
  String label,
  double screenWidth,
  TextEditingController controller,
  BuildContext context,
) {
  return Container(
    width: screenWidth * 0.9,
    child: TextFormField(
      readOnly: true,
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
