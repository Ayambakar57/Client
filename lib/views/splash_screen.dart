import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  final SplashController controller = Get.find<SplashController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDDE7DC),
      body: Center(
        child: SvgPicture.asset(
          'assets/images/logo.svg',
          width: 140.w, // Gunakan ScreenUtil
        ),
      ),
    );
  }
}
