// API тохиргооны файл
// Backend серверийн URL болон бусад тохиргоонуудыг агуулна

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ApiConfig {
  // Backend серверийн base URL - platform-аас хамаарч автоматаар сонгоно
  
  // Компьютерийн IP хаягууд (physical device дээр ашиглах)
  // Олон IP хаягийг дэмжүүлэх - эхний амжилттай IP хаягийг ашиглана
  // Windows дээр: ipconfig командаар олох
  // Mac/Linux дээр: ifconfig эсвэл ip addr командаар олох
  // Жишээ: 192.168.1.100, 192.168.0.105, 173.16.10.93 гэх мэт
  // ЭНД КОМПЬЮТЕРИЙН IP ХАЯГУУД ОРУУЛНА УУ!
  static const List<String> defaultIPs = [
    '173.16.10.93', // Анхны IP хаяг
    // Нэмэлт IP хаягуудыг энд нэмэх боломжтой:
    // '192.168.1.100',
    // '192.168.0.105',
  ];
  
  // SharedPreferences key
  static const String _ipKey = 'server_ip_address';
  static const String _lastWorkingIPKey = 'last_working_ip';
  
  // IP хаягийг SharedPreferences-аас унших эсвэл default ашиглах
  static Future<String> getSavedIP() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIP = prefs.getString(_ipKey);
      if (savedIP != null && savedIP.isNotEmpty) {
        return savedIP;
      }
    } catch (e) {
      print('Error reading saved IP: $e');
    }
    return defaultIPs.isNotEmpty ? defaultIPs.first : 'localhost';
  }
  
  // IP хаягийг SharedPreferences дээр хадгалах
  static Future<void> saveIP(String ip) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_ipKey, ip);
      print('IP хаяг хадгалагдлаа: $ip');
    } catch (e) {
      print('Error saving IP: $e');
    }
  }
  
  // Сүүлийн амжилттай IP хаягийг хадгалах
  static Future<void> saveLastWorkingIP(String ip) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastWorkingIPKey, ip);
    } catch (e) {
      print('Error saving last working IP: $e');
    }
  }
  
  // Сүүлийн амжилттай IP хаягийг унших
  static Future<String?> getLastWorkingIP() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastWorkingIPKey);
    } catch (e) {
      return null;
    }
  }
  
  // Default IP хаяг (эхний IP хаяг)
  static String get defaultIP => defaultIPs.isNotEmpty ? defaultIPs.first : 'localhost';
  
  // Одоогийн IP хаяг (saved эсвэл default)
  static String _currentIP = '';
  static String get currentIP => _currentIP.isNotEmpty ? _currentIP : defaultIP;
  static set currentIP(String ip) => _currentIP = ip;
  
  // IP хаягийг initialize хийх
  static Future<void> initialize() async {
    _currentIP = await getSavedIP();
    // Сүүлийн амжилттай IP байвал түүнийг ашиглах
    final lastWorkingIP = await getLastWorkingIP();
    if (lastWorkingIP != null && lastWorkingIP.isNotEmpty) {
      _currentIP = lastWorkingIP;
    }
  }
  
  // Platform-аас хамаарч URL сонгох
  static String get baseUrl {
    try {
      // Web platform дээр localhost ашиглах (browser дээр physical IP ашиглах боломжгүй)
      if (kIsWeb) {
        return 'http://localhost:5000/api';
      }
      
      // Mobile/Desktop platform-ууд
      if (Platform.isAndroid) {
        // Android дээр currentIP ашиглах (physical device эсвэл emulator)
        // Emulator дээр 10.0.2.2 ашиглах хэрэгтэй бол доорх мөрийг uncomment хийх:
        // return 'http://10.0.2.2:5000/api';
        return 'http://${currentIP}:5000/api';
      } else if (Platform.isIOS) {
        // iOS simulator дээр localhost ажиллана
        // Physical device дээр currentIP ашиглах
        return 'http://localhost:5000/api'; // Simulator дээр
        // Physical device дээр: return 'http://${currentIP}:5000/api';
      } else {
        // Windows, macOS, Linux desktop дээр localhost
        return 'http://localhost:5000/api';
      }
    } catch (e) {
      // Platform тодорхойлох алдаа гарвал localhost ашиглах
      return 'http://localhost:5000/api';
    }
  }
  
  // Олон IP хаягаас амжилттай IP хаягийг олох функц
  // Бүх IP хаягийг туршиж, амжилттай IP хаягийг буцаана
  static Future<String?> findWorkingIP() async {
    // Web platform дээр IP олох шаардлагагүй (localhost ашиглана)
    if (kIsWeb) {
      print('🌐 Web platform дээр localhost ашиглана');
      return 'localhost';
    }
    
    // Бүх IP хаягуудыг нэгтгэх (saved IP, last working IP, default IPs)
    final List<String> ipsToTry = [];
    
    // Saved IP
    final savedIP = await getSavedIP();
    if (savedIP.isNotEmpty && savedIP != 'localhost') {
      ipsToTry.add(savedIP);
    }
    
    // Last working IP
    final lastWorkingIP = await getLastWorkingIP();
    if (lastWorkingIP != null && lastWorkingIP.isNotEmpty && !ipsToTry.contains(lastWorkingIP)) {
      ipsToTry.add(lastWorkingIP);
    }
    
    // Default IPs
    for (final ip in defaultIPs) {
      if (!ipsToTry.contains(ip)) {
        ipsToTry.add(ip);
      }
    }
    
    // Бүх IP хаягийг туршиж, амжилттай IP хаягийг олох
    for (final ip in ipsToTry) {
      try {
        final url = Uri.parse('http://$ip:5000/api/health');
        final response = await http.get(url).timeout(
          const Duration(seconds: 2),
          onTimeout: () => throw Exception('Timeout'),
        );
        
        if (response.statusCode == 200) {
          // Амжилттай IP хаягийг хадгалах
          await saveIP(ip);
          await saveLastWorkingIP(ip);
          _currentIP = ip;
          print('✅ Амжилттай IP хаяг олдлоо: $ip');
          return ip;
        }
      } catch (e) {
        // Энэ IP хаяг ажиллахгүй байна, дараагийн IP хаягийг турших
        print('❌ IP хаяг ажиллахгүй: $ip');
        continue;
      }
    }
    
    // Бүх IP хаяг ажиллахгүй байна
    print('⚠️ Бүх IP хаяг ажиллахгүй байна');
    return null;
  }
  
  // API endpoint-ууд
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String meEndpoint = '/auth/me';
  static const String serviceRequestsEndpoint = '/service-requests';
  static const String techniciansEndpoint = '/technicians';
  static const String announcementsEndpoint = '/announcements';
  
  // Headers
  static Map<String, String> getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}
