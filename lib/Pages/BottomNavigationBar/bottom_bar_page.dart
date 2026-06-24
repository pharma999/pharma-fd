import 'package:flutter/material.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Config/images_config.dart';
import 'package:home_care/Controller/booking_controller.dart';
import 'package:home_care/Pages/Bookings/bookings_tab_page.dart';
import 'package:home_care/Pages/HomePage/home_page.dart';
import 'package:home_care/Pages/Profile/profile.dart';
import 'package:home_care/Pages/Services/services_tab_page.dart';

class BottomBarPage extends StatefulWidget {
  const BottomBarPage({super.key});

  @override
  State<BottomBarPage> createState() => _BottomBarPageState();
}

class _BottomBarPageState extends State<BottomBarPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ServicesTabPage(),
    const BookingsTabPage(),
    Profile(),
  ];

  @override
  void initState() {
    super.initState();
    // Register BookingController here (authenticated shell) so its WebSocket
    // connects immediately after login and auto-navigates to the tracking
    // screen the instant the provider accepts.
    Get.put(BookingController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: kPrimary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(22)),
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
            onItemSelected: (index) => setState(() => _selectedIndex = index),
            items: [
              FlashyTabBarItem(
                icon: SvgPicture.asset(
                  AssetsImage.homeIcon,
                  colorFilter:
                      const ColorFilter.mode(kPrimary, BlendMode.srcIn),
                  width: 26,
                  height: 26,
                ),
                title: const Text(
                  'Home',
                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                ),
                activeColor: kPrimary,
                inactiveColor: kTextLight,
              ),
              FlashyTabBarItem(
                icon: SvgPicture.asset(
                  AssetsImage.servicesIcon,
                  colorFilter:
                      const ColorFilter.mode(kPrimary, BlendMode.srcIn),
                  width: 26,
                  height: 26,
                ),
                title: const Text(
                  'Services',
                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                ),
                activeColor: kPrimary,
                inactiveColor: kTextLight,
              ),
              FlashyTabBarItem(
                icon: SvgPicture.asset(
                  AssetsImage.bookingsIcon,
                  colorFilter:
                      const ColorFilter.mode(kPrimary, BlendMode.srcIn),
                  width: 28,
                  height: 28,
                ),
                title: const Text(
                  'Bookings',
                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                ),
                activeColor: kPrimary,
                inactiveColor: kTextLight,
              ),
              FlashyTabBarItem(
                icon: SvgPicture.asset(
                  AssetsImage.profileIcon,
                  colorFilter:
                      const ColorFilter.mode(kPrimary, BlendMode.srcIn),
                  width: 28,
                  height: 28,
                ),
                title: const Text(
                  'Profile',
                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                ),
                activeColor: kPrimary,
                inactiveColor: kTextLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
