// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:home_care/Pages/WelcomePage/Widget/login_button.dart';
// import 'package:home_care/Pages/WelcomePage/Widget/text_widget.dart';
// import 'package:home_care/Pages/WelcomePage/Widget/logo_widget.dart';

// class WelcomePage extends StatelessWidget {
//   const WelcomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFEEF2FF), Color(0xFFFFFFFF)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Padding(
//           padding: EdgeInsets.symmetric(vertical: 50.w, horizontal: 20.w),
//           child: SizedBox(
//             height: 1.sh, // full screen height
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Top content
//                   Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // Circle Icon
//                         Container(
//                           width: 90.w,
//                           height: 90.w,
//                           decoration: const BoxDecoration(
//                             shape: BoxShape.circle,
//                             gradient: LinearGradient(
//                               colors: [Color(0xFF6366F1), Color(0xFF9333EA)],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                           ),
//                           child: Center(child: LogoWidget()),
//                         ),
//                         SizedBox(height: 30.h),
//                         TextWidget(),
//                       ],
//                     ),
//                   ),

//                   // Bottom button
//                   LogInButton(),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_care/Pages/WelcomePage/Widget/login_button.dart';
import 'package:home_care/Pages/WelcomePage/Widget/text_widget.dart';
import 'package:home_care/Pages/WelcomePage/Widget/logo_widget.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              // theme.colorScheme.surface,
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(
                context,
              ).colorScheme.primaryContainer, // adapts to dark/light
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 50.w, horizontal: 20.w),
          child: SizedBox(
            height: 1.sh,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top content
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Circle Icon with adaptive colors
                        Container(
                          width: 90.w,
                          height: 90.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(child: const LogoWidget()),
                        ),

                        SizedBox(height: 30.h),
                        const TextWidget(),
                      ],
                    ),
                  ),

                  // Bottom button
                  const LogInButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
