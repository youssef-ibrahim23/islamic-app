import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:islamic_app/Login.dart';
import 'package:islamic_app/main.dart';

class ForgotpasswordPage extends StatefulWidget {
  @override
  _ForgotpasswordPageState createState() => _ForgotpasswordPageState();
}

class _ForgotpasswordPageState extends State<ForgotpasswordPage> {
  TextEditingController controller = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0b3d27),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 10, top: 45),
              alignment: Alignment.topLeft,
              height: screenHeight * 0.55,
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.keyboard_backspace_rounded,
                    color: Colors.white,
                  )),
            ),
            Container(
              alignment: Alignment.center,
              height: screenHeight * 0.45,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(40)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    languageState!
                        ? "Help You if Forgot Your Password"
                        : "سيساعدك عندما تنسي رقمك السري",
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: languageState! ? 'cursive' : 'Lateef',
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: screenHeight * 0.08,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        labelText: languageState!
                            ? "Enter Your Email"
                            : "أدخل بريدك الالكتروني",
                        labelStyle: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.08,
                  ),
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
                            onPressed: Send,
                            child: Text(
                              languageState!
                                  ? "Send Reset Link"
                                  : "ارسال موقع اعادة تهيئة الرقم السري",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                fontFamily: languageState! ? 'serif' : 'Lateef',
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void Send() async {
    if (controller.text.isEmpty || !controller.text.contains('@')) {
      AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              title: languageState!
                  ? "Invalid Email"
                  : "البريد الالكتروني غير صحيح",
              desc: languageState!
                  ? "Please enter a valid email address."
                  : "من فضلك أدخل بريد الاكتروني صحيح",
              btnOkOnPress: () {})
          .show();
      return;
    }

    loading = true;
    setState(() {});

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: controller.text);

      AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: languageState! ? "Success" : 'نجاح',
          desc: languageState!
              ? "Check your email for a password reset link."
              : "افحص بريدك الالكتروني لاكمال عملية اعادة تهيئة الرقم السري",
          btnOkOnPress: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Login_P()));
          }).show();
      // ignore: unused_catch_clause
    } on FirebaseAuthException catch (e) {
      AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              title: languageState! ? "Error" : 'خطاء',
              desc: languageState! ? "Please try again ." : "حاول مجددا",
              btnOkOnPress: () {})
          .show();
    } catch (e) {
      AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              title: languageState! ? "Error" : 'خطاء',
              desc: languageState! ? "Please try again ." : "حاول مجددا",
              btnOkOnPress: () {})
          .show();
    } finally {
      loading = false;
      setState(() {});
    }
    controller.clear();
  }
}
