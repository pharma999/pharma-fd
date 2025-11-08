// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // Import this for FilteringTextInputFormatter, LogicalKeyboardKey
// import 'package:home_care/Config/images_config.dart';
// import 'package:home_care/Controller/otp_controller.dart';
// import 'package:home_care/Pages/OtpPage/Widget/left_circle.dart';
// import 'package:home_care/Pages/OtpPage/Widget/right_circle_widget.dart';

// class OtpVerificationPage extends StatefulWidget {
//   const OtpVerificationPage({super.key});

//   @override
//   State<OtpVerificationPage> createState() => _OtpVerificationPageState();
// }

// class _OtpVerificationPageState extends State<OtpVerificationPage> {
//   final List<TextEditingController> _controllers = List.generate(
//     4,
//     (_) => TextEditingController(),
//   );

//   final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

//   @override
//   void dispose() {
//     for (final c in _controllers) {
//       c.dispose();
//     }
//     for (final f in _focusNodes) {
//       f.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // resizeToAvoidBottomInset: false,
//       resizeToAvoidBottomInset: true,
//       backgroundColor: Colors.white,
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: Stack(
//           children: [
//             // ✅ Gradient Background Circles
//             Positioned(top: -70, left: -70, child: LeftCircleWidget()),
//             Positioned(top: -100, right: -100, child: RightCircleWidget()),

//             // ✅ Foreground Content
//             SingleChildScrollView(
//               child: SafeArea(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       // 🟩 SEGMENT 1 — Header
//                       Column(
//                         children: const [
//                           SizedBox(height: 20),
//                           Text(
//                             "OTP Verification",
//                             style: TextStyle(
//                               fontSize: 26,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             "Enter the OTP sent to your phone number",
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Colors.black54,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),

//                       // 🟨 SEGMENT 2 — Image & OTP Fields
//                       Column(
//                         children: [
//                           Image.asset(AssetsImage.otpImage, height: 200),
//                           const SizedBox(height: 30),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: List.generate(
//                               4,
//                               (index) => RawKeyboardListener(
//                                 // 👈 ADDED RawKeyboardListener
//                                 focusNode:
//                                     FocusNode(), // It needs its own local focus node
//                                 onKey: (event) {
//                                   if (event.runtimeType == RawKeyDownEvent &&
//                                       event.logicalKey ==
//                                           LogicalKeyboardKey.backspace) {
//                                     // If the field is empty and it's not the first field
//                                     if (_controllers[index].text.isEmpty &&
//                                         index > 0) {
//                                       FocusScope.of(
//                                         context,
//                                       ).requestFocus(_focusNodes[index - 1]);
//                                       _controllers[index - 1]
//                                           .clear(); // Clear the previous field
//                                     }
//                                   }
//                                 },
//                                 child: Container(
//                                   width: 60,
//                                   height: 60,
//                                   alignment: Alignment.center,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: Border.all(
//                                       color: Colors.black26,
//                                       width: 1.5,
//                                     ),
//                                   ),
//                                   child: TextField(
//                                     controller: _controllers[index],
//                                     focusNode: _focusNodes[index],
//                                     textAlign: TextAlign.center,
//                                     style: const TextStyle(fontSize: 22),
//                                     keyboardType: TextInputType.number,
//                                     maxLength: 1,
//                                     inputFormatters: [
//                                       // Optional: ensure only digits are entered
//                                       FilteringTextInputFormatter.digitsOnly,
//                                     ],
//                                     decoration: const InputDecoration(
//                                       counterText: '',
//                                       border: InputBorder.none,
//                                     ),
//                                     onChanged: (value) {
//                                       if (value.isNotEmpty && index < 3) {
//                                         // Move to the next field
//                                         FocusScope.of(
//                                           context,
//                                         ).requestFocus(_focusNodes[index + 1]);
//                                       } else if (value.isEmpty && index > 0) {
//                                         // Handle change when clearing the field if it had text,
//                                         // but RawKeyboardListener handles empty field backspace better
//                                       }
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),

//                       // 🟦 SEGMENT 3 — Button + Resend Text
//                       Column(
//                         children: [
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blueGrey.shade900,
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 16,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               onPressed: () => submitOtp(_controllers),

//                               child: const Text(
//                                 "Submit",
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 15),
//                           Container(
//                             padding: const EdgeInsets.all(0.5),
//                             child: GestureDetector(
//                               onTap: () => resedOtp(),
//                               child: const Text(
//                                 "Didn’t receive the code? Resend",
//                                 style: TextStyle(
//                                   color: Colors.black54,
//                                   fontSize: 15,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:home_care/Config/images_config.dart';
// import 'package:home_care/Controller/otp_controller.dart';
// import 'package:home_care/Pages/OtpPage/Widget/left_circle.dart';
// import 'package:home_care/Pages/OtpPage/Widget/right_circle_widget.dart';

// class OtpVerificationPage extends StatefulWidget {
//   const OtpVerificationPage({super.key});

//   @override
//   State<OtpVerificationPage> createState() => _OtpVerificationPageState();
// }

// class _OtpVerificationPageState extends State<OtpVerificationPage> {
//   final List<TextEditingController> _controllers = List.generate(
//     4,
//     (_) => TextEditingController(),
//   );
//   final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

