// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:home_care/Helper/phone_number_helper.dart';

// class PhoneNumberController with ChangeNotifier {
//   final formKey = GlobalKey<FormState>();
//   final TextEditingController phoneController = TextEditingController();
//   final FocusNode focusNode = FocusNode();

//   String? completePhoneNumber;
//   String initialCountryCode = "IN";

//   late AnimationController animationController;
//   late Animation<double> fadeAnimation;
//   late Animation<Offset> slideAnimation;

//   /// Initialize all controllers & animations
//   void initController(TickerProvider vsync) {
//     animationController = AnimationController(
//       vsync: vsync,
//       duration: const Duration(milliseconds: 800),
//     );

//     fadeAnimation = CurvedAnimation(
//       parent: animationController,
//       curve: Curves.easeIn,
//     );

//     slideAnimation =
//         Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
//           CurvedAnimation(
//             parent: animationController,
//             curve: Curves.easeOutCubic,
//           ),
//         );

//     animationController.forward();

//     _detectCountryFromLocation();
//   }

//   /// Detect user's country using Geolocator
//   Future<void> _detectCountryFromLocation() async {
//     try {
//       final countryCode = await PhoneNumberHelper.detectCountryCode();
//       if (countryCode != null) {
//         initialCountryCode = countryCode;
//         notifyListeners();
//       }
//     } catch (e) {
//       debugPrint("Error detecting country: $e");
//     }
//   }

//   /// Validate and save phone number
//   bool submit(BuildContext context) {
//     FocusScope.of(context).unfocus();

//     if (formKey.currentState!.validate()) {
//       formKey.currentState!.save();
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //   SnackBar(content: Text('Phone Number: $completePhoneNumber')),
//       // );
//       print("Enter button submitted");
//       Get.offAllNamed("/otpPage");
//       return true;
//     }
//     return false;
//   }

//   /// Dispose controllers
//   void disposeController() {
//     focusNode.dispose();
//     phoneController.dispose();
//     animationController.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Helper/phone_number_helper.dart';

class PhoneNumberController with ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  String? completePhoneNumber;
  String initialCountryCode = "IN";

  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  /// Initialize all controllers & animations
  void initController(TickerProvider vsync) {
    animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 800),
    );

    fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    );

    slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    animationController.forward();

    // 🛠 Run location detection AFTER first frame to avoid blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectCountryFromLocation();
    });
  }

  /// Detect user's country using Geolocator
  Future<void> _detectCountryFromLocation() async {
    try {
      final countryCode = await PhoneNumberHelper.detectCountryCode();
      if (countryCode != null) {
        initialCountryCode = countryCode;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error detecting country: $e");
    }
  }

  /// Validate and save phone number
  bool submit(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      print("Enter button submitted");
      Get.offAllNamed("/otpPage");
      return true;
    }
    return false;
  }

  /// Dispose controllers
  void disposeController() {
    focusNode.dispose();
    phoneController.dispose();
    animationController.dispose();
  }
}
