// Socket.IO service - Real-time notification-уудыг хүлээн авах
// Backend-тай socket.io ашиглан холбогдож, real-time notification-уудыг хүлээн авна

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_config.dart';
import 'auth_service.dart';

class SocketService {
  static IO.Socket? _socket;
  static bool _isConnected = false;
  static Function(Map<String, dynamic>)? _onNotificationCallback;

  // Socket холболт эхлүүлэх
  static Future<void> connect() async {
    if (_socket != null && _isConnected) {
      print('Socket already connected');
      return;
    }

    try {
      // Base URL-ийг авах
      await ApiConfig.initialize();
      final baseUrl = await ApiConfig.getBaseUrl();
      
      // HTTP URL-аас Socket.IO URL үүсгэх
      final socketUrl = baseUrl.replaceFirst('http://', '').replaceFirst('https://', '');
      
      print('=== SocketService.connect ===');
      print('Connecting to: $socketUrl');
      print('Base URL: $baseUrl');

      // Socket.IO холболт үүсгэх
      _socket = IO.io(
        baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .build(),
      );

      // Холболт амжилттай болсон үед
      _socket!.onConnect((_) {
        _isConnected = true;
        print('✅ Socket connected: ${_socket!.id}');
        
        // Хэрэглэгчийн ID-г backend-д илгээх (room-д нэгдэх)
        final userId = AuthService.currentUserId;
        if (userId != null) {
          _socket!.emit('join', userId);
          print('👤 Joined room: user_$userId');
        }
      });

      // Холболт тасарсан үед
      _socket!.onDisconnect((_) {
        _isConnected = false;
        print('❌ Socket disconnected');
      });

      // Алдаа гарсан үед
      _socket!.onError((error) {
        print('❌ Socket error: $error');
        _isConnected = false;
      });

      // Connect event
      _socket!.onConnectError((error) {
        print('❌ Socket connect error: $error');
        _isConnected = false;
      });

      // Notification хүлээн авах
      _socket!.on('notification', (data) {
        print('📬 Received notification: $data');
        if (_onNotificationCallback != null && data != null) {
          _onNotificationCallback!(data as Map<String, dynamic>);
        }
      });

      // Холболт нээх
      _socket!.connect();
    } catch (e) {
      print('❌ Error connecting socket: $e');
      _isConnected = false;
    }
  }

  // Socket холболт салгах
  static void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      print('🔌 Socket disconnected and disposed');
    }
  }

  // Notification хүлээн авах callback тохируулах
  static void setOnNotificationCallback(Function(Map<String, dynamic>) callback) {
    _onNotificationCallback = callback;
  }

  // Холболттой эсэхийг шалгах
  static bool get isConnected => _isConnected;

  // Хэрэглэгч нэвтэрсний дараа room-д нэгдэх
  static void joinUserRoom(String userId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('join', userId);
      print('👤 Joined room: user_$userId');
    }
  }

  // Хэрэглэгч гарах үед room-аас гарах
  static void leaveUserRoom() {
    if (_socket != null && _isConnected) {
      // Socket disconnect хийх
      disconnect();
    }
  }
}
