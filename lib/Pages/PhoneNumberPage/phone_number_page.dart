import 'package:flutter/material.dart';
import 'package:home_care/Controller/phone_number_controller.dart';
import 'package:home_care/Pages/PhoneNumberPage/Widget/appbar_widget.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage>
    with TickerProviderStateMixin {
  late final PhoneNumberController controller;

  @override
  void initState() {
    super.initState();
    controller = PhoneNumberController();
    controller.initController(this);
    // _detectCountryFromLocation();
  }

  @override
  void dispose() {
    controller.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(title: "Health Care"),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: FadeTransition(
            opacity: controller.fadeAnimation,
            child: SlideTransition(
              position: controller.slideAnimation,
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
                            .withValues(alpha: 0.4),
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
                      initialCountryCode: controller.initialCountryCode,
                      // keyboardType: TextInputType.phone,
                      // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      // contextMen: (context, editableTextState) =>
                      //     const SizedBox.shrink(),
                      // showCursor: true,
                      // autofocus: false,
                      onTap: () => FocusScope.of(
                        context,
                      ).requestFocus(controller.focusNode),
                      onChanged: (phone) =>
                          controller.completePhoneNumber = phone.completeNumber,
                      onSaved: (phone) => controller.completePhoneNumber =
                          phone?.completeNumber,
                      validator: (phone) {
                        if (phone == null || phone.number.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (phone.number.length < 6) {
                          return 'Too short';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => controller.submit(context),
                      // onPressed: () => controller.submit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(fontSize: 18),
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
    );
  }
}
