import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import 'api.dart';

class AuthService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConfig.authTokenKey)?.trim();
    return (token != null && token.isNotEmpty) ? token : null;
  }

  static Future<bool> isLoggedIn() async => (await getToken()) != null;

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.authTokenKey);
    await prefs.remove(AppConfig.userNameKey);
  }

  static Future<String?> login(String email, String password) async {
    if (!AppConfig.authEnabled || AppConfig.loginPath == null || AppConfig.loginPath!.isEmpty) {
      throw FriendlyException('Login is currently unavailable. Please try again later.');
    }

    final data = await ApiService.login(email, password);
    final token = '${data['token'] ?? data['access_token'] ?? ''}'.trim();
    if (token.isEmpty) {
      throw FriendlyException('Login failed. Please check your email and password.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.authTokenKey, token);
    await prefs.setString(AppConfig.userNameKey, '${data['user']?['name'] ?? data['name'] ?? email}');
    return token;
  }

  static Future<void> logout() async => clearAuthData();

  static Future<String?> register(String name, String email, String password) async {
    if (!AppConfig.authEnabled || AppConfig.registerPath == null || AppConfig.registerPath!.isEmpty) {
      throw FriendlyException('Registration is currently unavailable. Please try again later.');
    }

    final data = await ApiService.register(name, email, password);
    final token = '${data['token'] ?? data['access_token'] ?? ''}'.trim();
    if (token.isEmpty) {
      throw FriendlyException('Registration failed. Please try again.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.authTokenKey, token);
    await prefs.setString(AppConfig.userNameKey, name);
    return token;
  }
}
