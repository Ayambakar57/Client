import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/routes.dart'; // Import routes

class SplashController extends GetxController {
  var scale = 0.5.obs;
  var showLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    // Start animation
    await Future.delayed(const Duration(milliseconds: 300));
    scale.value = 1;

    // Show loading after animation
    await Future.delayed(const Duration(seconds: 2));
    showLoading.value = true;

    // Check login status and navigate
    await _checkLoginStatusAndNavigate();
  }

  Future<void> _checkLoginStatusAndNavigate() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Debug: Print all saved values
      print('=== DEBUG SPLASH CONTROLLER ===');
      print('Checking SharedPreferences...');

      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      String? userData = prefs.getString('userData');
      String? token = prefs.getString('token');
      int? clientId = prefs.getInt('client_id'); // Tambahan pengecekan client_id

      print('isLoggedIn: $isLoggedIn');
      print('userData exists: ${userData != null}');
      print('token exists: ${token != null && token.isNotEmpty}');
      print('client_id exists: ${clientId != null}');

      // Wait a bit more to ensure loading animation is visible
      await Future.delayed(const Duration(milliseconds: 500));

      // PERBAIKAN: Pastikan semua data login ada dan valid
      if (isLoggedIn &&
          userData != null &&
          token != null &&
          token.isNotEmpty &&
          clientId != null &&
          clientId > 0) {
        print('User is logged in, navigating to home');
        // PERBAIKAN: Gunakan Routes.home yang konsisten dengan LoginController
        Get.offNamed(Routes.home);
      } else {
        print('User is not logged in or missing data, navigating to login');
        // Clear any invalid data
        await _clearInvalidLoginData(prefs);
        Get.offNamed('/login');
      }
    } catch (e) {
      print('Error in _checkLoginStatusAndNavigate: $e');
      // On error, clear data and go to login
      final prefs = await SharedPreferences.getInstance();
      await _clearInvalidLoginData(prefs);
      Get.offNamed('/login');
    }
  }

  Future<void> _clearInvalidLoginData(SharedPreferences prefs) async {
    try {
      await prefs.remove('isLoggedIn');
      await prefs.remove('userData');
      await prefs.remove('token');
      await prefs.remove('client_id'); // Tambahan pembersihan client_id
      await prefs.remove('scanned_company_id');
      await prefs.remove('scanned_company_name');
      await prefs.remove('company_id'); // Tambahan pembersihan company_id
      print('Cleared invalid login data');
    } catch (e) {
      print('Error clearing invalid login data: $e');
    }
  }
}