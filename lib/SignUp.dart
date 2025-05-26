import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:islamic_app/BottomBar.dart';
import 'package:islamic_app/Services/Database.dart';
import 'package:islamic_app/Home.dart';
import 'package:islamic_app/Login.dart';
import 'package:islamic_app/PayerTimesP.dart';
import 'package:islamic_app/Profile.dart';
import 'package:islamic_app/main.dart';

bool loop = true;

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
  "Yemen": "Sana'a",
};

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

class SignUp_p extends StatefulWidget {
  const SignUp_p({super.key});

  @override
  State<SignUp_p> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUp_p> {
  String? selectedCountry;
  bool loading = false;

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirm = TextEditingController();

  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;

  void SignUp() async {
    setState(() {
      loading = true;
    });

    if (name.text.isEmpty ||
        email.text.isEmpty ||
        password.text.isEmpty ||
        confirm.text.isEmpty ||
        selectedCountry == null) {
      setState(() {
        loading = false;
      });
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: languageState! ? 'Error' : 'خطاء',
        desc: languageState!
            ? 'Please fill in all the fields.'
            : 'من فضلك ادخل جميع البيانات ',
        btnOkOnPress: () {},
      ).show();
      return;
    }

    if (password.text != confirm.text) {
      setState(() {
        loading = false;
      });
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: languageState! ? 'Error' : 'خطاء',
        desc: languageState!
            ? 'Passwords do not match.'
            : 'الرقم السري غير متشابة',
        btnOkOnPress: () {},
      ).show();
      return;
    }

    try {
      var status = await DB.insert(
          "INSERT INTO USERS (EMAIL, USERNAME, country) VALUES ('${email.text}', '${name.text}', '$selectedCountry')");
      print(status);

      Name = name;
      Email = email;
      country.text = selectedCountry!;
      acountName = name.text;
      print(selectedCountry);
      Country = selectedCountry;
      Governorate = arabicCountriesMainGovernorate.keys.contains(Country) ? arabicCountriesMainGovernorate[Country] : arabicCountriesMainGovernoratee[Country];
      print(Governorate);

      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );

      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: languageState!
            ? 'Verification Email Sent'
            : 'لقد ارسلنا لبريدك الالكتروني التحقق من الحساب',
        desc: languageState!
            ? 'Please check your email to verify your account.'
            : 'من فضلك افحص بريدك الالكتروني للتحقق لحسابك',
        btnOkOnPress: () async {
          bool isVerified = false;

          while (!isVerified && loop) {
            await FirebaseAuth.instance.currentUser!.reload();
            isVerified = FirebaseAuth.instance.currentUser!.emailVerified;
          }

          if (isVerified) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BottomBar()),
            );
          }
        },
      ).show();

      setState(() {
        loading = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error',
        desc: e.code,
        btnOkOnPress: () {},
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0b3d27),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.bottomLeft,
              height: screenHeight * 0.25,
              color: const Color(0xFF0b3d27),
              child: Row(
                mainAxisAlignment: languageState!
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: [
                  languageState!
                      ? SizedBox(width: screenWidth * 0.05)
                      : SizedBox(),
                  Text(
                    languageState! ? "Sign Up" : "انشاء حساب",
                    style: TextStyle(
                      fontFamily: languageState! ? 'Fantasy' : 'Lateef',
                      color: Colors.white,
                      fontSize: screenWidth * 0.11,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  languageState!
                      ? SizedBox()
                      : SizedBox(
                          width: screenWidth * 0.05,
                        )
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Container(
              width: screenWidth,
              height: screenHeight * 0.72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.03),
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
                        languageState!
                            ? "Sign up to Islamic"
                            : "  انشاء حساب في",
                        style: TextStyle(
                          fontFamily: languageState! ? 'Cursive' : 'Lateef',
                          color: Colors.black,
                          fontSize: languageState!
                              ? screenWidth * 0.08
                              : screenWidth * 0.07,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  _BuildTextFeild(languageState! ? "Enter Your Name" : "الاسم",
                      screenWidth, name),
                  SizedBox(height: screenHeight * 0.02),
                  _BuildTextFeild(
                      languageState!
                          ? "Enter your Email"
                          : " البريد الالكتروني",
                      screenWidth,
                      email),
                  SizedBox(height: screenHeight * 0.02),
                  _BuildTextFeild(
                    languageState! ? "Create Password" : "الرقم سري",
                    screenWidth,
                    password,
                    isPassword: true,
                    isHidden: isPasswordHidden,
                    toggleVisibility: () {
                      setState(() {
                        isPasswordHidden = !isPasswordHidden;
                      });
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _BuildTextFeild(
                    languageState!
                        ? "Confirm Password"
                        : "ادخل الرقم السري مجددا",
                    screenWidth,
                    confirm,
                    isPassword: true,
                    isHidden: isConfirmPasswordHidden,
                    toggleVisibility: () {
                      setState(() {
                        isConfirmPasswordHidden = !isConfirmPasswordHidden;
                      });
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  SizedBox(
                    width: screenWidth * 0.9,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText:
                            languageState! ? "Select your Country" : " المدينة",
                        labelStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Colors.black),
                      value: selectedCountry,
                      items: languageState!
                          ? arabicCountriesMainGovernorate.keys.map((country) {
                              return DropdownMenuItem<String>(
                                value: country,
                                child: Text(country),
                              );
                            }).toList()
                          : arabicCountriesMainGovernoratee.keys.map((country) {
                              return DropdownMenuItem<String>(
                                value: country,
                                child: Text(country),
                              );
                            }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCountry = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  loading
                      ? const CircularProgressIndicator(
                          color: Color.fromARGB(255, 241, 127, 51))
                      : Container(
                          alignment: Alignment.center,
                          width: screenWidth * 0.92,
                          height: screenHeight * 0.06,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 241, 127, 51),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextButton(
                            onPressed: () {
                              SignUp();
                            },
                            child: Text(
                              languageState! ? "Sign Up" : 'انشاء حساب',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'serif',
                              ),
                            ),
                          ),
                        ),
                  SizedBox(height: screenHeight * 0.02),
                  languageState!
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account!"),
                            TextButton(
                              onPressed: () {
                                loop = false;
                                setState(() {});
                                print(loop);
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => const Login_P()));
                              },
                              child: Text(
                                "Log in",
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
                                loop = false;
                                setState(() {});
                                print(loop);
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => const Login_P()));
                              },
                              child: Text(
                                "تسجيل الدخول",
                                style: TextStyle(
                                  color: const Color(0xFF0b3d27),
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'serif',
                                ),
                              ),
                            ),
                            const Text("! بالفعل لديك حساب"),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _BuildTextFeild(
    String label,
    double screenWidth,
    TextEditingController controller, {
    bool isPassword = false,
    bool isHidden = false,
    VoidCallback? toggleVisibility,
  }) {
    return SizedBox(
      width: screenWidth * 0.9,
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && isHidden,
        textAlign: languageState! ? TextAlign.left : TextAlign.right, // Align text content
      textDirection: languageState! ? TextDirection.ltr : TextDirection.rtl, // Align label
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isHidden ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black,
                  ),
                  onPressed: toggleVisibility,
                )
              : null,
        ),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
