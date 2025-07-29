import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/company_model.dart';

class CompanyService {
  static const String baseUrl = 'https://hamatech.rplrus.com/api';
  static const String imageBaseUrl = 'https://hamatech.rplrus.com/storage/';

  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'assets/images/example.png';
    }
    return '$imageBaseUrl$imagePath';
  }

  // Function to get token from SharedPreferences
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Function to get client ID from SharedPreferences
  Future<int?> getClientId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('client_id');
    } catch (e) {
      print('Error getting client ID: $e');
      return null;
    }
  }

  // Function to get company ID from SharedPreferences
  Future<int?> getCompanyId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('company_id');
    } catch (e) {
      print('Error getting company ID: $e');
      return null;
    }
  }

  // Function to get username from SharedPreferences
  Future<String?> getUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('username');
    } catch (e) {
      print('Error getting username: $e');
      return null;
    }
  }

  // Function to create headers with Bearer token
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': '1',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      print('🔑 Using Bearer token: ${token.substring(0, 20)}...');
    } else {
      print('⚠️ No token found for authorization');
    }

    return headers;
  }

  // Get all companies and filter by client_id
  Future<List<CompanyModel>> getCompanies() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/companies'),
        headers: headers,
      );

      print('📡 GET /companies - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> companiesData = responseData['data'];

        // Get client_id dari SharedPreferences
        final clientId = await getClientId();

        if (clientId == null) {
          throw Exception('Client ID not found. Please login again.');
        }

        print('🔍 Filtering companies for client_id: $clientId');

        // Filter companies berdasarkan client_id
        final filteredCompanies = companiesData
            .where((company) => company['client_id'] == clientId)
            .map((json) => CompanyModel.fromJson(json))
            .toList();

        print('✅ Found ${filteredCompanies.length} companies for client');
        return filteredCompanies;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Token may be invalid or expired');
      } else {
        throw Exception('Failed to load companies: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getCompanies: $e');
      throw Exception('Failed to load companies: $e');
    }
  }

  // Get specific company by client_id
  Future<CompanyModel?> getCompanyByClientId() async {
    try {
      final companies = await getCompanies();

      if (companies.isNotEmpty) {
        print('🏢 Found company: ${companies.first.name}');
        return companies.first; // Return the first company for this client
      }

      print('⚠️ No company found for this client');
      return null;
    } catch (e) {
      print('❌ Error getting company by client ID: $e');
      return null;
    }
  }

  // Get company by ID
  Future<CompanyModel?> getCompanyById(int companyId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/companies/$companyId'),
        headers: headers,
      );

      print('📡 GET /companies/$companyId - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final company = CompanyModel.fromJson(responseData['data']);
        print('✅ Company loaded: ${company.name}');
        return company;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Token may be invalid or expired');
      } else if (response.statusCode == 404) {
        print('⚠️ Company not found with ID: $companyId');
        return null;
      } else {
        throw Exception('Failed to load company: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting company by ID: $e');
      return null;
    }
  }

  // Method untuk validasi token
  Future<bool> validateToken() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      final headers = await _getHeaders();

      // Test endpoint untuk validasi token (bisa diganti sesuai API)
      final response = await http.get(
        Uri.parse('$baseUrl/companies'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Token validation failed: $e');
      return false;
    }
  }
}