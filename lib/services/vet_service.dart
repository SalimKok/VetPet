import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class VetService {
  static Future<List<Map<String, dynamic>>> getVets() async {
    final url = Uri.parse("${ApiService.baseUrl}/vets");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['vets']);
    }
    return [];
  }
}
