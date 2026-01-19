// Засварчдын service
// Backend API-тай холбогдож, засварчдын мэдээллийг удирдана

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/technician.dart';
import 'auth_service.dart';
import 'api_config.dart';

class TechnicianService {
  // Бүх засварчдыг авах
  static Future<List<Technician>> getTechnicians() async {
    try {
      final token = AuthService.token;
      if (token == null) return [];

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.techniciansEndpoint}');
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching technicians: $e');
      return [];
    }
  }

  // ID-аар засварчин авах
  static Future<Technician?> getTechnicianById(String id) async {
    try {
      final token = AuthService.token;
      if (token == null) return null;

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.techniciansEndpoint}/$id');
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching technician: $e');
      return null;
    }
  }

  // Шинэ засварчин үүсгэх (зөвхөн админ)
  static Future<Map<String, dynamic>> createTechnician({
    required String name,
    required String phone,
    required String specialization,
    String? email,
  }) async {
    try {
      final token = AuthService.token;
      if (token == null) {
        return {'success': false, 'error': 'Нэвтрэх шаардлагатай'};
      }

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.techniciansEndpoint}');
      final response = await http.post(
        url,
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'specialization': specialization,
          'email': email,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'technician': _fromJson(data),
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Засварчин үүсгэхэд алдаа гарлаа',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Холболтын алдаа: ${e.toString()}',
      };
    }
  }

  // Засварчны мэдээлэл шинэчлэх (зөвхөн админ)
  static Future<Map<String, dynamic>> updateTechnician(Technician technician) async {
    try {
      final token = AuthService.token;
      if (token == null) {
        return {'success': false, 'error': 'Нэвтрэх шаардлагатай'};
      }

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.techniciansEndpoint}/${technician.id}');
      final response = await http.put(
        url,
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({
          'name': technician.name,
          'phone': technician.phone,
          'specialization': technician.specialization,
          'email': technician.email,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'technician': _fromJson(data),
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Засварчны мэдээлэл шинэчлэхэд алдаа гарлаа',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Холболтын алдаа: ${e.toString()}',
      };
    }
  }

  // Засварчин устгах (зөвхөн админ)
  static Future<Map<String, dynamic>> deleteTechnician(String id) async {
    try {
      final token = AuthService.token;
      if (token == null) {
        return {'success': false, 'error': 'Нэвтрэх шаардлагатай'};
      }

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.techniciansEndpoint}/$id');
      final response = await http.delete(
        url,
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Засварчин устгахад алдаа гарлаа',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Холболтын алдаа: ${e.toString()}',
      };
    }
  }

  // JSON-аас Technician объект үүсгэх
  static Technician _fromJson(Map<String, dynamic> json) {
    return Technician(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      specialization: json['specialization'] ?? '',
      email: json['email'],
    );
  }

  // Legacy methods (backward compatibility)
  static void addTechnician(Technician technician) {
    // Deprecated - use createTechnician instead
  }
}
