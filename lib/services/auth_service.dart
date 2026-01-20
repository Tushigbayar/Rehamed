// Нэвтрэх, бүртгүүлэх service
// Backend API-тай холбогдож, хэрэглэгчийн нэвтрэх, бүртгүүлэх үйлдлүүдийг гүйцэтгэнэ

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class AuthService {
  static String? _token;
  static String? _currentUserId;
  static String? _currentUserName;
  static String? _currentUserRole;
  static bool _isLoggedIn = false;

  static bool get isLoggedIn => _isLoggedIn;
  static String? get currentUserId => _currentUserId;
  static String? get currentUserName => _currentUserName;
  static String? get currentUserRole => _currentUserRole;
  static String? get token => _token;

  // Token-ийг SharedPreferences дээр хадгалах
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
  }

  // Token-ийг SharedPreferences-аас унших
  static Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      print('=== AuthService._loadToken ===');
      print('Token loaded from SharedPreferences: ${_token != null}');
      print('Token value: ${_token != null ? _token!.substring(0, 20) + "..." : "null"}');
      
      if (_token != null) {
        _isLoggedIn = true;
        // Token-оос хэрэглэгчийн мэдээллийг авах
        await getCurrentUser();
      } else {
        print('WARNING: Token is null, user is not logged in');
        _isLoggedIn = false;
      }
    } catch (e) {
      print('ERROR loading token: $e');
      _token = null;
      _isLoggedIn = false;
    }
  }

  // Нэвтрэх функц
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // IP хаягийг initialize хийх (өөр төхөөрөмж дээр ашиглах)
      await ApiConfig.initialize();
      
      // Public URL эсвэл local IP ашиглах
      final baseUrl = await ApiConfig.getBaseUrl();
      final url = Uri.parse('$baseUrl${ApiConfig.loginEndpoint}');
      
      // Debug: URL болон headers хэвлэх
      print('=== Login Debug ===');
      print('Login URL: $url');
      print('Base URL: ${ApiConfig.baseUrl}');
      print('Current IP: ${ApiConfig.currentIP}');
      
      final response = await http.post(
        url,
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 30), // Timeout-ийг уртасгасан
        onTimeout: () {
          throw Exception('Холболтын хугацаа дууссан. Сервер ажиллаж байгаа эсэхийг шалгана уу.');
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          _token = data['token'];
          _currentUserId = data['user']['id'];
          _currentUserName = data['user']['name'];
          _currentUserRole = data['user']['role'];
          _isLoggedIn = true;

          // Token-ийг хадгалах
          await _saveToken(_token!);

          return {
            'success': true,
            'user': data['user'],
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Серверийн хариу буруу байна: ${e.toString()}',
          };
        }
      } else {
        try {
          final errorBody = response.body;
          if (errorBody.isNotEmpty) {
            final error = jsonDecode(errorBody);
            return {
              'success': false,
              'error': error['error'] ?? 'Нэвтрэхэд алдаа гарлаа',
            };
          } else {
            return {
              'success': false,
              'error': 'Нэвтрэхэд алдаа гарлаа (${response.statusCode})',
            };
          }
        } catch (e) {
          return {
            'success': false,
            'error': 'Нэвтрэхэд алдаа гарлаа (${response.statusCode})',
          };
        }
      }
    } catch (e) {
      String errorMessage = 'Холболтын алдаа';
      
      // Debug: Алдааны мэдээлэл хэвлэх
      print('=== Login Error ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: ${e.toString()}');
      
      // ClientException (Load failed) - ихэвчлэн network холболт байхгүй эсвэл IP хаяг буруу байх
      if (e.toString().contains('ClientException') || 
          e.toString().contains('Load failed') ||
          e.toString().contains('Failed host lookup') || 
          e.toString().contains('Connection refused') ||
          e.toString().contains('Network is unreachable') ||
          e.toString().contains('SocketException')) {
        errorMessage = 'Серверт холбогдох боломжгүй байна.\n\n'
            'Шалгах зүйлс:\n'
            '1. Backend server ажиллаж байгаа эсэх (http://${ApiConfig.currentIP}:5000)\n'
            '2. IP хаяг зөв эсэх (Одоогийн IP: ${ApiConfig.currentIP})\n'
            '3. Device болон computer ижил WiFi дээр байгаа эсэх\n'
            '4. Firewall 5000 портыг блоклож байгаа эсэх\n\n'
            '💡 Settings дээр IP хаягийг шалгах эсвэл "Автоматаар олох" товчийг дарах';
      } else if (e.toString().contains('timeout') || e.toString().contains('TimeoutException')) {
        errorMessage = 'Холболтын хугацаа дууссан.\n\n'
            'Сервер ажиллаж байгаа эсэхийг шалгана уу.\n'
            'IP хаяг: ${ApiConfig.currentIP}';
      } else {
        errorMessage = 'Холболтын алдаа: ${e.toString()}\n\n'
            'IP хаяг: ${ApiConfig.currentIP}\n'
            'Base URL: ${ApiConfig.baseUrl}';
      }
      
      return {
        'success': false,
        'error': errorMessage,
      };
    }
  }

  // Бүртгүүлэх функц
  static Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String name,
    String? email,
    String role = 'user',
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}');
      final response = await http.post(
        url,
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'username': username,
          'password': password,
          'name': name,
          'email': email,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUserId = data['user']['id'];
        _currentUserName = data['user']['name'];
        _currentUserRole = data['user']['role'];
        _isLoggedIn = true;

        // Token-ийг хадгалах
        await _saveToken(_token!);

        return {
          'success': true,
          'user': data['user'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Бүртгүүлэхэд алдаа гарлаа',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Холболтын алдаа: ${e.toString()}',
      };
    }
  }

  // Одоогийн хэрэглэгчийн мэдээлэл авах
  static Future<void> getCurrentUser() async {
    if (_token == null) {
      await _loadToken();
    }

    if (_token == null) return;

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.meEndpoint}');
      final headers = ApiConfig.getHeaders(token: _token);
      print('=== AuthService.getCurrentUser ===');
      print('URL: $url');
      print('Headers: $headers');
      
      final response = await http.get(
        url,
        headers: headers,
      );
      
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUserId = data['user']['_id'] ?? data['user']['id'];
        _currentUserName = data['user']['name'];
        _currentUserRole = data['user']['role'];
        _isLoggedIn = true;
      } else {
        // Token хүчингүй болсон, гарах
        await logout();
      }
    } catch (e) {
      // Алдаа гарвал гарах
      await logout();
    }
  }

  // Гарах функц
  static Future<void> logout() async {
    _isLoggedIn = false;
    _currentUserId = null;
    _currentUserName = null;
    _currentUserRole = null;
    _token = null;

    // Token-ийг устгах
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Хэрэглэгчийн мэдээллийг тохируулах (legacy support)
  static void setUser(String userId, String userName) {
    _currentUserId = userId;
    _currentUserName = userName;
    _isLoggedIn = true;
  }

  // App эхлэхэд token-ийг унших
  static Future<void> initialize() async {
    await _loadToken();
  }
}
