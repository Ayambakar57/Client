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

    isLoading.value = true;

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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userData', jsonEncode(result.user!.toJson()));

      // Simpan token ke SharedPreferences
      if (result.token != null && result.token!.isNotEmpty) {
        await prefs.setString('token', result.token!);
        print('✅ Login berhasil!');
        print('📱 Token berhasil disimpan: ${result.token!}');
        print('👤 User: ${result.user!.name}');
        print('🔑 Role: ${result.user!.role}');
      } else {
        print('⚠️ Login berhasil tapi token tidak ditemukan atau kosong');
      }

      // PERBAIKAN: Simpan client_id ke SharedPreferences
      // Asumsikan user model memiliki property id yang merupakan client_id
      if (result.user!.id != null) {
        await prefs.setInt('client_id', result.user!.id);
        print('🆔 Client ID berhasil disimpan: ${result.user!.id}');
      } else {
        print('⚠️ Client ID tidak ditemukan dalam user data');
      }

      Get.snackbar("Login Berhasil", result.message,
          snackPosition: SnackPosition.TOP);
      Get.offNamed(Routes.home);
    } else {
      loginError.value = result.message;
    }
  }

  // Method untuk mengambil token dari SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // PERBAIKAN: Method untuk mengambil client_id dari SharedPreferences
  static Future<int?> getClientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('client_id');
  }

  // Method untuk menghapus token saat logout
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // PERBAIKAN: Method untuk menghapus client_id saat logout
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

  // PERBAIKAN: Method untuk mengecek apakah client_id masih ada
  static Future<bool> hasClientId() async {
    final prefs = await SharedPreferences.getInstance();
    int? clientId = prefs.getInt('client_id');
    return clientId != null && clientId > 0;
  }

  // PERBAIKAN: Method untuk logout yang membersihkan semua data
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userData');
    await prefs.remove('token');
    await prefs.remove('client_id');
    await prefs.remove('company_id'); // Juga hapus company_id jika ada
    print('🚪 Logout berhasil, semua data dihapus');
  }
}