import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_care/Config/strings_config.dart';

class TextWidget extends StatelessWidget {
  const TextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title
        Text(
          AppString.appName,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF312E81),
          ),
        ),
        SizedBox(height: 16.h),

        // Subtitle
        Text(
          WelcomePageString.postDischarge,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20.sp, color: const Color(0xFF4338CA)),
        ),
        SizedBox(height: 12.h),

        // Taglines
        Text(
          WelcomePageString.qualityHealthCare,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF4338CA),
            height: 1.5,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          WelcomePageString.doorStepForSmaless,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF4338CA),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
