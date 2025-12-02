import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medical_visit.dart';

class VisitService {
  // Android emülatör için 10.0.2.2, iOS veya gerçek cihaz için bilgisayarının IP'si
  final String baseUrl = "http://10.0.2.2:5000/api/visits";

  // 1. Hayvanın Geçmişini Getir
  Future<List<MedicalVisit>> getPetHistory(int petId) async {
    final response = await http.get(Uri.parse('$baseUrl/pet/$petId'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => MedicalVisit.fromJson(item)).toList();
    } else {
      throw Exception('Geçmiş yüklenemedi: ${response.statusCode}');
    }
  }

  // 2. Yeni Muayene Ekle
  Future<bool> createVisit(MedicalVisit visit) async {
    final response = await http.post(
      Uri.parse('$baseUrl/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(visit.toJson()),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print("Hata: ${response.body}");
      return false;
    }
  }
}