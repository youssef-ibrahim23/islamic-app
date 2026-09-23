import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/widgets/app_them.dart';

class Message extends StatelessWidget {
  final String text;

  const Message({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: GoogleFonts.getFont(
          Globals.languageState! ? 'Roboto' : 'Tajawal',
          color: primaryColor,
          fontSize: 18,
        ),
      ),
    );
  }
}
