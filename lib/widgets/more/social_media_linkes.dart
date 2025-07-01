import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/more/social_icon.dart';
import 'package:url_launcher/url_launcher.dart';

import 'email_icon.dart';

class SocialMediaLinksWidget extends StatelessWidget {
  final Size? size;
  final bool? isPortrait;

  const SocialMediaLinksWidget({
    Key? key,
    this.size,
    this.isPortrait,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SocialIconWidget(
          icon: FontAwesomeIcons.linkedin,
          url: 'https://www.linkedin.com/company/ntg-clarity',
          color: Color(0xFF0077B5),
        ),
        const SizedBox(width: 30),

        // ✅ Mail button using IconButton
        const EmailIconWidget(
          email: 'egypt@ntgclarity.com',
          color: primaryColor,
        ),

        const SizedBox(width: 30),
        const SocialIconWidget(
          icon: FontAwesomeIcons.globe,
          url: 'https://ntgclarity.com/',
          color: Colors.green,
        ),
      ]
          .animate(interval: 100.ms)
          .slideX(begin: 0.5, end: 0, curve: Curves.easeOutBack),
    );
  }
}
