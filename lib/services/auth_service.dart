import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

class AuthService {
  static Future<bool> isLoggedIn() async =>
      (await SharedPreferences.getInstance()).getString('auth_token')?.isNotEmpty == true;

  static Future<String?> login(String email,String password) async {
    final data=await ApiService.login(email,password);
    final token='${data['token'] ?? data['access_token'] ?? ''}';
    if(token.isEmpty) return null;
    final p=await SharedPreferences.getInstance();
    await p.setString('auth_token',token);
    await p.setString('user_name','${data['user']?['name'] ?? data['name'] ?? email}');
    return token;
  }

  static Future<void> logout() async {
    final p=await SharedPreferences.getInstance();
    await p.remove('auth_token'); await p.remove('user_name');
  }
}
