// import 'package:flutter/material.dart';
// import 'package:home_care/Pages/HomePage/Widget/home_page_ui.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const HomePageUi(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:home_care/Pages/HomePage/Widget/home_page_ui.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HomePageUi(),
      // bottomNavigationBar: BottomBarPage(),
    );
  }
}
