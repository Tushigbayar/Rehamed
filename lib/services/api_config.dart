// API тохиргооны файл
// Backend серверийн URL болон бусад тохиргоонуудыг агуулна

class ApiConfig {
  // Backend серверийн base URL
  // Local development: http://localhost:5000
  // Android emulator: http://10.0.2.2:5000
  // iOS simulator: http://localhost:5000
  // Physical device: http://YOUR_COMPUTER_IP:5000 (жишээ: http://192.168.1.100:5000)
  static const String baseUrl = 'http://localhost:5000/api';
  
  // Android emulator дээр ажиллах бол доорх URL ашиглана:
  // static const String baseUrl = 'http://10.0.2.2:5000/api';
  
  // Physical device дээр ажиллах бол компьютерийн IP хаягийг оруулна:
  // static const String baseUrl = 'http://192.168.1.100:5000/api';
  
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
