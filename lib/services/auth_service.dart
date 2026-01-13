class AuthService {
  static String? _currentUserId;
  static String? _currentUserName;
  static bool _isLoggedIn = false;

  static bool get isLoggedIn => _isLoggedIn;
  static String? get currentUserId => _currentUserId;
  static String? get currentUserName => _currentUserName;

  // Mock login - production дээр database эсвэл API ашиглана
  static Future<bool> login(String username, String password) async {
    // Mock authentication
    await Future.delayed(const Duration(seconds: 1));
    
    if (username.isNotEmpty && password.isNotEmpty) {
      _isLoggedIn = true;
      _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _currentUserName = username;
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    _isLoggedIn = false;
    _currentUserId = null;
    _currentUserName = null;
  }

  static void setUser(String userId, String userName) {
    _currentUserId = userId;
    _currentUserName = userName;
    _isLoggedIn = true;
  }
}
