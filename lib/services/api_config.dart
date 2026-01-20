// API тохиргооны файл
// Backend серверийн URL болон бусад тохиргоонуудыг агуулна

import 'dart:io';

class ApiConfig {
  // Backend серверийн base URL - platform-аас хамаарч автоматаар сонгоно
  
  // Компьютерийн IP хаяг (physical device дээр ашиглах)
  // Windows дээр: ipconfig командаар олох
  // Mac/Linux дээр: ifconfig эсвэл ip addr командаар олох
  // Жишээ: 192.168.1.100, 192.168.0.105 гэх мэт
  // ЭНД КОМПЬЮТЕРИЙН IP ХАЯГ ОРУУЛНА УУ!
  static const String computerIP = '173.16.10.93'; // Компьютерийн IP хаяг
  
  // Platform-аас хамаарч URL сонгох
  static String get baseUrl {
    try {
      if (Platform.isAndroid) {
        // Android дээр computerIP ашиглах (physical device эсвэл emulator)
        // Emulator дээр 10.0.2.2 ашиглах хэрэгтэй бол доорх мөрийг uncomment хийх:
        // return 'http://10.0.2.2:5000/api';
        return 'http://$computerIP:5000/api';
      } else if (Platform.isIOS) {
        // iOS simulator дээр localhost ажиллана
        // Physical device дээр computerIP ашиглах
        return 'http://localhost:5000/api'; // Simulator дээр
        // Physical device дээр: return 'http://$computerIP:5000/api';
      } else {
        // Windows, macOS, Linux дээр localhost
        return 'http://localhost:5000/api';
      }
    } catch (e) {
      // Platform тодорхойлох алдаа гарвал localhost ашиглах
      return 'http://localhost:5000/api';
    }
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
