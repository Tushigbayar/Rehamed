// Мэдэгдлийн service
// Backend API-тай холбогдож, мэдэгдлүүдийг удирдана

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/announcement.dart';
import 'auth_service.dart';
import 'api_config.dart';

class AnnouncementService {
  // Бүх мэдэгдлүүдийг авах
  static Future<List<Announcement>> getAnnouncements() async {
    try {
      final token = AuthService.token;
      if (token == null) return [];

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.announcementsEndpoint}');
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _fromJson(json)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      return [];
    } catch (e) {
      print('Error fetching announcements: $e');
      return [];
    }
  }

  // Сүүлийн мэдэгдлүүдийг авах
  static Future<List<Announcement>> getRecentAnnouncements({int limit = 5}) async {
    try {
      final token = AuthService.token;
      if (token == null) return [];

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.announcementsEndpoint}/recent?limit=$limit');
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
      print('Error fetching recent announcements: $e');
      return [];
    }
  }

  // ID-аар мэдэгдэл авах
  static Future<Announcement?> getAnnouncementById(String id) async {
    try {
      final token = AuthService.token;
      if (token == null) return null;

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.announcementsEndpoint}/$id');
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
      print('Error fetching announcement: $e');
      return null;
    }
  }

  // Шинэ мэдэгдэл үүсгэх (зөвхөн админ)
  static Future<Map<String, dynamic>> createAnnouncement({
    required String title,
    required String content,
    bool isImportant = false,
    String? author,
  }) async {
    try {
      final token = AuthService.token;
      if (token == null) {
        return {'success': false, 'error': 'Нэвтрэх шаардлагатай'};
      }

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.announcementsEndpoint}');
      final response = await http.post(
        url,
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({
          'title': title,
          'content': content,
          'isImportant': isImportant,
          'author': author,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'announcement': _fromJson(data),
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Мэдэгдэл үүсгэхэд алдаа гарлаа',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Холболтын алдаа: ${e.toString()}',
      };
    }
  }

  // Мэдэгдэл шинэчлэх (зөвхөн админ)
  static Future<Map<String, dynamic>> updateAnnouncement(Announcement announcement) async {
    try {
      final token = AuthService.token;
      if (token == null) {
        return {'success': false, 'error': 'Нэвтрэх шаардлагатай'};
      }

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.announcementsEndpoint}/${announcement.id}');
      final response = await http.put(
        url,
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({
          'title': announcement.title,
          'content': announcement.content,
          'isImportant': announcement.isImportant,
          'author': announcement.author,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'announcement': _fromJson(data),
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Мэдэгдэл шинэчлэхэд алдаа гарлаа',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Холболтын алдаа: ${e.toString()}',
      };
    }
  }

  // Мэдэгдэл устгах (зөвхөн админ)
  static Future<Map<String, dynamic>> deleteAnnouncement(String id) async {
    try {
      final token = AuthService.token;
      if (token == null) {
        return {'success': false, 'error': 'Нэвтрэх шаардлагатай'};
      }

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.announcementsEndpoint}/$id');
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
          'error': error['error'] ?? 'Мэдэгдэл устгахад алдаа гарлаа',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Холболтын алдаа: ${e.toString()}',
      };
    }
  }

  // JSON-аас Announcement объект үүсгэх
  static Announcement _fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isImportant: json['isImportant'] ?? false,
      author: json['author'],
    );
  }

  // Legacy methods (backward compatibility)
  static void addAnnouncement(Announcement announcement) {
    // Deprecated - use createAnnouncement instead
  }
}