//   @override
//   void dispose() {
//     for (final c in _controllers) {
//       c.dispose();
//     }
//     for (final f in _focusNodes) {
//       f.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       resizeToAvoidBottomInset: true,
//       body: SafeArea(
//         child: GestureDetector(
//           onTap: () => FocusScope.of(context).unfocus(),
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               return SingleChildScrollView(
//                 padding: EdgeInsets.only(
//                   left: 24,
//                   right: 24,
//                   bottom: MediaQuery.of(context).viewInsets.bottom + 24,
//                 ),
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                   child: IntrinsicHeight(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [

//                         const SizedBox(height: 40),
//                         const Text(
//                           "OTP Verification",
//                           style: TextStyle(
//                             fontSize: 26,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         const Text(
//                           "Enter the OTP sent to your phone number",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: Colors.black54,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 30),
//                         Image.asset(AssetsImage.otpImage, height: 200),
//                         const SizedBox(height: 40),

//                         // OTP Input Fields
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: List.generate(
//                             4,
//                             (index) => Container(
//                               width: 60,
//                               height: 60,
//                               alignment: Alignment.center,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                   color: Colors.black26,
//                                   width: 1.5,
//                                 ),
//                               ),
//                               child: TextField(
//                                 controller: _controllers[index],
//                                 focusNode: _focusNodes[index],
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(fontSize: 22),
//                                 keyboardType: TextInputType.number,
//                                 maxLength: 1,
//                                 inputFormatters: [
//                                   FilteringTextInputFormatter.digitsOnly,
//                                 ],
//                                 decoration: const InputDecoration(
//                                   counterText: '',
//                                   border: InputBorder.none,
//                                 ),
//                                 onChanged: (value) {
//                                   if (value.isNotEmpty && index < 3) {
//                                     FocusScope.of(
//                                       context,
//                                     ).requestFocus(_focusNodes[index + 1]);
//                                   }
//                                 },
//                               ),
//                             ),
//                           ),
//                         ),
//                         const Spacer(),
//                         const SizedBox(height: 40),

//                         // Submit button (NOT floating)
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blueGrey.shade900,
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             onPressed: () => submitOtp(_controllers),
//                             child: const Text(
//                               "Submit",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         GestureDetector(
//                           onTap: () => resedOtp(),
//                           child: const Text(
//                             "Didn’t receive the code? Resend",
//                             style: TextStyle(
//                               color: Colors.black54,
//                               fontSize: 15,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_care/Config/images_config.dart';
import 'package:home_care/Controller/otp_controller.dart';
import 'package:home_care/Pages/OtpPage/Widget/left_circle.dart';
import 'package:home_care/Pages/OtpPage/Widget/right_circle_widget.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 🟡 Background Circles
          const Positioned(top: -70, left: -70, child: LeftCircleWidget()),
          const Positioned(top: -100, right: -100, child: RightCircleWidget()),

          // 🟢 Main Content (scrollable and keyboard-safe)
          SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: bottomInset + 24,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            const Text(
                              "OTP Verification",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Enter the OTP sent to your phone number",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Image.asset(AssetsImage.otpImage, height: 200),
                            const SizedBox(height: 40),

                            // 🔢 OTP Boxes
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            //   children: List.generate(
                            //     4,
                            //     (index) => Container(
                            //       width: 60,
                            //       height: 60,
                            //       alignment: Alignment.center,
                            //       decoration: BoxDecoration(
                            //         borderRadius: BorderRadius.circular(12),
                            //         border: Border.all(
                            //           color: Colors.black26,
                            //           width: 1.5,
                            //         ),
                            //       ),
                            //       child: TextField(
                            //         controller: _controllers[index],
                            //         focusNode: _focusNodes[index],
                            //         textAlign: TextAlign.center,
                            //         style: const TextStyle(fontSize: 22),
                            //         keyboardType: TextInputType.number,
                            //         maxLength: 1,
                            //         inputFormatters: [
                            //           FilteringTextInputFormatter.digitsOnly,
                            //         ],
                            //         decoration: const InputDecoration(
                            //           counterText: '',
                            //           border: InputBorder.none,
                            //         ),
                            //         onChanged: (value) {
                            //           if (value.isNotEmpty && index < 3) {
                            //             FocusScope.of(
                            //               context,
                            //             ).requestFocus(_focusNodes[index + 1]);
                            //           }
                            //           // If current field is empty, move focus to the previous one
                            //           if (_controllers[index].text.isEmpty &&
                            //               index > 0) {
                            //             _controllers[index - 1].clear();
                            //             FocusScope.of(
                            //               context,
                            //             ).requestFocus(_focusNodes[index - 1]);
                            //           }
                            //         },
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                4,
                                (index) => RawKeyboardListener(
                                  focusNode: FocusNode(),
                                  onKey: (RawKeyEvent event) {
                                    if (event is RawKeyDownEvent &&
                                        event.logicalKey ==
                                            LogicalKeyboardKey.backspace) {
                                      // If current field is empty → move to previous
                                      if (_controllers[index].text.isEmpty &&
                                          index > 0) {
                                        _controllers[index - 1].clear();
                                        FocusScope.of(
                                          context,
                                        ).requestFocus(_focusNodes[index - 1]);
                                      }
                                    }
                                  },
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.black26,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _controllers[index],
                                      focusNode: _focusNodes[index],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 22),
                                      keyboardType: TextInputType.number,
                                      maxLength: 1,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: const InputDecoration(
                                        counterText: '',
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (value) {
                                        if (value.isNotEmpty && index < 3) {
                                          // Move focus to next box
                                          FocusScope.of(context).requestFocus(
                                            _focusNodes[index + 1],
                                          );
                                        }
                                        // Auto move back if value cleared manually
                                        else if (value.isEmpty && index > 0) {
                                          FocusScope.of(context).requestFocus(
                                            _focusNodes[index - 1],
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(),
                            const SizedBox(height: 40),

                            // 🟦 Submit Button (not floating)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey.shade900,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => submitOtp(_controllers),
                                child: const Text(
                                  "Submit",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => resedOtp(),
                              child: const Text(
                                "Didn’t receive the code? Resend",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
