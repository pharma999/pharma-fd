import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Controller/otp_controller.dart';
import 'package:get/get.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with TickerProviderStateMixin {
  final int otpLength = 6;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  late OtpController _otpCtrl;
  late String phoneNumber;
  late String verificationId;

  // Entrance animations
  late final AnimationController _entranceCtrl;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardFade;
  late final Animation<double> _headerFade;

  // Per-box scale animation triggered on focus
  late final List<AnimationController> _boxCtrl;
  late final List<Animation<double>> _boxScale;

  // Shake animation on error
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(otpLength, (_) => FocusNode());

    final args = Get.arguments as Map<String, dynamic>? ?? {'phoneNumber': ''};
    phoneNumber = args['phoneNumber'].toString();
    verificationId = args['verificationId'] ?? '';

    _otpCtrl = Get.put(OtpController());
    _otpCtrl.setPhoneNumber(phoneNumber);
    if (verificationId.isNotEmpty) _otpCtrl.setVerificationId(verificationId);

    // Entrance
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerFade = CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.0, 0.5));
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic));
    _cardFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.2, 1.0)));

    // Box pop-in
    _boxCtrl = List.generate(
      otpLength,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        lowerBound: 1.0,
        upperBound: 1.1,
        value: 1.0,
      ),
    );
    _boxScale = _boxCtrl.map((c) => c as Animation<double>).toList();

    // Shake
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );

    _entranceCtrl.forward();

    // Wire focus listeners for box scale animation
    for (int i = 0; i < otpLength; i++) {
      final idx = i;
      _focusNodes[idx].addListener(() {
        if (_focusNodes[idx].hasFocus) {
          _boxCtrl[idx].forward();
        } else {
          _boxCtrl[idx].reverse();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    for (final c in _boxCtrl) { c.dispose(); }
    _entranceCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: kBackground,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Gradient header area ────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.38,
            child: Container(
              decoration: const BoxDecoration(
                gradient: kPrimaryGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────────
          SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: bottomInset + 24),
                child: Column(
                  children: [
                    // ── Header ───────────────────────────────────────────
                    FadeTransition(
                      opacity: _headerFade,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Get.back(),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                                        color: Colors.white, size: 18),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.15),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3), width: 2),
                              ),
                              child: const Icon(Icons.lock_outline_rounded,
                                  color: Colors.white, size: 38),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'OTP Verification',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter the 6-digit code sent to\n$phoneNumber',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 36),
                          ],
                        ),
                      ),
                    ),

                    // ── Card ─────────────────────────────────────────────
                    SlideTransition(
                      position: _cardSlide,
                      child: FadeTransition(
                        opacity: _cardFade,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: kPrimary.withValues(alpha: 0.10),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // OTP boxes
                              AnimatedBuilder(
                                animation: _shakeAnim,
                                builder: (context, child) {
                                  final dx = (_shakeCtrl.isAnimating)
                                      ? 8 * (0.5 - _shakeAnim.value).abs() * 2
                                      : 0.0;
                                  return Transform.translate(
                                    offset: Offset(dx, 0),
                                    child: child,
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(otpLength, (i) => _buildOtpBox(i)),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Error
                              Obx(() {
                                final err = _otpCtrl.errorMessage.value;
                                if (err.isEmpty) return const SizedBox.shrink();
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: kError.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: kError.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: kError, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(err,
                                            style: const TextStyle(
                                                color: kError,
                                                fontSize: 13,
                                                fontFamily: 'Poppins')),
                                      ),
                                    ],
                                  ),
                                );
                              }),

                              // Submit button
                              Obx(() {
                                final loading = _otpCtrl.isLoading.value;
                                return SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: loading
                                        ? null
                                        : () {
                                            _otpCtrl.submitOtpWithControllers(_controllers);
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: loading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor: AlwaysStoppedAnimation(Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            'Verify OTP',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                  ),
                                );
                              }),

                              const SizedBox(height: 20),

                              // Resend
                              Obx(() => Center(
                                    child: GestureDetector(
                                      onTap: _otpCtrl.canResend.value
                                          ? () => _otpCtrl.resendOtp()
                                          : null,
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                              fontFamily: 'Poppins', fontSize: 13),
                                          children: [
                                            TextSpan(
                                              text: "Didn't receive the code? ",
                                              style: TextStyle(color: kTextMedium),
                                            ),
                                            TextSpan(
                                              text: _otpCtrl.canResend.value
                                                  ? 'Resend'
                                                  : 'Resend in ${_otpCtrl.secondsRemaining.value}s',
                                              style: TextStyle(
                                                color: _otpCtrl.canResend.value
                                                    ? kPrimary
                                                    : kTextLight,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )),

                              // Demo mode chip
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: kWarning.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: kWarning.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.science_outlined,
                                        color: kWarning, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Demo mode — use OTP: 000000',
                                      style: TextStyle(
                                          color: kWarning,
                                          fontSize: 12,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return ScaleTransition(
      scale: _boxScale[index],
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            if (_controllers[index].text.isEmpty && index > 0) {
              _controllers[index - 1].clear();
              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
            }
          }
        },
        child: Obx(() {
          final hasError = _otpCtrl.errorMessage.value.isNotEmpty;
          final filled = _controllers[index].text.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 52,
            decoration: BoxDecoration(
              color: filled
                  ? kPrimary.withValues(alpha: 0.07)
                  : kBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError
                    ? kError
                    : filled
                        ? kPrimary
                        : kBorder,
                width: filled ? 2 : 1.5,
              ),
            ),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: kPrimary,
                fontFamily: 'Poppins',
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                if (value.isNotEmpty && index < otpLength - 1) {
                  FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                } else if (value.isEmpty && index > 0) {
                  FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                }
              },
            ),
          );
        }),
      ),
    );
  }
}
