import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/phone_number_controller.dart';
import 'package:home_care/Pages/PhoneNumberPage/Widget/appbar_widget.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneNumberPage extends StatelessWidget {
  const PhoneNumberPage({super.key});

  static const String bypassPhoneNumber = '6386098744';

  void _skipToOtp(BuildContext context) {
    Get.toNamed('/otpPage', arguments: {'phoneNumber': bypassPhoneNumber});
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PhoneNumberController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(title: "Health Care"),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Obx(
            () => FadeTransition(
              opacity: controller.animationController.drive(
                Tween<double>(begin: 0, end: 1),
              ),
              child: SlideTransition(
                position: controller.animationController.drive(
                  Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero),
                ),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.phone_android_rounded,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Enter your phone number",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),
                      IntlPhoneField(
                        controller: controller.phoneController,
                        focusNode: controller.focusNode,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 1.2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        initialCountryCode: controller.countryCode.value,
                        onTap: () => FocusScope.of(
                          context,
                        ).requestFocus(controller.focusNode),
                        onChanged: (phone) =>
                            controller.updatePhoneNumber(phone.completeNumber),
                        onSaved: (phone) => controller.updatePhoneNumber(
                          phone?.completeNumber ?? '',
                        ),
                        validator: (value) =>
                            controller.phoneValidator(value?.completeNumber),
                      ),
                      const SizedBox(height: 30),
                      Obx(
                        () => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.submitPhoneNumber(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 6,
                          ),
                          child: controller.isLoading.value
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
                                  "Continue",
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Obx(
                        () => controller.errorMessage.value.isNotEmpty
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
                                  controller.errorMessage.value,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
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
                              "Use: 6386098744",
                              style: TextStyle(
                                color: Colors.amber.shade700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                controller.completePhoneNumber.value =
                                    '+916386098744';
                                controller.updatePhoneNumber('6386098744');
                                controller.submitPhoneNumber(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade600,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.skip_next),
                              label: const Text("Skip to OTP"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "We’ll send you a verification code to this number.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
