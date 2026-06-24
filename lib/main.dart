import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Config/page_path_config.dart';
import 'package:home_care/Config/theme_config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_care/Pages/WelcomePage/welcome_page.dart';
import 'package:home_care/Controller/notification_controller.dart';
import 'package:home_care/Controller/profile_controller.dart';
import 'package:home_care/Controller/service_cart_controller.dart';
import 'package:home_care/Controller/service_controller.dart';
import 'package:home_care/Controller/service_professionals_controller.dart';
import 'package:home_care/Controller/geo_controller.dart';

void main() async {
  // Required before any plugin (geolocator, geocoding, shared_preferences)
  // or platform channel is accessed from main().
  WidgetsFlutterBinding.ensureInitialized();

  // Register global GetX controllers after binding is ready
  Get.put(ProfileController());
  Get.put(ServiceCartController());
  Get.put(NotificationController());
  Get.put(ServiceController());
  Get.put(ServiceProfessionalsController());
  Get.put(GeoController());

  runApp(
    ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context, child) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Health Care',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      getPages: pagePath,
      home: WelcomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
