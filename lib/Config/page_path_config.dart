import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:home_care/Pages/BookNow/bookNow_page.dart';
import 'package:home_care/Pages/BottomNavigationBar/bottom_bar_page.dart';
import 'package:home_care/Pages/Cart/cart_screen.dart';
import 'package:home_care/Pages/HomePage/home_page.dart';
import 'package:home_care/Pages/Profile/FamilyReport/family_report.dart';
import 'package:home_care/Pages/Profile/PersonalDetail/personal_deatil.dart';
import 'package:home_care/Pages/Profile/profile.dart';
import 'package:home_care/Pages/Professional/professnal_page.dart';
import 'package:home_care/Pages/Quick/quick_page.dart';
import 'package:home_care/Pages/Services/services_page.dart';
import 'package:home_care/Pages/WelcomePage/welcome_page.dart';
import 'package:home_care/Pages/LogInPage/login_page.dart';
import 'package:home_care/Pages/OtpPage/otp_page.dart';
import 'package:home_care/Pages/PhoneNumberPage/phone_number_page.dart';

var pagePath = [
  GetPage(
    name: "/bottomAppBar",
    page: () => BottomBarPage(),
    transition: Transition.leftToRight,
  ),

  GetPage(
    name: "/homePage",
    page: () => HomePage(),
    transition: Transition.leftToRight,
  ),

  GetPage(
    name: "/loginPage",
    page: () => LogInPage(),
    transition: Transition.leftToRight,
  ),

  GetPage(
    name: "/enterPhoneNumberPage",
    page: () => PhoneNumberPage(),
    transition: Transition.leftToRight,
  ),

  GetPage(
    name: "/otpPage",
    page: () => OtpVerificationPage(),
    transition: Transition.leftToRight,
  ),

  GetPage(
    name: "/welcomePage",
    page: () => WelcomePage(),
    transition: Transition.rightToLeft,
  ),

  GetPage(
    name: "/quickPage",
    page: () => QuickServicesPage(),
    transition: Transition.rightToLeft,
  ),

  GetPage(
    name: "/servicesPage",
    page: () => ServicesPage(),
    transition: Transition.circularReveal,
  ),

  GetPage(
    name: "/professnal-page",
    page: () => ProfessionalPage(),
    transition: Transition.circularReveal,
  ),

  GetPage(
    name: "/book-now",
    page: () => BookNowPage(),
    transition: Transition.rightToLeft,
  ),

  GetPage(
    name: "/profile",
    page: () => Profile(),
    transition: Transition.rightToLeft,
  ),

  GetPage(
    name: "/cart",
    page: () => CartScreen(),
    transition: Transition.rightToLeft,
  ),

  GetPage(
    name: "/personal-detail",
    page: () => PersonalDetailsPage(),
    transition: Transition.leftToRight,
  ),

  GetPage(name: "/faimly-report",
  page:() => FamilyReportsPage(),
  transition: Transition.leftToRight)
];
