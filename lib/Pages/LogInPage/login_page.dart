import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../Api/Services/auth_repository.dart';
import '../../Api/Core/api_result.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final _auth = AuthRepository();

  bool isPhoneInput = true;
  String phoneNumber = '';
  bool _loading = false;
  String _error = '';
  String _devHint = '';

  // OTP resend countdown
  int _resendSeconds = 0;
  Timer? _resendTimer;

  static const int _otpLength = 6;

  final List<TextEditingController> otpControllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> otpFocusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds <= 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  void _onKeyPressed(String key) {
    if (_loading) return;
    setState(() {
      _error = '';
      if (key == '⌫') {
        if (phoneNumber.isNotEmpty) {
          phoneNumber = phoneNumber.substring(0, phoneNumber.length - 1);
        }
      } else if (RegExp(r'[0-9]').hasMatch(key) && phoneNumber.length < 10) {
        phoneNumber += key;
      }
    });
  }

  void _onClearPressed() {
    setState(() {
      phoneNumber = '';
      _error = '';
    });
  }

  Future<void> _generateOtp() async {
    if (phoneNumber.length < 10) {
      setState(() => _error = 'Please enter a valid 10-digit phone number');
      return;
    }
    setState(() {
      _loading = true;
      _error = '';
      _devHint = '';
    });

    final result = await _auth.sendOtp(phoneNumber: '+91$phoneNumber');

    setState(() => _loading = false);

    if (result is Success) {
      final data = (result as Success).data as Map<String, dynamic>;
      final msg = (data['message'] ?? '').toString();
      final devMode = msg.toUpperCase().contains('DEV');

      setState(() {
        isPhoneInput = false;
        _error = '';
        if (devMode) {
          _devHint = 'DEV mode: use OTP 000000';
          for (int i = 0; i < _otpLength; i++) {
            otpControllers[i].text = '0';
          }
        }
      });
      _startResendTimer();
      FocusScope.of(context).requestFocus(otpFocusNodes[0]);
    } else {
      setState(() => _error = (result as Error).message);
    }
  }

  Future<void> _resendOtp() async {
    if (_resendSeconds > 0 || _loading) return;
    await _generateOtp();
    if (!isPhoneInput) {
      // already switched; just restart timer (done inside _generateOtp)
      setState(() {});
    }
  }

  Future<void> _onOtpComplete() async {
    final otp = otpControllers.map((c) => c.text).join();
    if (otp.length < _otpLength) {
      setState(() => _error = 'Enter the $_otpLength-digit OTP');
      return;
    }
    setState(() {
      _loading = true;
      _error = '';
    });

    final result = await _auth.verifyOtp(
      phoneNumber: '+91$phoneNumber',
      otp: otp,
    );

    setState(() => _loading = false);

    if (result is Success) {
      Get.offAllNamed('/bottomAppBar');
    } else {
      setState(() => _error = (result as Error).message);
    }
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
                  "We'll send you a 6 digit verification code",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Phone number display field
                Container(
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
                                child: const Icon(Icons.close,
                                    color: Colors.grey, size: 24),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (_error.isNotEmpty) _errorBanner(_error),

                const SizedBox(height: 20),

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

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _generateOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text(
                            'GENERATE OTP',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],

              // OTP INPUT SCREEN
              if (!isPhoneInput) ...[
                Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    onPressed: _loading
                        ? null
                        : () {
                            _resendTimer?.cancel();
                            setState(() {
                              isPhoneInput = true;
                              _error = '';
                              _devHint = '';
                              for (final c in otpControllers) {
                                c.clear();
                              }
                            });
                          },
                  ),
                  Expanded(
                    child: Text(
                      'OTP sent to +91 $phoneNumber',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),

                if (_devHint.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.shade400),
                    ),
                    child: Row(children: [
                      Icon(Icons.developer_mode,
                          color: Colors.amber.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _devHint,
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ]),
                  ),

                Text(
                  'Enter the $_otpLength digit code sent to +91 $phoneNumber',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_otpLength, (index) {
                    return SizedBox(
                      width: 44,
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
                            if (index < _otpLength - 1) {
                              otpFocusNodes[index + 1].requestFocus();
                            } else {
                              otpFocusNodes[index].unfocus();
                              _onOtpComplete();
                            }
                          } else if (value.isEmpty && index > 0) {
                            otpFocusNodes[index - 1].requestFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                if (_error.isNotEmpty) _errorBanner(_error),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive OTP? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: (_resendSeconds > 0 || _loading)
                          ? null
                          : _resendOtp,
                      child: _resendSeconds > 0
                          ? Text(
                              'Resend in ${_resendSeconds}s',
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 13),
                            )
                          : const Text(
                              'RESEND',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _onOtpComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text(
                            'VERIFY & CONTINUE',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorBanner(String msg) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(msg,
                style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
          ),
        ]),
      );

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
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 10)),
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
