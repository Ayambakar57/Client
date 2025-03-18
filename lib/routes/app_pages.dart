import 'package:get/get.dart';
import '../views/login_screen.dart';
import '../views/splash_screen.dart';
import 'app_router.dart';



class AppPages {
  static final pages = [
    GetPage(name: Routes.SPLASH, page: () => SplashScreen()),
    GetPage(name: Routes.LOGIN, page: () => LoginScreen()),
  ];
}
