// alat_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../models/alat_model.dart';

class AlatService {
  static const String baseUrl = 'https://hamatech.rplrus.com/api';

  // Modified fetchAlat to accept optional companyId parameter
  static Future<List<AlatModel>> fetchAlat({int? companyId}) async {
    String url = '$baseUrl/alat';

    // Add company_id parameter if provided
    if (companyId != null) {
      url += '?company_id=$companyId';
    }

    print('Fetching tools from URL: $url'); // Debug log

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'ngrok-skip-browser-warning': '1',
      },
    );

    print('Response status: ${response.statusCode}'); // Debug log
    print('Response body: ${response.body}'); // Debug log

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List dataList = jsonData['data'];

      return dataList.map((json) => AlatModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch tools (${response.statusCode}): ${response.body}');
    }
  }

  // Fetch alat by company
  static Future<List<AlatModel>> fetchAlatByCompany(int companyId) async {
    if (companyId <= 0) {
      throw Exception('Invalid company ID: $companyId');
    }
    return await fetchAlat(companyId: companyId);
  }

  static Future<http.Response?> deleteAlat(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/alat/$id'),
        headers: {
          'ngrok-skip-browser-warning': '1',
        },
      );

      print('Delete Status: ${response.statusCode}'); // Debug log
      print('Delete Body: ${response.body}'); // Debug log

      return response;
    } catch (e) {
      print('Error saat menghapus alat: $e');
      return null;
    }
  }

  static Future<http.Response?> getAlatById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alat/$id'),
        headers: {
          'ngrok-skip-browser-warning': '1',
        },
      );

      print('Status getAlatById: ${response.statusCode}'); // Debug log
      print('Body: ${response.body}'); // Debug log

      return response;
    } catch (e) {
      print('Error getAlatById: $e');
      return null;
    }
  }
}