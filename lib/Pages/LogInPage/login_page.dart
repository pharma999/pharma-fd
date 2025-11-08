import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  bool isPhoneInput = true;
  String phoneNumber = '';
  final List<TextEditingController> otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      otpFocusNodes[i].addListener(() {
        if (otpFocusNodes[i].hasFocus && otpControllers[i].text.length == 1) {
          otpFocusNodes[i + 1].requestFocus();
        }
      });
    }
    otpFocusNodes[3].addListener(() {
      if (otpFocusNodes[3].hasFocus && otpControllers[3].text.length == 1) {
        otpFocusNodes[3].unfocus();
        _onOtpComplete();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (key == '⌫') {
        if (phoneNumber.isNotEmpty) {
          phoneNumber = phoneNumber.substring(0, phoneNumber.length - 1);
        }
      } else if (RegExp(r'[0-9]').hasMatch(key)) {
        phoneNumber += key;
      }
    });
  }

  void _onClearPressed() {
    setState(() {
      phoneNumber = '';
    });
  }

  void _generateOtp() {
    if (phoneNumber.length >= 10) {
      setState(() {
        isPhoneInput = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('OTP sent to +91 $phoneNumber')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
    }
  }

  void _onOtpComplete() {
    String otp = otpControllers.map((c) => c.text).join();
    if (otp.length == 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('OTP verified: $otp')));
      // Navigate to next page here if needed
    }
  }

  void _resendOtp() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('OTP resent')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Mobile - Phone Number Verification',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 60),

              // PHONE INPUT SCREEN
              if (isPhoneInput) ...[
                const Text(
                  'Enter your phone number',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "We'll send you a 4 digit verification code",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Phone number display field
                GestureDetector(
                  onTap: () {},
                  child: AbsorbPointer(
                    absorbing: true,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '+91',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  phoneNumber,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18,
                                  ),
                                ),
                                if (phoneNumber.isNotEmpty)
                                  GestureDetector(
                                    onTap: _onClearPressed,
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // CUSTOM KEYPAD (FIXED)
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildKeyButton('1', ''),
                          _buildKeyButton('2', 'ABC'),
                          _buildKeyButton('3', 'DEF'),
                          _buildKeyButton('4', 'GHI'),
                          _buildKeyButton('5', 'JKL'),
                          _buildKeyButton('6', 'MNO'),
                          _buildKeyButton('7', 'PQRS'),
                          _buildKeyButton('8', 'TUV'),
                          _buildKeyButton('9', 'WXYZ'),
                          _buildKeyButton('+', ''),
                          _buildKeyButton('0', ''),
                          _buildBackspaceButton(),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Generate OTP button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _generateOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'GENERATE OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],

              // OTP INPUT SCREEN
              if (!isPhoneInput) ...[
                const Text(
                  'Enter OTP',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Enter the 4 digit code sent to +91 $phoneNumber',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 56,
                      child: TextField(
                        controller: otpControllers[index],
                        focusNode: otpFocusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        onChanged: (value) {
                          if (value.length == 1) {
                            if (index < 3) {
                              otpFocusNodes[index + 1].requestFocus();
                            } else {
                              _onOtpComplete();
                            }
                          }
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive OTP? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: _resendOtp,
                      child: const Text(
                        'RESEND',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _onOtpComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'VERIFY & CONTINUE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],

              if (isPhoneInput) const Spacer(),
              if (isPhoneInput) ...[],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyButton(String key, String label) {
    return GestureDetector(
      onTap: () => _onKeyPressed(key),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              key,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (label.isNotEmpty)
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: () => _onKeyPressed('⌫'),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Icon(Icons.backspace, color: Colors.grey, size: 28),
      ),
    );
  }
}
