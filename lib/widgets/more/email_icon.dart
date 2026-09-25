import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailIconWidget extends StatelessWidget {
  final String email;
  final Color color;

  const EmailIconWidget({
    Key? key,
    required this.email,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final Uri emailUri = Uri.parse('mailto:$email');
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);

      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Center(
          child: Icon(
            Icons.email_rounded,
            color: color,
            size: 22,
          ),
        ),
      ),
    );
  }
}
