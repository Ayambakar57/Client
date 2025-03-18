import 'package:get/get.dart';
import '../routes/app_router.dart';


class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration(seconds: 3), () {
      Get.offNamed(Routes.LOGIN);
    });
  }
}
