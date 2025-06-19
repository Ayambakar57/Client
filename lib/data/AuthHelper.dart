import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/login_model.dart';

class AuthHelper {
  // Keys untuk SharedPreferences
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userDataKey = 'userData';
  static const String _clientIdKey = 'client_id';
  static const String _usernameKey = 'username';

  // Simpan data login
  static Future<void> saveLoginData({
    required UserModel user,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userDataKey, jsonEncode(user.toJson()));
    await prefs.setInt(_clientIdKey, user.id);
    await prefs.setString(_usernameKey, user.name);
  }

  // Ambil status login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Ambil data user
  static Future<UserModel?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Ambil client ID
  static Future<int?> getClientId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_clientIdKey);
    } catch (e) {
      print('Error getting client ID: $e');
      return null;
    }
  }

  // Ambil username
  static Future<String?> getUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_usernameKey);
    } catch (e) {
      print('Error getting username: $e');
      return null;
    }
  }

  // Logout - hapus semua data
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_clientIdKey);
    await prefs.remove(_usernameKey);
  }

  // Clear all auth data
  static Future<void> clearAuthData() async {
    await logout();
  }
}