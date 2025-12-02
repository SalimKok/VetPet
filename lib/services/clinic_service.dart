import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ClinicService {
  // Tüm klinikleri getir
  static Future<List<Map<String, dynamic>>> getClinics() async {
    final url = Uri.parse("${ApiService.baseUrl}/clinics");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['clinics']);
    }
    return [];
  }

  // Belirli bir klinik
  static Future<Map<String, dynamic>?> getClinic(int clinicId) async {
    final url = Uri.parse("${ApiService.baseUrl}/clinics/$clinicId");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Map<String, dynamic>.from(data['clinic']);
    }
    return null;
  }

  // Veterinerin kliniklerini getir
  static Future<List<Map<String, dynamic>>> getVetClinics(int vetId) async {
    final url = Uri.parse("${ApiService.baseUrl}/vets/$vetId/clinics");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['clinics']);
    }
    return [];
  }

  // Yeni klinik ekle
  static Future<bool> createClinic({
    required String name,
    String? address,
    String? phone,
    String? workingHours,
    required int vetId,
  }) async {
    final url = Uri.parse("${ApiService.baseUrl}/clinics");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "address": address,
        "phone": phone,
        "working_hours": workingHours,
        "vet_id": vetId,
      }),
    );

    return response.statusCode == 201;
  }

  // Klinik güncelle
  static Future<bool> updateClinic({
    required int clinicId,
    String? name,
    String? address,
    String? phone,
    String? workingHours,
  }) async {
    final url = Uri.parse("${ApiService.baseUrl}/clinics/$clinicId");
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "address": address,
        "phone": phone,
        "working_hours": workingHours,
      }),
    );

    return response.statusCode == 200;
  }

  // Klinik sil
  static Future<bool> deleteClinic(int clinicId) async {
    final url = Uri.parse("${ApiService.baseUrl}/clinics/$clinicId");
    final response = await http.delete(url);
    return response.statusCode == 200;
  }
}
