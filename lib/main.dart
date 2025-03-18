import 'package:client_page/routes/app_router.dart';
import 'package:client_page/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'routes/app_pages.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812), // Sesuaikan dengan desain Figma
      minTextAdapt: true,
      builder: (_, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: Routes.SPLASH,
          getPages: AppPages.pages,
          home: child,
        );
      },
      child: SplashScreen(), // Halaman awal
    );
  }
}
