import 'package:get/get.dart';

class LoginController extends GetxController {
  var username = ''.obs;
  var password = ''.obs;
  var isPasswordVisible = false.obs; // Untuk toggle visibility password

  void login() {
    // Logika login nanti ditambahkan di sini
    print("Username: ${username.value}, Password: ${password.value}");
  }
}
