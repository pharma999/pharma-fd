import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:home_care/Config/images_config.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(
          AssetsImage.heartPic,
          width: 40.w,
          height: 40.w,
          fit: BoxFit.contain,
        ),
        SvgPicture.asset(
          AssetsImage.heartLine,
          width: 40.w,
          height: 40.w,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}
