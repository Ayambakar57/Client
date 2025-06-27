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

  // Get all companies and filter by client_id
  Future<List<CompanyModel>> getCompanies() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/companies'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': '1',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> companiesData = responseData['data'];

        // Get client_id dari SharedPreferences
        final clientId = await getClientId();

        if (clientId == null) {
          throw Exception('Client ID not found. Please login again.');
        }

        // Filter companies berdasarkan client_id
        final filteredCompanies = companiesData
            .where((company) => company['client_id'] == clientId)
            .map((json) => CompanyModel.fromJson(json))
            .toList();

        return filteredCompanies;
      } else {
        throw Exception('Failed to load companies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load companies: $e');
    }
  }

  // Get specific company by client_id
  Future<CompanyModel?> getCompanyByClientId() async {
    try {
      final companies = await getCompanies();

      if (companies.isNotEmpty) {
        return companies.first; // Return the first company for this client
      }

      return null;
    } catch (e) {
      print('Error getting company by client ID: $e');
      return null;
    }
  }

  // Get company by ID
  Future<CompanyModel?> getCompanyById(int companyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/companies/$companyId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': '1',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return CompanyModel.fromJson(responseData['data']);
      } else {
        throw Exception('Failed to load company: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting company by ID: $e');
      return null;
    }
  }
}