import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'api_service.dart';

class UserService {
  static Future<Map<String, dynamic>?> getUserProfile(int userId) async {
    final url = Uri.parse("${ApiService.baseUrl}/users/$userId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['user'];
      } else {
        print("API Hatası: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Hata: $e");
      return null;
    }
  }

  static Future<bool> updateUserProfile(int userId, Map<String, dynamic> data) async {
    try {
      var uri = Uri.parse("${ApiService.baseUrl}/users/$userId");
      var request = http.MultipartRequest('POST', uri);

      // Text alanlarını ekle
      request.fields['name'] = data['name'] ?? '';
      request.fields['email'] = data['email'] ?? '';
      request.fields['phone'] = data['phone'] ?? '';

      // Fotoğraf varsa ekle
      if (data['photo'] != null && data['photo'] is File) {
        File file = data['photo'];
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo',
            file.path,
            filename: basename(file.path),
          ),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Profil güncelleme hatası: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception updateUserProfile: $e");
      return false;
    }
  }
}
