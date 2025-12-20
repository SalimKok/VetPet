import 'package:flutter/material.dart';
import 'package:petvet/pages/admin/admin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/owner/owner_home_page.dart';
import '../pages/vet/vet_home_page.dart';
import '../services/auth_service.dart';

class LoginService {
  // 1. Dönüş tipini Future<bool> yaptık (Hata çözümü için)
  static Future<bool> login({
    required BuildContext context,
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    // Boş alan kontrolü
    if (email.isEmpty || password.isEmpty) {
      _showMessage(context, 'Lütfen email ve şifreyi doldurun!');
      return false;
    }

    // Email format kontrolü
    bool isValidEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    if (!isValidEmail) {
      _showMessage(context, 'Lütfen geçerli bir e-posta adresi giriniz!');
      return false;
    }

    // AuthService üzerinden API'ye istek atıyoruz
    final res = await AuthService.login(email, password);

    if (res == null) {
      _showMessage(context, 'Sunucuya bağlanılamadı!');
      return false;
    }

    // Backend'den gelen success kontrolü
    if (res['success'] != true) {
      _showMessage(context, res['message'] ?? 'Giriş başarısız!');
      return false;
    }

    // Verileri çekiyoruz
    final String role = res['role'] ?? '';
    final int userId = res['user']?['id'] ?? 0;

    // "Beni Hatırla" seçiliyse bilgileri kaydet, değilse temizle
    if (rememberMe) {
      await _saveCredentials(email, password, role, userId);
    } else {
      await _clearSavedCredentials();
    }

    // Rol bazlı yönlendirme
    // Not: Yönlendirme başarılı olsa bile fonksiyondan true döneceğiz.
    switch (role) {
      case 'vet':
        _navigateTo(context, VetHomePage(vetId: userId));
        break;
      case 'owner':
        _navigateTo(context, OwnerHomePage(ownerId: userId));
        break;
      case 'admin':
        _navigateTo(context, const AdminPage());
        break;
      default:
        _showMessage(context, 'Bilinmeyen rol: $role');
        return false;
    }

    return true; // Giriş ve yönlendirme başarılı!
  }

  // SharedPreferences'a güvenli kaydetme
  static Future<void> _saveCredentials(
      String email, String password, String role, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);
    await prefs.setString('saved_password', password);
    await prefs.setString('role', role);
    await prefs.setInt('userId', userId);
    await prefs.setBool('rememberMe', true);
  }

  // Beni hatırla kapalıysa temizleme
  static Future<void> _clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
    await prefs.setBool('rememberMe', false);
  }

  static void _showMessage(BuildContext context, String text) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static void _navigateTo(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}