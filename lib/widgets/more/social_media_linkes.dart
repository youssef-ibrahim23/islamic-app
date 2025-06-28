import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/more/social_icon.dart';

class SocialMediaLinkes{
  static Widget buildSocialMediaLinks(Size size, bool isPortrait , BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocialIcon.buildSocialIcon(
          icon: FontAwesomeIcons.linkedin,
          url: "https://www.linkedin.com/company/ntg-clarity",
          color: const Color(0xFF0077B5),
          context: context 
        ),
        const SizedBox(width: 30),
       SocialIcon.buildSocialIcon(
          icon: FontAwesomeIcons.envelope,
          url: "mailto:egypt@ntgclarity.com",
          color: primaryColor,
          context: context 
        ),
        const SizedBox(width: 30),
        SocialIcon.buildSocialIcon(
          icon: FontAwesomeIcons.globe,
          url: "https://ntgclarity.com/",
          color: Colors.green,
          context: context 
        ),
      ].animate(interval: 100.ms).slideX(
            begin: 0.5,
            end: 0,
            curve: Curves.easeOutBack,
          ),
    );
  }
}