import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/owner_home_page.dart';
import '../pages/vet_home_page.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class LoginService {
  // Login fonksiyonu
  static Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      _showMessage(context, 'Lütfen email ve şifreyi doldurun!');
      return;
    }

    final res = await AuthService.login(email, password);

    if (res == null) {
      _showMessage(context, 'Sunucuya bağlanılamadı!');
      return;
    }

    if (res['success'] != true) {
      _showMessage(context, res['message'] ?? 'Giriş başarısız!');
      return;
    }

    final String role = res['role'] ?? '';
    final int userId = res['user']?['id'] ?? 0;
    final int vetId = res['user']?['id'] ?? 0;

    if (rememberMe) {
      await _saveCredentials(email, password, role, userId);
    }

    // Rol bazlı yönlendirme
    switch (role) {
      case 'vet':
        _navigateTo(context, VetHomePage(vetId: vetId));
        break;
      case 'owner':
        _navigateTo(context, OwnerHome(ownerId: userId));
        break;
      default:
        _showMessage(context, 'Bilinmeyen rol: $role');
    }
  }

  // SharedPreferences'a kaydet
  static Future<void> _saveCredentials(
      String email, String password, String role, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setString('role', role);
    await prefs.setInt('userId', userId);
    await prefs.setBool('rememberMe', true);
  }

  // SharedPreferences'tan otomatik login için oku
  static Future<Map<String, dynamic>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('rememberMe') ?? false;
    if (!rememberMe) return null;

    return {
      'email': prefs.getString('email') ?? '',
      'password': prefs.getString('password') ?? '',
      'role': prefs.getString('role') ?? '',
      'userId': prefs.getInt('userId') ?? 0,
    };
  }

  static void _showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  static void _navigateTo(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}
