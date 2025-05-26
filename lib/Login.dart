import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:islamic_app/BottomBar.dart';
import 'package:islamic_app/ForgotPassword.dart';
import 'package:islamic_app/Home.dart';
import 'package:islamic_app/PayerTimesP.dart';
import 'package:islamic_app/Profile.dart';
import 'package:islamic_app/SignUp.dart';
import 'package:islamic_app/SplashScreen.dart';
import 'package:islamic_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Services/Database.dart';

class Login_P extends StatefulWidget {
  const Login_P({super.key});

  @override
  State<Login_P> createState() => _LoginPState();
}

class _LoginPState extends State<Login_P> {
  List languages = ["English" , "العربية"];
  String? selectedLanguage;
  bool loading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool hidePassword = true;

  // Login Function
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: languageState! ? 'Error' : 'خطاء',
        desc: languageState!
            ? 'Please fill in all fields.'
            : 'من فضلك ادخل كل البيانات',
        btnOkOnPress: () {},
      ).show();
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Check email verification
      bool isVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      if (!isVerified) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: languageState! ? 'Email Not Verified' : 'الاميل لم يتحقق بعد',
          desc: languageState!
              ? 'Please check your email to verify your account.'
              : 'من فضلك افحص بريدك الالكتروني لتحقق حسابك',
          btnOkOnPress: () {},
        ).show();
        setState(() {
          loading = false;
        });
        return;
      }

      // Query database for user info
      String query =
          "SELECT EMAIL, USERNAME, country FROM USERS WHERE EMAIL = '${emailController.text}'";
      List<Map<String, dynamic>> data = await DB.select(query);

      if (data.isNotEmpty) {
        // Set user data
        Name.text = data[0]['USERNAME'];
        Email.text = data[0]['EMAIL'];
        country.text = data[0]['country'];
        acountName = data[0]['USERNAME'];
        Country = data[0]['country'] ?? 'Egypt';

        Governorate = arabicCountriesMainGovernorate.keys.contains(Country) ? arabicCountriesMainGovernorate[Country] : arabicCountriesMainGovernoratee[Country];
        print(data);
        print("$Country , $Governorate");
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomBar()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = languageState!
          ? 'An unknown error occurred. Please try again.'
          : 'خطاء غير معروف . من فضلك حاول مجددا';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = languageState!
              ? 'No user found for this email.'
              : 'لا يوجد حساب لهذا الاميل';
          break;
        case 'wrong-password':
          errorMessage = languageState!
              ? 'Incorrect password entered.'
              : 'الرقم السري الذي ادخلتة غير صحيح';
          break;
        case 'invalid-email':
          errorMessage = languageState!
              ? 'The email address is badly formatted.'
              : 'هذا الاميل ليس ب الشكل المعناد';
          break;
      }
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: languageState! ? 'Error' : 'خطاء',
        desc: errorMessage,
        btnOkOnPress: () {},
      ).show();
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: languageState! ? 'Error' : 'خطا',
        desc: languageState!
            ? 'Something went wrong. Please try again later.'
            : 'هناك شئ حدث بشكل غير صحيح , من فضلك حاول مجددا',
        btnOkOnPress: () {},
      ).show();
    } finally {
      setState(() {
        loading = false;
      });
      passwordController.clear(); // Clear sensitive data
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0b3d27),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              width: screenWidth,
              height: screenHeight * 0.42,
              color: const Color(0xFF0b3d27),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(height: screenHeight*0.04,),
                  Container(
                    padding: EdgeInsets.all(20),
                    alignment: languageState! ? Alignment.centerRight : Alignment.centerLeft,
                    width: screenWidth ,
                    child: Container(
                      width: screenWidth * 0.3,
                      child:DropdownButtonFormField<String>(
    decoration:  InputDecoration(
      labelText: languageState! ? "English" : "العربية",
      labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
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

  ) ,
                    ),
                  ),
                  SizedBox(height: screenHeight*0.1,),
                  Row(
                    mainAxisAlignment: (languageState!)
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    children: [
                      (languageState!)
                          ? SizedBox(width: screenWidth * 0.05)
                          : SizedBox(),
                      Text(
                        (languageState!) ? "Log in" : "تسجيل الدخول ",
                        style: TextStyle(
                          fontFamily: languageState! ? 'Fantasy' : 'Lateef',
                          color: Colors.white,
                          fontSize: screenWidth * 0.11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      (languageState!)
                          ? SizedBox()
                          : SizedBox(
                              width: screenWidth * 0.05,
                            )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.034),
            Container(
              width: screenWidth,
              height: screenHeight * 0.56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      languageState!
                          ? SizedBox()
                          : Text(
                              "Islamic App",
                              style: TextStyle(
                                fontFamily: 'Cursive',
                                color: Colors.black,
                                fontSize: screenWidth * 0.08,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      Text(
                        (languageState!)
                            ? "Welcome To Islamic App"
                            : " اهلا بك في",
                        style: TextStyle(
                          fontFamily: languageState! ? 'Cursive' : 'lateef',
                          color: Colors.black,
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.035),
                  buildTextField(
                    controller: emailController,
                    label: languageState! ? "Email" : "البريد الالكتروني",
                    obscureText: false,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  buildTextField(
                    controller: passwordController,
                    label: languageState! ? "Password" : "الرقم السري",
                    obscureText: hidePassword,
                    icon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    alignment: Alignment.centerRight,
                    width: screenWidth,
                    child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotpasswordPage()));
                        },
                        child: Text(
                          languageState!
                              ? "Forgot Password ? "
                              : "هل نسيت الرقم السري ؟",
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: languageState! ? 'cursive' : 'Lateef',
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold),
                        )),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  loading
                      ? const CircularProgressIndicator(
                          color: Color.fromARGB(255, 241, 127, 51),
                        )
                      : SizedBox(
                          width: screenWidth * 0.92,
                          height: screenHeight * 0.06,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 241, 127, 51),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            onPressed: login,
                            child: Text(
                              languageState! ? "Log in" : "تسجيل الدخول",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                fontFamily: languageState! ? 'serif' : 'Lateef',
                              ),
                            ),
                          ),
                        ),
                  SizedBox(height: screenHeight * 0.02),
                  languageState!
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?"),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const SignUp_p()));
                              },
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: const Color(0xFF0b3d27),
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'serif',
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const SignUp_p()));
                              },
                              child: Text(
                                "انشاء حساب",
                                style: TextStyle(
                                  color: const Color(0xFF0b3d27),
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'serif',
                                ),
                              ),
                            ),
                            const Text("لا تمتلك حساب ؟"),
                          ],
                        )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    IconButton? icon,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: TextFormField(
        controller: controller,
        textAlign: languageState! ? TextAlign.left : TextAlign.right, // Align text content
      textDirection: languageState! ? TextDirection.ltr : TextDirection.rtl, // Align label
      textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          
          suffixIcon: icon,
          labelText: label,
          labelStyle:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.all(Radius.circular(7)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
        style: const TextStyle(color: Colors.black),
        obscureText: obscureText,
      ),
    );
  }
}
