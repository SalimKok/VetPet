import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart'; // Base URL'i buradan alıyoruz (örn: http://10.0.2.2:5000)

class VetPatientsService {
  // ApiService.baseUrl yoksa buraya direk "http://10.0.2.2:5000" yazabilirsin.
  final String _baseUrl = "${ApiService.baseUrl}/api/vet";

  // 1. Veterinerin Kendi Hastalarını Getir
  Future<List<dynamic>> getMyPatients(int vetId) async {
    final response = await http.get(Uri.parse('$_baseUrl/my-patients/$vetId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Hasta listesi yüklenemedi: ${response.statusCode}');
    }
  }

  // 2. Sistemdeki TÜM Hayvanları Getir (Keşfet)
  Future<List<dynamic>> getAllPets() async {
    final response = await http.get(Uri.parse('$_baseUrl/all-pets'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Tüm hayvanlar listesi yüklenemedi');
    }
  }

  // 3. Listeme Hasta Ekle
  // Dönüş değeri olarak backend'den gelen mesajı String olarak döndürelim
  Future<Map<String, dynamic>> addPatient(int vetId, int petId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/add-patient'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "vet_id": vetId,
        "pet_id": petId
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // {message: "..."} döner
    } else {
      return {"error": "Bir hata oluştu"};
    }
  }
}