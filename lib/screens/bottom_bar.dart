import 'package:flutter/material.dart';
import 'package:islamic_app/screens/favorites.dart';
import 'package:islamic_app/screens/home.dart';
import 'package:islamic_app/screens/more.dart';
import 'package:islamic_app/globals.dart';
import 'compass.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _currentIndex = 1; // Default to HomePage
  final Color primaryColor = const Color(0xFF8B0000); // Dark red
  final Color inactiveColor = const Color(0xFF888888); // Gray for inactive items
  final Color backgroundColor = Colors.white;

  final List<Widget> _pages = [
    const More(),
    const HomePage(),
    const CompassPage(),
    const FavoritesPage()
  ];

  @override
  Widget build(BuildContext context) {
    final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive sizing
    final double iconSize = isPortrait 
        ? screenHeight * 0.03
        : screenWidth * 0.03;
    final double bottomBarHeight = isPortrait
        ? screenHeight * 0.08
        : screenHeight * 0.1;
    final double labelFontSize = isPortrait
        ? screenWidth * 0.03
        : screenHeight * 0.02;

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          color: backgroundColor,
          elevation: 2,
          height: bottomBarHeight,
          padding: EdgeInsets.symmetric(
            horizontal: isPortrait ? 8 : 16,
            vertical: isPortrait ? 0 : 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.more_horiz,
                label: Globals.languageState! ? 'More' : 'المزيد',
                index: 0,
                iconSize: iconSize,
                fontSize: labelFontSize,
              ),
              _buildNavItem(
                context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: Globals.languageState! ? 'Home' : 'الرئيسية',
                index: 1,
                iconSize: iconSize,
                fontSize: labelFontSize,
              ),
              _buildNavItem(
                context,
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore,
                label: Globals.languageState! ? 'Compass' : 'القبلة',
                index: 2,
                iconSize: iconSize,
                fontSize: labelFontSize,
              ),
              _buildNavItem(
                context,
                icon: Icons.favorite_outline,
                activeIcon: Icons.favorite,
                label: Globals.languageState! ? 'Favorites' : 'المفضلة',
                index: 3,
                iconSize: iconSize,
                fontSize: labelFontSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    IconData? activeIcon,
    required String label,
    required int index,
    required double iconSize,
    required double fontSize,
  }) {
    final bool isActive = _currentIndex == index;
    final Color color = isActive ? primaryColor : inactiveColor;
    final IconData displayIcon = isActive ? (activeIcon ?? icon) : icon;
    final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      splashColor: primaryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isPortrait ? 12 : 16,
          vertical: isPortrait ? 8 : 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              displayIcon,
              size: iconSize,
              color: color,
            ),
            if (isPortrait) const SizedBox(height: 4),
            if (isPortrait) Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}