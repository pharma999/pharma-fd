import 'package:flutter/material.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter_svg/svg.dart';
import 'package:home_care/Config/images_config.dart';
import 'package:home_care/Pages/HomePage/home_page.dart';
import 'package:home_care/Pages/Services/services_page.dart';

class BottomBarPage extends StatefulWidget {
  const BottomBarPage({super.key});

  @override
  State<BottomBarPage> createState() => _BottomBarPageState();
}

class _BottomBarPageState extends State<BottomBarPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    // Center(child: Text('Events Page')),
    HomePage(),
    ServicesPage(),
    Center(child: Text('Highlights Page')),
    Center(child: Text('Settings Page')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // soft neutral background
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: FlashyTabBar(
            animationCurve: Curves.easeInOut,
            selectedIndex: _selectedIndex,
            showElevation: false,
            iconSize: 28,
            animationDuration: const Duration(milliseconds: 300),
            backgroundColor: Colors.white,
            onItemSelected: (index) => setState(() {
              _selectedIndex = index;
            }),
            items: [
              FlashyTabBarItem(
                icon: SvgPicture.asset(
                  AssetsImage.homeIcon,
                  colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                  width: 28,
                  height: 28,
                ),
                title: const Text('Home'),
                activeColor: Colors.blueAccent,
                inactiveColor: Colors.grey,
              ),
              FlashyTabBarItem(
                icon: SvgPicture.asset(
                  AssetsImage.servicesIcon,
                  colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                  width: 28,
                  height: 28,
                ),
                title: const Text('Services'),
                activeColor: Colors.purpleAccent,
                inactiveColor: Colors.grey,
              ),
              FlashyTabBarItem(
                icon: SvgPicture.asset(
                  AssetsImage.bookingsIcon,
                  colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                  width: 30,
                  height: 30,
                ),
                title: const Text('Bookings'),
                activeColor: Colors.orangeAccent,
                inactiveColor: Colors.grey,
              ),
              FlashyTabBarItem(
                icon: SvgPicture.asset(
                  AssetsImage.profileIcon,
                  colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                  width: 30,
                  height: 30,
                ),
                title: const Text('Profile'),
                activeColor: Colors.teal,
                inactiveColor: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
