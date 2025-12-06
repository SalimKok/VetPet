import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ClinicService {

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

  static Future<bool> createClinic({
    required String name,
    required int vetId,
    int? cityId,
    int? districtId,
    // Neighbourhood yok
    String? addressDetails,
    String? phone,
    String? workingHours,
  }) async {
    final url = Uri.parse("${ApiService.baseUrl}/clinics");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "vet_id": vetId,
        "city_id": cityId,
        "district_id": districtId,
        "address_details": addressDetails,
        "phone": phone,
        "working_hours": workingHours,
      }),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateClinic({
    required int clinicId,
    String? name,
    int? cityId,
    int? districtId,
    String? addressDetails,
    String? phone,
    String? workingHours,
  }) async {
    final url = Uri.parse("${ApiService.baseUrl}/clinics/$clinicId");
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "city_id": cityId,
        "district_id": districtId,
        "address_details": addressDetails,
        "phone": phone,
        "working_hours": workingHours,
      }),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteClinic(int clinicId) async {
    final url = Uri.parse("${ApiService.baseUrl}/clinics/$clinicId");
    final response = await http.delete(url);
    return response.statusCode == 200;
  }
}