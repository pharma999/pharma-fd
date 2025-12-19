// import 'package:flutter/material.dart';
// import 'package:home_care/Pages/HomePage/Widget/appoimnet_widget.dart';
// import 'package:home_care/Pages/HomePage/Widget/emergency_widget.dart';
// import 'package:home_care/Pages/HomePage/Widget/location_widget.dart';
// import 'package:home_care/Pages/HomePage/Widget/profesnal_widget.dart';
// import 'package:home_care/Pages/HomePage/Widget/quick_widget.dart';
// import 'package:home_care/Pages/HomePage/Widget/searchbar_widgit.dart';
// import 'package:home_care/Pages/HomePage/Widget/services_widget.dart';

// class HomePageUi extends StatelessWidget {
//   const HomePageUi({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 🔹 Gradient Header
//             Container(
//               padding: const EdgeInsets.only(
//                 top: 45,
//                 left: 16,
//                 right: 16,
//                 bottom: 20,
//               ),
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [Color(0xFF6BC4FF), Color(0xFFE3F2FD)],
//                   // colors: [Color(0xFF82939e), Color(0xFFE3F2FD)],
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Top icons row
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [QuickWidget(), EmergencyUi(), AppoimentUi()],
//                   ),
//                   const SizedBox(height: 16),

//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withValues(alpha: 0.7),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const LocationHomeUi(),
//                   ),
//                   const SizedBox(height: 16),

//                   SearchBarUi(),
//                 ],
//               ),
//             ),

//             // 🔹 Banner section
//             // AssistenceWidgetUi(),
//             const SizedBox(height: 16),
//             // Services
//             HealthCareServicesUi(),

//             // HealthcareCategoriesBar(),
//             const SizedBox(height: 20),

//             // 🔹 Product suggestion section
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 "Still looking for these?",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//             ),

//             const SizedBox(height: 12),

//             AvailableProfessionalsUi(),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//       // bottomNavigationBar: BottomBarPage(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:home_care/Pages/HomePage/Widget/appoimnet_widget.dart';
import 'package:home_care/Pages/HomePage/Widget/emergency_floating.dart';
import 'package:home_care/Pages/HomePage/Widget/emergency_widget.dart';
import 'package:home_care/Pages/HomePage/Widget/location_widget.dart';
import 'package:home_care/Pages/HomePage/Widget/profesnal_widget.dart';
import 'package:home_care/Pages/HomePage/Widget/quick_widget.dart';
import 'package:home_care/Pages/HomePage/Widget/searchbar_widgit.dart';
import 'package:home_care/Pages/HomePage/Widget/services_widget.dart';

class HomePageUi extends StatefulWidget {
  const HomePageUi({super.key});

  @override
  State<HomePageUi> createState() => _HomePageUiState();
}

class _HomePageUiState extends State<HomePageUi> {
  // Initial position for the floating button
  double posX = 280;
  double posY = 500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Gradient Header
                Container(
                  padding: const EdgeInsets.only(
                    top: 45,
                    left: 16,
                    right: 16,
                    bottom: 20,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF6BC4FF), Color(0xFFE3F2FD)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [QuickWidget(), EmergencyUi(), AppoimentUi()],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const LocationHomeUi(),
                      ),
                      const SizedBox(height: 16),
                      SearchBarUi(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                HealthCareServicesUi(),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Still looking for these?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                AvailableProfessionalsUi(),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // 🔹 Draggable Floating Button
          Positioned(
            left: posX,
            top: posY,
            child: Draggable(
              feedback: FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.redAccent,
                child: const Icon(
                  Icons.emergency_outlined,
                  color: Colors.white,
                ),
              ),
              childWhenDragging: Container(), // Hide original while dragging
              onDragEnd: (details) {
                setState(() {
                  posX = details.offset.dx;
                  posY =
                      details.offset.dy -
                      MediaQuery.of(
                        context,
                      ).padding.top; // Adjust for status bar
                });
              },
              child: EmergencyFloatingButton(),

              //  FloatingActionButton(
              //   onPressed: () {
              //     Get.toNamed("/cart"); // Navigate to cart
              //   },
              //   backgroundColor: Colors.redAccent,
              //   child: const Icon(Icons.shopping_cart, color: Colors.white),
              // ),
            ),
          ),
        ],
      ),
    );
  }
}
