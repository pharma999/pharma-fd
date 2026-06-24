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
        Text(
          AppString.appName,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            fontFamily: 'Poppins',
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          WelcomePageString.postDischarge,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            fontFamily: 'Poppins',
            color: Colors.white.withValues(alpha: 0.85),
            height: 1.5,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          WelcomePageString.qualityHealthCare,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.sp,
            fontFamily: 'Poppins',
            color: Colors.white.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
