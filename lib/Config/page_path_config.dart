import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:home_care/Pages/BookNow/bookNow_page.dart';
import 'package:home_care/Pages/BottomNavigationBar/bottom_bar_page.dart';
import 'package:home_care/Pages/Cart/cart_screen.dart';
import 'package:home_care/Pages/Chatbot/chatbot_page.dart';
import 'package:home_care/Pages/HomePage/home_page.dart';
import 'package:home_care/Pages/Profile/FamilyReport/family_report.dart';
import 'package:home_care/Pages/Profile/PersonalDetail/personal_deatil.dart';
import 'package:home_care/Pages/Profile/profile.dart';
import 'package:home_care/Pages/Profile/appointments_page.dart';
import 'package:home_care/Pages/Profile/records_page.dart';
import 'package:home_care/Pages/Profile/profile_details_page.dart';
import 'package:home_care/Pages/Profile/payments_page.dart';
import 'package:home_care/Pages/Professional/professnal_page.dart';
import 'package:home_care/Pages/Quick/quick_page.dart';
import 'package:home_care/Pages/Services/services_page.dart';
import 'package:home_care/Pages/WelcomePage/welcome_page.dart';
import 'package:home_care/Pages/LogInPage/login_page.dart';
import 'package:home_care/Pages/OtpPage/otp_page.dart';
import 'package:home_care/Pages/PhoneNumberPage/phone_number_page.dart';
import 'package:home_care/Pages/SOS/sos_page.dart';
import 'package:home_care/Pages/Appointment/appointment_type_page.dart';
import 'package:home_care/Pages/Appointment/doctor_selection_page.dart';
import 'package:home_care/Pages/Appointment/appointment_booking_page.dart';
import 'package:home_care/Pages/Appointment/appointment_confirmation_page.dart';
import 'package:home_care/Helper/auth_guards.dart';

var pagePath = [
  // ========== PROTECTED ROUTES (Require Authentication) ==========
  GetPage(
    name: "/bottomAppBar",
    page: () => BottomBarPage(),
    transition: Transition.leftToRight,
    middlewares: [AuthGuard()],
  ),

  GetPage(
    name: "/homePage",
    page: () => HomePage(),
    transition: Transition.leftToRight,
    middlewares: [AuthGuard()],
  ),

  GetPage(
    name: "/profile",
    page: () => Profile(),
    transition: Transition.rightToLeft,
    middlewares: [AuthGuard()],
  ),

  GetPage(
    name: "/cart",
    page: () => CartScreen(),
    transition: Transition.rightToLeft,
    middlewares: [AuthGuard()],
  ),

  GetPage(
    name: "/personal-detail",
    page: () => PersonalDetailsPage(),
    transition: Transition.leftToRight,
    middlewares: [AuthGuard()],
  ),

  GetPage(
    name: "/faimly-report",
    page: () => FamilyReportsPage(),
    transition: Transition.leftToRight,
    middlewares: [AuthGuard()],
  ),

  GetPage(
    name: "/chatbot",
    transition: Transition.leftToRight,
    page: () => ChatbotPage(),
    middlewares: [AuthGuard()],
  ),

  GetPage(
    name: "/appointments",
    transition: Transition.leftToRight,
    page: () => AppointmentsPage(),
    middlewares: [AuthGuard()],
  ),

  GetPage(
    name: "/records",
    transition: Transition.leftToRight,
    page: () => RecordsPage(),
    middlewares: [AuthGuard()],
  ),

  GetPage(
    name: "/profile-details",
    transition: Transition.leftToRight,
    page: () => ProfileDetailsPage(),
    middlewares: [AuthGuard()],
  ),

  GetPage(
    name: "/payments",
    transition: Transition.leftToRight,
    page: () => PaymentsPage(),
    middlewares: [AuthGuard()],
  ),

  GetPage(
    name: "/sos",
    transition: Transition.rightToLeft,
    page: () => const SOSPage(),
    middlewares: [AuthGuard()],
  ),

  GetPage(
    name: "/appointment-type",
    transition: Transition.rightToLeft,
    page: () => const AppointmentTypePage(),
    middlewares: [AuthGuard()],
  ),

  GetPage(
    name: "/doctor-selection",
    transition: Transition.rightToLeft,
    page: () => const DoctorSelectionPage(),
    middlewares: [AuthGuard()],
  ),

  GetPage(
    name: "/appointment-booking",
    transition: Transition.rightToLeft,
    page: () => const AppointmentBookingPage(),
    middlewares: [AuthGuard()],
  ),

  GetPage(
    name: "/appointment-confirmation",
    transition: Transition.rightToLeft,
    page: () => const AppointmentConfirmationPage(),
    middlewares: [AuthGuard()],
  ),

  GetPage(
    name: "/quickPage",
    page: () => QuickServicesPage(),
    transition: Transition.rightToLeft,
    middlewares: [AuthGuard()],
  ),

  GetPage(
    name: "/servicesPage",
    page: () => ServicesPage(),
    transition: Transition.circularReveal,
    middlewares: [AuthGuard()],
  ),

  GetPage(
    name: "/professnal-page",
    page: () => ProfessionalPage(),
    transition: Transition.circularReveal,
    middlewares: [AuthGuard()],
  ),

  GetPage(
    name: "/book-now",
    page: () => BookNowPage(),
    transition: Transition.rightToLeft,
    middlewares: [AuthGuard()],
  ),

  // ========== PUBLIC ROUTES (No Authentication Required) ==========
  GetPage(
    name: "/welcomePage",
    page: () => WelcomePage(),
    transition: Transition.rightToLeft,
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
];
