import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Config/page_path_config.dart';
import 'package:home_care/Config/theme_config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_care/Pages/WelcomePage/welcome_page.dart';

void main() {
  runApp(
    ScreenUtilInit(
      designSize: const Size(360, 690), // your design reference size
      minTextAdapt: true,
      builder: (context, child) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Healt Care",
      theme: lightTheme,
      darkTheme: darkTheme,
      // themeMode: ThemeMode.system,
      themeMode: ThemeMode.light,
      getPages: pagePath,

      // home: HomePage(),
      // home: HomePage(),
      // home: BottomBarPage(),
      home: WelcomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:home_care/Config/page_path_config.dart';
// import 'package:home_care/Config/theme_config.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:home_care/Pages/BottomNavigationBar/bottom_bar_page.dart';

// void main() {
//   runApp(
//     ScreenUtilInit(
//       designSize: const Size(360, 690),
//       minTextAdapt: true,
//       builder: (context, child) {
//         return const MyApp(); // ✅ Wrapped inside builder
//       },
//       child: const MyApp(), // ✅ Added child parameter (required)
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: "Health Care",
//       theme: lightTheme,
//       darkTheme: darkTheme,
//       themeMode: ThemeMode.system,
//       getPages: pagePath,
//       home: const BottomBarPage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
