// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/more/language_drop_down.dart';
import 'package:islamic_app/widgets/more/setting_card.dart';
import 'package:islamic_app/widgets/more/setting_item.dart';
import 'package:islamic_app/widgets/more/social_media_linkes.dart';

class More extends StatefulWidget {
  const More({super.key});

  @override
  State<More> createState() => _MoreState();
}

class _MoreState extends State<More> {
  @override
  Widget build(BuildContext context) {
    final bool isEnglish = Globals.languageState!;
    final size = MediaQuery.of(context).size;
    final bool isPortrait = size.height > size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.8),
              Colors.white.withOpacity(0.1),
            ],
          ),
          image: const DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
            opacity: 0.9,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header with gradient overlay
              Container(
                width: double.infinity,
                height: isPortrait ? size.height * 0.25 : size.height * 0.35,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      isEnglish ? 'Settings' : 'الإعدادات',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isPortrait ? 32 : 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEnglish ? 'Customize your experience' : 'خصّص تجربتك',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: isPortrait ? 16 : 14,
                        fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isPortrait ? 20 : 20),
                  ],
                ),
              ),

              // Settings cards
              Directionality(
                textDirection: Globals.languageState!
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      SettingCardWidget(
                        title: isEnglish ? 'Language' : 'اللغة',
                        icon: Icons.translate,
                        size: size,
                        isPortrait: isPortrait,
                        children: [
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: LanguageDropDown(
                              isEnglish: isEnglish,
                              size: size,
                              setState: setState,
                              context: context,
                            ),
                          ),
                        ],
                      ).animate().fadeIn().slideY(
                            begin: 0.2,
                            curve: Curves.easeOutQuad,
                          ),
                      const SizedBox(height: 16),
                      SettingCardWidget(
                        title: isEnglish ? 'Connect with us' : 'تواصل معنا',
                        icon: Icons.contact_support_rounded,
                        size: size,
                        isPortrait: isPortrait,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              children: [
                                Text(
                                  isEnglish
                                      ? "We'd love to hear from you!"
                                      : "نحن نحب أن نسمع منك!",
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontFamily:
                                        isEnglish ? 'Roboto' : 'Tajawal',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const SocialMediaLinksWidget(),
                              ],
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 100.ms).slideY(
                            begin: 0.2,
                            curve: Curves.easeOutQuad,
                          ),
                      const SizedBox(height: 16),
                      SettingCardWidget(
                        title: isEnglish ? 'About' : 'حول التطبيق',
                        icon: Icons.info_outline_rounded,
                        size: size,
                        isPortrait: isPortrait,
                        children: [
                          SettingItemWidget(
                            icon: Icons.app_registration,
                            title: isEnglish ? 'App Version' : 'إصدار التطبيق',
                            subtitle: isEnglish
                                ? "Latest version of the app"
                                : "أحدث إصدار من التطبيق",
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "1.0.0",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms).slideY(
                            begin: 0.2,
                            curve: Curves.easeOutQuad,
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
