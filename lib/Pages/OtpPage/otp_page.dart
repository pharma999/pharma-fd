import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_care/Config/images_config.dart';
import 'package:home_care/Controller/otp_controller.dart';
import 'package:home_care/Pages/OtpPage/Widget/left_circle.dart';
import 'package:home_care/Pages/OtpPage/Widget/right_circle_widget.dart';
import 'package:get/get.dart';

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

  late OtpController _controller;
  late String phoneNumber;
  late String verificationId;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>? ?? {'phoneNumber': ''};

    phoneNumber = args["phoneNumber"].toString();
    verificationId = args["verificationId"] ?? '';

    // Initialize OTP controller with GetX
    _controller = Get.put(OtpController());
    _controller.setPhoneNumber(phoneNumber);

    print(phoneNumber);
    print(verificationId);

    debugPrint("PHONE NUMBER: $phoneNumber");
    debugPrint("VERIFICATION ID: $verificationId");
  }

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

                            const Spacer(), const SizedBox(height: 20),

                            // Error message display
                            Obx(
                              () => _controller.errorMessage.value.isNotEmpty
                                  ? Container(
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(bottom: 15),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.red,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.red.shade50,
                                      ),
                                      child: Text(
                                        _controller.errorMessage.value,
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            const SizedBox(height: 40),

                            // 🟦 Submit Button (not floating)
                            SizedBox(
                              width: double.infinity,
                              child: Obx(
                                () => ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueGrey.shade900,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _controller.isLoading.value
                                      ? null
                                      : () => _controller
                                            .submitOtpWithControllers(
                                              _controllers,
                                            ),
                                  child: _controller.isLoading.value
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Text(
                                          "Submit",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.amber.shade600,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.amber.shade50,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Demo Mode 🧪",
                                    style: TextStyle(
                                      color: Colors.amber.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Use OTP: 5555",
                                    style: TextStyle(
                                      color: Colors.amber.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            Obx(
                              () => GestureDetector(
                                onTap: _controller.canResend.value
                                    ? () => _controller.resendOtp()
                                    : null,
                                child: Text(
                                  _controller.canResend.value
                                      ? "Didn't receive the code? Resend"
                                      : "Resend in ${_controller.secondsRemaining.value}s",
                                  style: TextStyle(
                                    color: _controller.canResend.value
                                        ? Colors.blue
                                        : Colors.black54,
                                    fontSize: 15,
                                  ),
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
