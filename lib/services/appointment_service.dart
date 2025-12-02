import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AppointmentService {
  /// SAHİBİN randevularını getirir
  static Future<List<Map<String, dynamic>>> getOwnerAppointments(int ownerId) async {
    final url = Uri.parse("${ApiService.baseUrl}/appointments/owner/$ownerId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['appointments']);
    } else {
      print("Sahip randevuları alınamadı: ${response.body}");
      return [];
    }
  }

  /// VETERİNERİN randevularını getirir
  static Future<List<Map<String, dynamic>>> getVetAppointments(int vetId) async {
    final url = Uri.parse("${ApiService.baseUrl}/appointments/vet/$vetId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['appointments']);
    } else {
      print("Veteriner randevuları alınamadı: ${response.body}");
      return [];
    }
  }

  /// Yeni randevu oluşturur
  static Future<bool> createAppointment({
    required int petId,
    required int ownerId,
    required int vetId,
    required DateTime date,
    String reason = '',
  }) async {
    final url = Uri.parse("${ApiService.baseUrl}/appointments");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "pet_id": petId,
        "owner_id": ownerId,
        "vet_id": vetId,
        "date": date.toIso8601String(),
        "reason": reason,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print("Randevu oluşturma hatası: ${response.body}");
      return false;
    }
  }

  /// Randevu DURUMUNU günceller (örnek: 'approved', 'cancelled', 'completed')
  static Future<bool> updateAppointmentStatus(int appointmentId, String status) async {
    final url = Uri.parse("${ApiService.baseUrl}/appointments/$appointmentId/status");
    final response = await http.patch(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"status": status}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Durum güncelleme hatası: ${response.body}");
      return false;
    }
  }


  /// Randevu BİLGİLERİNİ günceller (tarih, sebep gibi)
  static Future<bool> updateAppointment({
    required int appointmentId,
    DateTime? date,
    String? reason,
  }) async {
    final url = Uri.parse("${ApiService.baseUrl}/appointments/$appointmentId");
    final body = {};

    if (date != null) body['date'] = date.toIso8601String();
    if (reason != null) body['reason'] = reason;

    if (body.isEmpty) {
      print("Güncellenecek bilgi bulunamadı.");
      return false;
    }

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Randevu güncelleme hatası: ${response.body}");
      return false;
    }
  }

  /// Randevuyu SİLER
  static Future<bool> deleteAppointment(int appointmentId) async {
    final url = Uri.parse("${ApiService.baseUrl}/appointments/$appointmentId");
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Randevu silme hatası: ${response.body}");
      return false;
    }
  }

  // VETERİNER TARAFINDAN RANDEVU/AŞI OLUŞTURMA (YENİ)
  Future<bool> createAppointmentByVet({
    required int vetId,
    required int petId,
    required DateTime date,
    required String reason,
  }) async {
    // URL'in sonuna backend'de tanımladığımız yolu ekliyoruz
    // NOT: Eğer blueprint prefix'in '/api' ise başa onu eklemeyi unutma.
    // Örn: '$baseUrl/api/appointments/create-by-vet' olabilir.
    final url = Uri.parse('${ApiService.baseUrl}/appointments/create-by-vet');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "vet_id": vetId,
          "pet_id": petId,
          "date": date.toIso8601String(), // Tarihi ISO formatına (String) çevirir
          "reason": reason,
        }),
      );

      if (response.statusCode == 201) {
        return true; // Başarılı
      } else {
        // Hata durumunda konsola yazdırıp false dönüyoruz
        print("Randevu oluşturma hatası: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Bağlantı hatası: $e");
      return false;
    }
  }
}
