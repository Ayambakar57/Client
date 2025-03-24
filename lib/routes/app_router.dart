import 'package:get/get.dart';
import '../bindings/detail_data_binding.dart';
import '../bindings/login_binding.dart';
import '../bindings/splash_binding.dart';
import '../views/detail_data_screen.dart';
import '../views/login_screen.dart';
import '../views/splash_screen.dart';

class Routes {
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const HOME = '/home';

  static final routes = [
    GetPage(
      name: SPLASH,
      page: () => SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: LOGIN,
      page: () => LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: HOME,
      page: () => DetailDataView(),
      binding: DetailDataBinding(),
    ),
  ];
}
