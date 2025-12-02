import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_service.dart';

class PetService {
  static Future<List<Map<String, dynamic>>> getPets(int ownerId) async {
    final url = Uri.parse("${ApiService.baseUrl}/pets/$ownerId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['pets']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addPet(Map<String, dynamic> petData) async {
    final url = Uri.parse("${ApiService.baseUrl}/pets");
    try {
      var request = http.MultipartRequest('POST', url);
      request.fields.addAll({
        'owner_id': petData['owner_id'].toString(),
        'name': petData['name'],
        'species': petData['species'],
        'breed': petData['breed'],
        'notes': petData['notes'],
        if (petData['birth_date'] != null) 'birth_date': petData['birth_date'],
      });

      if (petData['photo_file'] != null && petData['photo_file'] is File) {
        var file = petData['photo_file'] as File;
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          file.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      final response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updatePet(int id, Map<String, dynamic> petData) async {
    final url = Uri.parse("${ApiService.baseUrl}/pets/$id");
    try {
      var request = http.MultipartRequest('PUT', url);
      request.fields.addAll({
        'name': petData['name'],
        'species': petData['species'],
        'breed': petData['breed'],
        'notes': petData['notes'],
        if (petData['birth_date'] != null) 'birth_date': petData['birth_date'],
      });

      if (petData['photo_file'] != null && petData['photo_file'] is File) {
        var file = petData['photo_file'] as File;
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          file.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deletePet(int id) async {
    final url = Uri.parse("${ApiService.baseUrl}/pets/$id");
    try {
      final response = await http.delete(url);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
