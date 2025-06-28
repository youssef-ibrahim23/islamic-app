import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:islamic_app/services/more_services.dart';

class SocialIcon{

  static Widget buildSocialIcon({
    required IconData icon,
    required String url,
    required Color color,
    required BuildContext context
  }) {
    return InkWell(
      onTap: () async => await MoreService.launchExternalUrl( context , url),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
              color: color.withOpacity(0.3)), // Added missing parenthesis
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