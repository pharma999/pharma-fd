// import 'package:flutter/material.dart';
// import 'package:home_care/Api/index.dart';
// import 'package:get/get.dart';
// import 'package:home_care/utils/token_storage.dart';

// class OtpController with ChangeNotifier {
//   final AuthApi _authApi = AuthApi();

//   bool isLoading = false;

//   /// 🔹 SUBMIT OTP FROM UI
//   Future<void> submitOtp(
//     List<TextEditingController> controllers, {
//     required String phoneNumber,
//     required String verificationId,
//   }) async {
//     // Join OTP digits
//     final otp = controllers.map((c) => c.text).join();

//     debugPrint("Entered OTP: $otp");

//     if (otp.length != 4) {
//       Get.snackbar("Error", "Please enter a valid 4-digit OTP");
//       return;
//     }

//     await verifyOtp(
//       phoneNumber: phoneNumber,
//       verificationId: verificationId,
//       otp: otp,
//     );
//   }

//   /// 🔹 VERIFY OTP API
//   Future<void> verifyOtp({
//     required String phoneNumber,
//     required String verificationId,
//     required String otp,
//   }) async {
//     isLoading = true;
//     notifyListeners();

//     try {
//       final response = await _authApi.verifyOtp({
//         "phone_number": phoneNumber,
//         "verification_id": verificationId,
//         "otp": otp,
//       });

//       debugPrint("VERIFY OTP RESPONSE:");
//       debugPrint(response.toString());

//       if (response["sucess"] == true) {
//         final token = response["data"]["token"];
//         debugPrint("TOKEN: $token");

//         // await TokenStorage.saveToken(token);
//         try {
//           await TokenStorage.saveToken(token);
//         } catch (e) {
//           debugPrint("TOKEN SAVE ERROR: $e");
//         }

//         Get.offAllNamed("/bottomAppBar");
//       } else {
//         Get.snackbar("Error", "Invalid OTP");
//       }
//     } catch (e) {
//       debugPrint("VERIFY OTP ERROR: $e");
//       Get.snackbar("Error", e.toString());
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
// }

// void resedOtp() {
//   print("Resend Otp Function");
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/utils/token_storage.dart';

class OtpController with ChangeNotifier {
  bool isLoading = false;

  /// 🔹 SUBMIT OTP FROM UI
  Future<void> submitOtp(
    List<TextEditingController> controllers, {
    required String phoneNumber,
    required String verificationId,
  }) async {
    final otp = controllers.map((c) => c.text).join();

    debugPrint("Entered OTP: $otp");

    if (otp.length != 4) {
      Get.snackbar("Error", "Please enter a valid 4-digit OTP");
      return;
    }

    // ✅ HARD-CODED OTP FOR TESTING
    if (otp == "5555") {
      await _loginWithDummyToken();
    } else {
      Get.snackbar("Error", "Invalid OTP");
    }
  }

  /// 🔹 MOCK LOGIN (NO API CALL)
  Future<void> _loginWithDummyToken() async {
    isLoading = true;
    notifyListeners();

    try {
      const dummyToken = "TEST_TOKEN_5555";

      debugPrint("LOGIN SUCCESS WITH TEST OTP");
      debugPrint("TOKEN: $dummyToken");

      await TokenStorage.saveToken(dummyToken);

      Get.offAllNamed("/bottomAppBar");
    } catch (e) {
      debugPrint("TOKEN SAVE ERROR: $e");
      Get.snackbar("Error", "Login failed");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

/// 🔹 RESEND OTP (TEST)
void resedOtp() {
  debugPrint("Resend OTP (Testing Mode)");
}
