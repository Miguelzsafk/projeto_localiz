import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const String _keyUserEmail = 'user_email';

  static Future<void> guardarEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserEmail, email);
  }

  static Future<String?> obterEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  static Future<void> limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}