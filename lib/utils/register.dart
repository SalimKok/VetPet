import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterService {
  static Future<void> register({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    // 1. Boş alan kontrolü
    if (name.isEmpty || email.isEmpty || password.isEmpty || role.isEmpty) {
      _showMessage(context, 'Lütfen tüm alanları doldurun ve bir rol seçin!');
      return;
    }
    // 2. Email format kontrolü (Regex)
    bool isValidEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    if (!isValidEmail) {
      _showMessage(context, 'Lütfen geçerli bir e-posta adresi giriniz!');
      return;
    }
    // 3. Şifre uzunluk kontrolü
    if (password.length < 6) {
      _showMessage(context, 'Şifre en az 6 karakter olmalıdır!');
      return;
    }
    // Sunucu isteği
    final res = await AuthService.register(name, email, password, role);

    if (res == null) {
      _showMessage(context, 'Sunucuya bağlanılamadı!');
      return;
    }

    _showMessage(context, res['message'] ?? 'İşlem tamamlandı.');
  }

  static void _showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

}
