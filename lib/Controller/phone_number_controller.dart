import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Api/services/auth_api.dart';
import 'package:home_care/Helper/phone_number_helper.dart';

class PhoneNumberController with ChangeNotifier {
  final AuthApi _authApi = AuthApi();
  final formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  String? completePhoneNumber;
  String initialCountryCode = "IN";

  bool isLoading = false;

  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  /// 🔹 DUMMY VALUES (TEST MODE)
  static const String dummyPhoneNumber = "6386098744";
  static const String dummyVerificationId = "3782559";

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

  // Validate and save phone number
  // bool submit(BuildContext context) {
  //   FocusScope.of(context).unfocus();

  //   if (formKey.currentState!.validate()) {
  //     formKey.currentState!.save();
  //     print("Enter button submitted");
  //     Get.offAllNamed("/otpPage");
  //     return true;
  //   }
  //   return false;
  // }

  Future<void> submit(BuildContext context) async {
    FocusScope.of(context).unfocus();

    isLoading = true;
    notifyListeners();

    try {
      // final response = await _authApi.login({
      //   "phone_number": phoneController.text.trim(),
      // });

      // debugPrint("LOGIN API RESPONSE:");
      // debugPrint(response.toString());

      // if (response["sucess"] == true) {
      //   Get.toNamed("/otpPage", arguments: response["data"]);

      // } else {
      //   Get.snackbar("Error", "OTP sending failed");
      // }

      Get.toNamed(
        "/otpPage",
        arguments: {
          "phoneNumber": dummyPhoneNumber,
          "verificationId": dummyVerificationId,
        },
      );
    } catch (e) {
      debugPrint("API ERROR: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Dispose controllers
  void disposeController() {
    focusNode.dispose();
    phoneController.dispose();
    animationController.dispose();
  }
}
