import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/more/social_icon.dart';   // or use SocialIconWidget if you switched

class SocialMediaLinksWidget extends StatelessWidget {
  /// You included these two parameters in the original API,
  /// but they were not used inside the method.  They’re optional now,
  /// yet still here so the call‑sites don’t break.
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
SizedBox(width: 30),
const SocialIconWidget(
  icon: FontAwesomeIcons.envelope,
  url: 'mailto:egypt@ntgclarity.com',
  color: primaryColor,
),
SizedBox(width: 30),
const SocialIconWidget(
  icon: FontAwesomeIcons.globe,
  url: 'https://ntgclarity.com/',
  color: Colors.green,
),

      ]
          // Animate each child with a small stagger, same as your original code
          .animate(interval: 100.ms)
          .slideX(begin: 0.5, end: 0, curve: Curves.easeOutBack),
    );
  }
}
