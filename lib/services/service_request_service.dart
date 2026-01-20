// Үйлчилгээний хүсэлтийн service
// Backend API-тай холбогдож, үйлчилгээний хүсэлтүүдийг удирдана

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_request.dart';
import 'auth_service.dart';
import 'api_config.dart';

class ServiceRequestService {
  // Бүх үйлчилгээний хүсэлтүүдийг авах
  static Future<List<ServiceRequest>> getRequests() async {
    try {
      final token = AuthService.token;
      if (token == null) return [];

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.serviceRequestsEndpoint}');
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
      print('Error fetching requests: $e');
      return [];
    }
  }

  // ID-аар үйлчилгээний хүсэлт авах
  static Future<ServiceRequest?> getRequestById(String id) async {
    try {
      final token = AuthService.token;
      if (token == null) return null;

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.serviceRequestsEndpoint}/$id');
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
      print('Error fetching request: $e');
      return null;
    }
  }

  // Шинэ үйлчилгээний хүсэлт үүсгэх
  static Future<Map<String, dynamic>> createRequest({
    required ServiceRequestType type,
    required String title,
    required String description,
    required String location,
    bool isUrgent = false,
    DateTime? scheduledDate,
    DateTime? scheduledTime,
    List<String>? images,
  }) async {
    try {
      final token = AuthService.token;
      if (token == null) {
        return {'success': false, 'error': 'Нэвтрэх шаардлагатай'};
      }

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.serviceRequestsEndpoint}');
      final response = await http.post(
        url,
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({
          'type': _typeToString(type),
          'title': title,
          'description': description,
          'location': location,
          'isUrgent': isUrgent,
          'scheduledDate': scheduledDate?.toIso8601String(),
          'scheduledTime': scheduledTime?.toIso8601String(),
          'images': images ?? [],
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'request': _fromJson(data),
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Үйлчилгээний хүсэлт үүсгэхэд алдаа гарлаа',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Холболтын алдаа: ${e.toString()}',
      };
    }
  }

  // Үйлчилгээний хүсэлт шинэчлэх
  static Future<Map<String, dynamic>> updateRequest(ServiceRequest request) async {
    try {
      final token = AuthService.token;
      if (token == null) {
        return {'success': false, 'error': 'Нэвтрэх шаардлагатай'};
      }

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.serviceRequestsEndpoint}/${request.id}');
      final response = await http.put(
        url,
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({
          'type': _typeToString(request.type),
          'title': request.title,
          'description': request.description,
          'location': request.location,
          'status': _statusToString(request.status),
          'assignedTo': request.assignedTo,
          'notes': request.notes,
          'images': request.images ?? [],
          'isUrgent': request.isUrgent,
          'scheduledDate': request.scheduledDate?.toIso8601String(),
          'scheduledTime': request.scheduledTime?.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'request': _fromJson(data),
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Үйлчилгээний хүсэлт шинэчлэхэд алдаа гарлаа',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Холболтын алдаа: ${e.toString()}',
      };
    }
  }

  // Үйлчилгээний хүсэлт устгах
  static Future<Map<String, dynamic>> deleteRequest(String id) async {
    try {
      final token = AuthService.token;
      if (token == null) {
        return {'success': false, 'error': 'Нэвтрэх шаардлагатай'};
      }

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.serviceRequestsEndpoint}/$id');
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
          'error': error['error'] ?? 'Үйлчилгээний хүсэлт устгахад алдаа гарлаа',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Холболтын алдаа: ${e.toString()}',
      };
    }
  }

  // Статусаар хүсэлтүүдийг авах
  static Future<List<ServiceRequest>> getRequestsByStatus(ServiceRequestStatus status) async {
    try {
      final token = AuthService.token;
      if (token == null) return [];

      final statusString = _statusToString(status);
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.serviceRequestsEndpoint}/status/$statusString');
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
      print('Error fetching requests by status: $e');
      return [];
    }
  }

  // Тайлан татаж авах (CSV формат)
  static Future<Map<String, dynamic>> exportReport({
    int? year,
    int? month,
  }) async {
    try {
      // Token шалгах - эхлээд initialize хийх
      await AuthService.initialize();
      final token = AuthService.token;
      
      if (token == null || !AuthService.isLoggedIn) {
        return {
          'success': false,
          'error': 'Нэвтрэх шаардлагатай',
          'requiresLogin': true,
        };
      }

      // Query параметрүүд
      final queryParams = <String, String>{};
      if (year != null) queryParams['year'] = year.toString();
      if (month != null) queryParams['month'] = month.toString();

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.serviceRequestsEndpoint}/report/export')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

      // Headers
      final headers = ApiConfig.getHeaders(token: token);

      final response = await http.get(
        uri,
        headers: headers,
      );

      // 401 алдаа гарвал token дууссан
      if (response.statusCode == 401) {
        // Token устгах
        await AuthService.logout();
        return {
          'success': false,
          'error': 'Нэвтрэх хугацаа дууссан. Дахин нэвтрэнэ үү.',
          'requiresLogin': true,
        };
      }

      if (response.statusCode == 200) {
        return {
          'success': true,
          'csvData': response.bodyBytes, // CSV өгөгдөл (bytes)
          'contentType': response.headers['content-type'] ?? 'text/csv',
        };
      } else {
        try {
          final errorBody = response.body;
          if (errorBody.isNotEmpty) {
            final error = jsonDecode(errorBody);
            return {
              'success': false,
              'error': error['error'] ?? 'Тайлан татахад алдаа гарлаа',
            };
          } else {
            return {
              'success': false,
              'error': 'Тайлан татахад алдаа гарлаа (${response.statusCode})',
            };
          }
        } catch (e) {
          return {
            'success': false,
            'error': 'Тайлан татахад алдаа гарлаа (${response.statusCode})',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Холболтын алдаа: ${e.toString()}',
      };
    }
  }

  // JSON-аас ServiceRequest объект үүсгэх
  static ServiceRequest _fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId']?['_id'] ?? json['userId']?['id'] ?? json['userId'] ?? '',
      type: _stringToType(json['type'] ?? 'other'),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      status: _stringToStatus(json['status'] ?? 'pending'),
      requestedAt: json['requestedAt'] != null
          ? DateTime.parse(json['requestedAt'])
          : DateTime.now(),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      assignedTo: json['assignedTo']?['_id'] ?? json['assignedTo']?['id'] ?? json['assignedTo'],
      notes: json['notes'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      isUrgent: json['isUrgent'] ?? false,
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : null,
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'])
          : null,
    );
  }

  // Type enum-ийг string болгох
  static String _typeToString(ServiceRequestType type) {
    switch (type) {
      case ServiceRequestType.emergency:
        return 'emergency';
      case ServiceRequestType.maintenance:
        return 'maintenance';
      case ServiceRequestType.cleaning:
        return 'cleaning';
      case ServiceRequestType.equipment:
        return 'equipment';
      case ServiceRequestType.other:
        return 'other';
    }
  }

  // String-ийг Type enum болгох
  static ServiceRequestType _stringToType(String type) {
    switch (type) {
      case 'emergency':
        return ServiceRequestType.emergency;
      case 'maintenance':
        return ServiceRequestType.maintenance;
      case 'cleaning':
        return ServiceRequestType.cleaning;
      case 'equipment':
        return ServiceRequestType.equipment;
      default:
        return ServiceRequestType.other;
    }
  }

  // Status enum-ийг string болгох
  static String _statusToString(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return 'pending';
      case ServiceRequestStatus.accepted:
        return 'accepted';
      case ServiceRequestStatus.inProgress:
        return 'inProgress';
      case ServiceRequestStatus.completed:
        return 'completed';
      case ServiceRequestStatus.cancelled:
        return 'cancelled';
    }
  }

  // String-ийг Status enum болгох
  static ServiceRequestStatus _stringToStatus(String status) {
    switch (status) {
      case 'accepted':
        return ServiceRequestStatus.accepted;
      case 'inProgress':
        return ServiceRequestStatus.inProgress;
      case 'completed':
        return ServiceRequestStatus.completed;
      case 'cancelled':
        return ServiceRequestStatus.cancelled;
      default:
        return ServiceRequestStatus.pending;
    }
  }

  // Legacy methods (backward compatibility)
  static List<ServiceRequest> getAllRequests() {
    return [];
  }

  static void addRequest(ServiceRequest request) {
    // Deprecated - use createRequest instead
  }

  static void updateRequestSync(ServiceRequest updatedRequest) {
    // Deprecated - use updateRequest instead
  }

  static void deleteRequestSync(String id) {
    // Deprecated - use deleteRequest instead
  }
}
