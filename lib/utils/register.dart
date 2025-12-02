import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class RegisterService {
  static Future<void> register({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage(context, 'Lütfen tüm alanları doldurun!');
      return;
    }

    final res = await AuthService.register(name, email, password, role);

    if (res == null) {
      _showMessage(context, 'Sunucuya bağlanılamadı!');
      return;
    }

    _showMessage(context, res['message'] ?? 'Kayıt başarısız!');
  }

  // ---------------- PRIVATE HELPERS ----------------
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
