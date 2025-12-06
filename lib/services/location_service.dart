import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class LocationService {

  // Şehirleri Getir
  static Future<List<Map<String, dynamic>>> getCities() async {
    try {
      final url = Uri.parse("${ApiService.baseUrl}/cities");
      print("İstek atılıyor: $url"); // <--- BU SATIRI EKLE

      final response = await http.get(url);
      print("Cevap Kodu: ${response.statusCode}"); // <--- BU SATIRI EKLE
      print("Cevap Body: ${response.body}"); // <--- BU SATIRI EKLE

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 'cities' key'inin dolu olduğundan emin olalım
        List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(data['cities']);
        print("Gelen Şehir Sayısı: ${list.length}"); // <--- BU SATIRI EKLE
        return list;
      }
    } catch (e) {
      print("Şehirler çekilirken HATA: $e"); // <--- BU SATIRI EKLE
    }
    return [];
  }

  // İlçeleri Getir (Seçilen şehre göre)
  static Future<List<Map<String, dynamic>>> getDistricts(int cityId) async {
    try {
      final url = Uri.parse("${ApiService.baseUrl}/districts/$cityId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['districts']);
      }
    } catch (e) {
      print("İlçeler çekilirken hata: $e");
    }
    return [];
  }
}