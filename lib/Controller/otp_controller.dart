import 'package:flutter/material.dart';
import 'package:get/get.dart';

void submitOtp(List<TextEditingController> controllers) {
  // Join all text values into a single string
  String otp = controllers.map((c) => c.text).join();

  print("Entered OTP: $otp");

  // Validate OTP
  if (otp.length < 4) {
    print("❌ Please enter a valid 4-digit OTP");
    return;
  }

  // Proceed with your logic (e.g., API call)
  print("✅ Submitting OTP: $otp");
  Get.offAllNamed("/bottomAppBar");
}

void resedOtp() {
  print("Resend Otp Function");
}
