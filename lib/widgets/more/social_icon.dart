import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:islamic_app/services/more_services.dart';

class SocialIconWidget extends StatelessWidget {
  final IconData icon;
  final String url;
  final Color color;

  const SocialIconWidget({
    Key? key,
    required this.icon,
    required this.url,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async => await MoreService.launchExternalUrl(context, url),
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
          child: FaIcon(
            icon,
            color: color,
            size: 22,
          ),
        ),
      ),
    );
  }
}
