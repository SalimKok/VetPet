import 'api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminService {

  final Map<String, String> _headers = {
    "Content-Type": "application/json",
  };

  /// 1. İstatistikleri Getir (Dashboard için)
  Future<Map<String, dynamic>> fetchStats() async {
    final url = Uri.parse("${ApiService.baseUrl}/admin/stats");

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("İstatistikler yüklenemedi: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Bağlantı hatası: $e");
    }
  }

  /// 2. Tüm Kullanıcıları Getir
  Future<List<dynamic>> fetchAllUsers() async {
    final url = Uri.parse("${ApiService.baseUrl}/admin/users");

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Kullanıcı listesi alınamadı: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Bağlantı hatası: $e");
    }
  }

  /// 3. Kullanıcı Sil
  Future<bool> deleteUser(int userId) async {
    final url = Uri.parse("${ApiService.baseUrl}/admin/users/$userId");

    try {
      final response = await http.delete(url, headers: _headers);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Silme işlemi başarısız: ${response.body}");
      }
    } catch (e) {
      throw Exception("Hata oluştu: $e");
    }
  }

  /// 4. Bekleyen Veterinerleri Getir
  Future<List<dynamic>> fetchPendingVets() async {
    final url = Uri.parse("${ApiService.baseUrl}/approve/vets");

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Veteriner listesi alınamadı: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Bağlantı hatası: $e");
    }
  }

  /// 5. Veterineri Onayla
  Future<bool> approveVet(int vetId) async {
    final url = Uri.parse("${ApiService.baseUrl}/approve/vets/$vetId");

    try {
      final response = await http.post(url, headers: _headers);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Onaylama başarısız: ${response.body}");
      }
    } catch (e) {
      throw Exception("Hata: $e");
    }
  }

  Future<List<dynamic>> getAllAppointments() async {
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/admin/appointments'), headers: _headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Randevular yüklenemedi");
      }
    } catch (e) {
      print("Hata: $e");
      return [];
    }
  }

  Future<bool> updateAnyAppointmentStatus(int appointmentId, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/admin/appointments/$appointmentId'),
        body: jsonEncode({'status': newStatus}),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAnyAppointment(int id) async {
    try {
      final response = await http.delete(Uri.parse('${ApiService.baseUrl}/admin/appointments/$id'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}