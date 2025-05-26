import 'package:flutter/material.dart';
import 'package:islamic_app/Login.dart';

class Welcome_P extends StatefulWidget {
  const Welcome_P({super.key});

  @override
  State<Welcome_P> createState() => _Welcome_pState();
}

class _Welcome_pState extends State<Welcome_P> {
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/WhatsApp Image 2024-12-09 at 17.20.05_7fcff006.jpg'),
              fit: BoxFit.fill,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: screenHeight * 0.5,
                ),
                Text(
                  "ISLAMIC",
                  style: TextStyle(
                      fontFamily: 'Cursive',
                      color: const Color(0xFF0B2D27),
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.1),
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                Text(
                  textAlign: TextAlign.center,
                  "An app help you to stay \n connenected throughout the islam",
                  style: TextStyle(
                      fontFamily: 'serif',
                      color: const Color(0xFF0B2D27),
                      fontSize: screenWidth * 0.05),
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                Container(
                  width: screenWidth,
                  decoration: const BoxDecoration(),
                  child: Padding(
                    padding: const EdgeInsets.all(50),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B2D27),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login_P()));
                      },
                      child: const Text(
                        "Explore Now",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
