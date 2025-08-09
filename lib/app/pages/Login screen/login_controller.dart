import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/login_service.dart';
import '../../../routes/routes.dart';

final isLoading = false.obs;

class LoginController extends GetxController {
  var isPasswordHidden = true.obs;
  var nameController = TextEditingController();
  var passwordController = TextEditingController();
  var isLoading = false.obs;
  var loginError = ''.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void login() async {
    isLoading.value = true;
    String name = nameController.text.trim();
    String password = passwordController.text.trim();

    loginError.value = "";

    if (name.isEmpty || password.isEmpty) {
      loginError.value = "Username atau password tidak boleh kosong";
      isLoading.value = false;
      return;
    }

    final result = await LoginService.login(
      name: name,
      password: password,
    );

    isLoading.value = false;

    if (result.success) {
      if (result.user == null) {
        loginError.value = "Username atau password salah";
        return;
      }

      if (result.user!.role.toLowerCase() != 'client') {
        loginError.value = "Username atau password salah";
        return;
      }

      // PERBAIKAN: Validasi lebih ketat sebelum menyimpan
      if (result.token == null || result.token!.isEmpty) {
        loginError.value = "Login gagal: Token tidak valid";
        return;
      }

      if (result.user!.id == null || result.user!.id <= 0) {
        loginError.value = "Login gagal: Data user tidak lengkap";
        return;
      }

      try {
        final prefs = await SharedPreferences.getInstance();

        // Simpan semua data login secara berurutan
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userData', jsonEncode(result.user!.toJson()));
        await prefs.setString('token', result.token!);
        await prefs.setInt('client_id', result.user!.id);
        await prefs.setString('nama', result.user!.name);

        // OPSIONAL: Simpan juga data user lainnya jika diperlukan
        // await prefs.setString('user_role', result.user!.role);
        // await prefs.setString('user_email', result.user!.email ?? '');

        // Debug: Verifikasi data tersimpan
        print('✅ Login berhasil!');
        print('📱 Token tersimpan: ${prefs.getString('token')}');
        print('👤 User: ${result.user!.name}');
        print('🔑 Role: ${result.user!.role}');
        print('🆔 Client ID tersimpan: ${prefs.getInt('client_id')}');
        print('💾 isLoggedIn: ${prefs.getBool('isLoggedIn')}');

        // Verifikasi semua data tersimpan dengan benar
        bool allDataSaved = prefs.getBool('isLoggedIn') == true &&
            prefs.getString('token') != null &&
            prefs.getInt('client_id') != null &&
            prefs.getString('userData') != null;

        if (!allDataSaved) {
          loginError.value = "Login gagal: Error menyimpan data";
          await _clearAllLoginData(prefs);
          return;
        }

        Get.snackbar(
            "Login Berhasil",
            result.message,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white
        );

        // Navigasi ke halaman utama
        Get.offNamed(Routes.home);

      } catch (e) {
        print('❌ Error menyimpan data login: $e');
        loginError.value = "Login gagal: Error sistem";
        final prefs = await SharedPreferences.getInstance();
        await _clearAllLoginData(prefs);
      }
    } else {
      loginError.value = result.message;
    }
  }

  // PERBAIKAN: Method untuk membersihkan semua data login
  Future<void> _clearAllLoginData(SharedPreferences prefs) async {
    try {
      await prefs.remove('isLoggedIn');
      await prefs.remove('userData');
      await prefs.remove('token');
      await prefs.remove('client_id');
      await prefs.remove('nama');
      await prefs.remove('company_id');
      await prefs.remove('scanned_company_id');
      await prefs.remove('scanned_company_name');
      print('🧹 Semua data login dihapus');
    } catch (e) {
      print('❌ Error clearing login data: $e');
    }
  }

  // Method tambahan untuk mengambil nama user
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nama');
  }

  // Method tambahan untuk mengambil semua data user
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('userData');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Method untuk mengambil client_id dari SharedPreferences
  static Future<int?> getClientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('client_id');
  }

  // Method untuk menghapus token saat logout
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Method untuk menghapus client_id saat logout
  static Future<void> removeClientId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('client_id');
  }

  // Method untuk mengecek apakah token masih ada
  static Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  // Method untuk mengecek apakah client_id masih ada
  static Future<bool> hasClientId() async {
    final prefs = await SharedPreferences.getInstance();
    int? clientId = prefs.getInt('client_id');
    return clientId != null && clientId > 0;
  }

  // PERBAIKAN: Method untuk logout yang membersihkan semua data
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Bersihkan semua SharedPreferences
    print('🚪 Logout berhasil, semua data dihapus');
    Get.offAllNamed('/login'); // Kembali ke login dan hapus semua route stack
  }

  // PERBAIKAN: Method untuk validasi status login lengkap
  static Future<bool> isCompletelyLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? token = prefs.getString('token');
    int? clientId = prefs.getInt('client_id');
    String? userData = prefs.getString('userData');

    bool isComplete = isLoggedIn &&
        token != null &&
        token.isNotEmpty &&
        clientId != null &&
        clientId > 0 &&
        userData != null;

    print('🔍 Login status check:');
    print('  - isLoggedIn: $isLoggedIn');
    print('  - has token: ${token != null && token.isNotEmpty}');
    print('  - has client_id: ${clientId != null && clientId > 0}');
    print('  - has userData: ${userData != null}');
    print('  - Complete: $isComplete');

    return isComplete;
  }
}