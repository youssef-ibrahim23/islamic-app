import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:islamic_app/Login.dart';
import 'package:islamic_app/Profile.dart';
import 'package:islamic_app/SplashScreen.dart';
import 'package:islamic_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

String selectedLanguage = languageState! ? 'English' : 'العربية';

class More extends StatefulWidget {
  const More({super.key});

  @override
  State<More> createState() => _MoreState();
}

class _MoreState extends State<More> {
  final List<String> languages = ['English', 'العربية']; // Drop-down options

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0b3d27),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Top empty container
          Container(
            alignment: Alignment.bottomLeft,
            width: screenWidth,
            height: screenHeight * 0.53,
            color: const Color(0xFF0b3d27),
          ),
          

          // Main content container
          Container(
            width: screenWidth,
            height: screenHeight * 0.4,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                SizedBox(height: screenHeight * 0.02),
                
                // Language dropdown
                _buildLanguageDropdown(screenWidth),
                SizedBox(height: screenHeight * 0.05),

                // Logout button
                _buildLogoutButton(screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.05),

                // Social media links
                _buildSocialMediaLinks(screenWidth),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build the language dropdown
  Widget _buildLanguageDropdown(double screenWidth) {
             return SizedBox(
  width: screenWidth * 0.9,
  child: DropdownButtonFormField<String>(
    decoration:  InputDecoration(
      labelText: languageState! ? "Language" : " اللغة",
      labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    ),
    dropdownColor: Colors.white,
    style: const TextStyle(color: Colors.black),
    value: selectedLanguage,
    items: languageState! ? languages.map((country) {
      return DropdownMenuItem<String>(
        value: country,
        child: Text(country),
      );
    }).toList() : languages.map((country) {
      return DropdownMenuItem<String>(
        value: country,
        child: Text(country),
      );
    }).toList()  ,
    onChanged: (value) async {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
            setState(() {
              selectedLanguage = value!;
              languageState = value == "English";
            });

            await sharedPreferences.setBool("language", languageState!);

            // Restart the app to apply language changes
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SplashScreen()),
            );
          }

  ),
);
  }

  // Build the logout button
  Widget _buildLogoutButton(double screenWidth, double screenHeight) {
    return SizedBox(
      width: screenWidth * 0.92,
      height: screenHeight * 0.06,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 241, 127, 51),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onPressed: () async {
          try {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Login_P()),
            );
          } catch (e) {
            print("Error during sign-out: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Failed to sign out. Please try again."),
              ),
            );
          }
          Name.clear();
          Email.clear();
          country.clear();
        },
        child: Text(
          languageState! ? "Log Out" : "تسجيل الخروج",
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
        ),
      ),
    );
  }

  // Build social media links
  Widget _buildSocialMediaLinks(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // LinkedIn button
        IconButton(
          onPressed: () async {
            String linkedinUrl =
                "https://www.linkedin.com/in/youssef-ibrahim-a2137a343?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app";
            await _launchUrl(linkedinUrl);
          },
          icon: Icon(
            FontAwesomeIcons.linkedin,
            color: Colors.blue,
            size: screenWidth * 0.07,
          ),
        ),

        // Gmail button
        TextButton(
          onPressed: () async {
            String emailUrl = "mailto:youssefabrahem6@gmail.com";
            await _launchUrl(emailUrl);
          },
          child: Image.asset(
            "assets/gmail.png",
            height: screenWidth * 0.07,
          ),
        ),

      ],
    );
  }

  // Helper function to launch URLs
  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print("Error launching URL: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to open the link. Please try again."),
        ),
      );
    }
  }
}