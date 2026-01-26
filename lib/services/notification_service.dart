// Notification service - Notification-уудыг удирдах
// HTTP API болон Socket.IO ашиглан notification-уудыг авах, удирдах

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';
import 'socket_service.dart';

class Notification {
  final String id;
  final String userId;
  final String? technicianId;
  final String serviceRequestId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Notification({
    required this.id,
    required this.userId,
    this.technicianId,
    required this.serviceRequestId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.updatedAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId']?.toString() ?? '',
      technicianId: json['technicianId']?.toString(),
      serviceRequestId: json['serviceRequestId']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'other',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}

class NotificationService {
  static const String endpoint = '/api/notifications';
  static Function(Notification)? _onNewNotificationCallback;

  // Бүх notification-уудыг авах
  static Future<List<Notification>> getNotifications() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = ApiConfig.getHeaders(token: AuthService.token);
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Notification.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  // Уншаагүй notification-уудыг авах
  static Future<List<Notification>> getUnreadNotifications() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint/unread');
      final headers = ApiConfig.getHeaders(token: AuthService.token);
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Notification.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch unread notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching unread notifications: $e');
      return [];
    }
  }

  // Уншаагүй notification-уудын тоог авах
  static Future<int> getUnreadCount() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint/unread/count');
      final headers = ApiConfig.getHeaders(token: AuthService.token);
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error fetching unread count: $e');
      return 0;
    }
  }

  // Notification уншсан болгох
  static Future<bool> markAsRead(String notificationId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint/$notificationId/read');
      final headers = ApiConfig.getHeaders(token: AuthService.token);
      
      final response = await http.put(url, headers: headers);
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Бүх notification-уудыг уншсан болгох
  static Future<bool> markAllAsRead() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint/read-all');
      final headers = ApiConfig.getHeaders(token: AuthService.token);
      
      final response = await http.put(url, headers: headers);
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  // Notification устгах
  static Future<bool> deleteNotification(String notificationId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint/$notificationId');
      final headers = ApiConfig.getHeaders(token: AuthService.token);
      
      final response = await http.delete(url, headers: headers);
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // Real-time notification хүлээн авах callback тохируулах
  static void setOnNewNotificationCallback(Function(Notification) callback) {
    _onNewNotificationCallback = callback;
    
    // Socket.IO-д notification хүлээн авах callback тохируулах
    SocketService.setOnNotificationCallback((data) {
      try {
        final notification = Notification.fromJson(data);
        if (_onNewNotificationCallback != null) {
          _onNewNotificationCallback!(notification);
        }
      } catch (e) {
        print('Error parsing notification from socket: $e');
      }
    });
  }

  // Real-time notification listener-ийг устгах
  static void removeOnNewNotificationCallback() {
    _onNewNotificationCallback = null;
    SocketService.setOnNotificationCallback((_) {});
  }
}
