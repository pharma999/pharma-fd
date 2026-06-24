import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Controller/phone_number_controller.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardFade;
  late final Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _headerFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.5),
    );
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entranceCtrl, curve: Curves.easeOutCubic));
    _cardFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _entranceCtrl, curve: const Interval(0.25, 1.0)));
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PhoneNumberController());
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: kBackground,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Gradient header ──────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.40,
            child: Container(
              decoration: const BoxDecoration(
                gradient: kPrimaryGradient,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(36)),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomInset + 24),
              child: Column(
                children: [
                  // Back button
                  FadeTransition(
                    opacity: _headerFade,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.offAllNamed('/welcomePage'),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Illustration + heading
                  FadeTransition(
                    opacity: _headerFade,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.15),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 2),
                            ),
                            child: const Icon(
                                Icons.phone_android_rounded,
                                color: Colors.white,
                                size: 38),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Enter Phone Number',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We\'ll send a verification code\nto confirm your number.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.80),
                              fontSize: 13,
                              fontFamily: 'Poppins',
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 36),
                        ],
                      ),
                    ),
                  ),

                  // ── Card ─────────────────────────────────────────────────
                  SlideTransition(
                    position: _cardSlide,
                    child: FadeTransition(
                      opacity: _cardFade,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
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
                        child: Form(
                          key: controller.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Your Phone Number',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                  color: kTextDark,
                                ),
                              ),
                              const SizedBox(height: 12),
                              IntlPhoneField(
                                controller: controller.phoneController,
                                focusNode: controller.focusNode,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  labelStyle: const TextStyle(
                                      fontFamily: 'Poppins',
                                      color: kTextMedium),
                                  filled: true,
                                  fillColor: kBackground,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: kBorder, width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: kBorder, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: kPrimary, width: 2),
                                  ),
                                ),
                                initialCountryCode:
                                    controller.countryCode.value,
                                onChanged: (phone) => controller
                                    .updatePhoneNumber(phone.completeNumber),
                                onSaved: (phone) => controller.updatePhoneNumber(
                                    phone?.completeNumber ?? ''),
                                validator: (value) =>
                                    controller.phoneValidator(
                                        value?.completeNumber),
                              ),
                              const SizedBox(height: 24),

                              // Continue button
                              Obx(() {
                                final loading = controller.isLoading.value;
                                return SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: loading
                                        ? null
                                        : () => controller
                                            .submitPhoneNumber(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: loading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      Colors.white),
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Continue',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(Icons
                                                  .arrow_forward_rounded,
                                                  size: 18),
                                            ],
                                          ),
                                  ),
                                );
                              }),

                              // Error message
                              Obx(() {
                                final err = controller.errorMessage.value;
                                if (err.isEmpty) return const SizedBox.shrink();
                                return Container(
                                  margin: const EdgeInsets.only(top: 14),
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
                                      const Icon(Icons.error_outline,
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

                              // Demo mode chip
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: kWarning.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: kWarning.withValues(alpha: 0.3)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.science_outlined,
                                            color: kWarning, size: 15),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Demo Mode',
                                          style: TextStyle(
                                            color: kWarning,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Use: 6386098744',
                                      style: TextStyle(
                                          color: kWarning,
                                          fontSize: 12,
                                          fontFamily: 'Poppins'),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () {
                                        controller.completePhoneNumber.value =
                                            '+916386098744';
                                        controller
                                            .updatePhoneNumber('6386098744');
                                        controller.submitPhoneNumber(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: kWarning,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.skip_next,
                                                color: Colors.white, size: 16),
                                            SizedBox(width: 4),
                                            Text(
                                              'Skip to OTP',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ],
                                        ),
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
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
