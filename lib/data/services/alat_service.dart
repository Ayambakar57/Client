// alat_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alat_model.dart';

class AlatService {
  static const String baseUrl = 'https://hamatech.rplrus.com/api';

  // Method untuk mendapatkan token dari SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Method untuk membuat header dengan token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    final headers = <String, String>{
      'ngrok-skip-browser-warning': '1',
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Modified fetchAlat to accept optional companyId parameter and use token
  static Future<List<AlatModel>> fetchAlat({int? companyId}) async {
    String url = '$baseUrl/alat';

    // Add company_id parameter if provided
    if (companyId != null) {
      url += '?company_id=$companyId';
    }

    print('Fetching tools from URL: $url'); // Debug log

    final headers = await _getHeaders();
    print('Request headers: $headers'); // Debug log

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    print('Response status: ${response.statusCode}'); // Debug log
    print('Response body: ${response.body}'); // Debug log

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List dataList = jsonData['data'];

      return dataList.map((json) => AlatModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Token tidak valid atau expired');
    } else {
      throw Exception('Failed to fetch tools (${response.statusCode}): ${response.body}');
    }
  }

  // Fetch alat by company with token
  static Future<List<AlatModel>> fetchAlatByCompany(int companyId) async {
    if (companyId <= 0) {
      throw Exception('Invalid company ID: $companyId');
    }
    return await fetchAlat(companyId: companyId);
  }

  // Delete alat with token authentication
  static Future<http.Response?> deleteAlat(int id) async {
    try {
      final headers = await _getHeaders();
      print('Delete request headers: $headers'); // Debug log

      final response = await http.delete(
        Uri.parse('$baseUrl/alat/$id'),
        headers: headers,
      );

      print('Delete Status: ${response.statusCode}'); // Debug log
      print('Delete Body: ${response.body}'); // Debug log

      if (response.statusCode == 401) {
        print('❌ Token tidak valid atau expired saat menghapus alat');
        throw Exception('Unauthorized: Token tidak valid atau expired');
      }

      return response;
    } catch (e) {
      print('Error saat menghapus alat: $e');
      return null;
    }
  }

  // Get alat by ID with token authentication
  static Future<http.Response?> getAlatById(int id) async {
    try {
      final headers = await _getHeaders();
      print('Get alat by ID headers: $headers'); // Debug log

      final response = await http.get(
        Uri.parse('$baseUrl/alat/$id'),
        headers: headers,
      );

      print('Status getAlatById: ${response.statusCode}'); // Debug log
      print('Body: ${response.body}'); // Debug log

      if (response.statusCode == 401) {
        print('❌ Token tidak valid atau expired saat mengambil alat');
        throw Exception('Unauthorized: Token tidak valid atau expired');
      }

      return response;
    } catch (e) {
      print('Error getAlatById: $e');
      return null;
    }
  }

  // Create new alat with token authentication
  static Future<http.Response?> createAlat(Map<String, dynamic> alatData) async {
    try {
      final headers = await _getHeaders();
      print('Create alat headers: $headers'); // Debug log

      final response = await http.post(
        Uri.parse('$baseUrl/alat'),
        headers: headers,
        body: json.encode(alatData),
      );

      print('Create Status: ${response.statusCode}'); // Debug log
      print('Create Body: ${response.body}'); // Debug log

      if (response.statusCode == 401) {
        print('❌ Token tidak valid atau expired saat membuat alat');
        throw Exception('Unauthorized: Token tidak valid atau expired');
      }

      return response;
    } catch (e) {
      print('Error saat membuat alat: $e');
      return null;
    }
  }

  // Update alat with token authentication
  static Future<http.Response?> updateAlat(int id, Map<String, dynamic> alatData) async {
    try {
      final headers = await _getHeaders();
      print('Update alat headers: $headers'); // Debug log

      final response = await http.put(
        Uri.parse('$baseUrl/alat/$id'),
        headers: headers,
        body: json.encode(alatData),
      );

      print('Update Status: ${response.statusCode}'); // Debug log
      print('Update Body: ${response.body}'); // Debug log

      if (response.statusCode == 401) {
        print('❌ Token tidak valid atau expired saat mengupdate alat');
        throw Exception('Unauthorized: Token tidak valid atau expired');
      }

      return response;
    } catch (e) {
      print('Error saat mengupdate alat: $e');
      return null;
    }
  }

  // Upload alat with image and token authentication
  static Future<http.Response?> uploadAlatWithImage({
    required Map<String, String> fields,
    File? imageFile,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/alat'));

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['ngrok-skip-browser-warning'] = '1';

      // Add fields
      request.fields.addAll(fields);

      // Add image file if provided
      if (imageFile != null) {
        String? mimeType = lookupMimeType(imageFile.path);
        MediaType? mediaType;

        if (mimeType != null) {
          var parts = mimeType.split('/');
          mediaType = MediaType(parts[0], parts[1]);
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            contentType: mediaType,
          ),
        );
      }

      print('Upload request headers: ${request.headers}'); // Debug log
      print('Upload request fields: ${request.fields}'); // Debug log

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Upload Status: ${response.statusCode}'); // Debug log
      print('Upload Body: ${response.body}'); // Debug log

      if (response.statusCode == 401) {
        print('❌ Token tidak valid atau expired saat upload alat');
        throw Exception('Unauthorized: Token tidak valid atau expired');
      }

      return response;
    } catch (e) {
      print('Error saat upload alat: $e');
      return null;
    }
  }

  // Update alat with image and token authentication
  static Future<http.Response?> updateAlatWithImage({
    required int id,
    required Map<String, String> fields,
    File? imageFile,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/alat/$id'));

      // Add method override for PUT
      request.fields['_method'] = 'PUT';

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['ngrok-skip-browser-warning'] = '1';

      // Add fields
      request.fields.addAll(fields);

      // Add image file if provided
      if (imageFile != null) {
        String? mimeType = lookupMimeType(imageFile.path);
        MediaType? mediaType;

        if (mimeType != null) {
          var parts = mimeType.split('/');
          mediaType = MediaType(parts[0], parts[1]);
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            contentType: mediaType,
          ),
        );
      }

      print('Update with image headers: ${request.headers}'); // Debug log
      print('Update with image fields: ${request.fields}'); // Debug log

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Update with image Status: ${response.statusCode}'); // Debug log
      print('Update with image Body: ${response.body}'); // Debug log

      if (response.statusCode == 401) {
        print('❌ Token tidak valid atau expired saat update alat dengan gambar');
        throw Exception('Unauthorized: Token tidak valid atau expired');
      }

      return response;
    } catch (e) {
      print('Error saat update alat dengan gambar: $e');
      return null;
    }
  }

  // Method untuk mengecek apakah token masih valid
  static Future<bool> isTokenValid() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'), // Endpoint untuk check token
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error checking token validity: $e');
      return false;
    }
  }
}