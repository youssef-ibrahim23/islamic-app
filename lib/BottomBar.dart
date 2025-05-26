import 'package:flutter/material.dart';
import 'package:islamic_app/Home.dart';
import 'package:islamic_app/More.dart';
import 'package:islamic_app/Profile.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _currentIndex = 1; // Default to HomePage

  final List<Widget> _pages = [
    const More(),
    const HomePage(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF0b3d27),
        height: screenHeight * 0.07,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarIcon(
              icon: Icons.more_horiz,
              index: 0,
            ),
            _buildNavBarIcon(
              icon: Icons.home,
              index: 1,
            ),
            _buildNavBarIcon(
              icon: Icons.person,
              index: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarIcon({
    required IconData icon,
    required int index,
  }) {
    return IconButton(
      onPressed: () {
        setState(() {
          _currentIndex = index;
        });
      },
      icon: Icon(
        icon,
        color: _currentIndex == index
            ? const Color.fromARGB(255, 28, 117, 101)
            : Colors.white,
      ),
    );
  }
}
