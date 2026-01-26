import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/api_config.dart';
import 'services/socket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // App эхлэхэд хадгалсан token-ийг унших
  await AuthService.initialize();
  // App эхлэхэд IP хаягийг initialize хийх
  await ApiConfig.initialize();
  
  // Хэрэглэгч нэвтэрсэн бол socket холболт эхлүүлэх
  if (AuthService.isLoggedIn) {
    SocketService.connect().then((_) {
      final userId = AuthService.currentUserId;
      if (userId != null) {
        SocketService.joinUserRoom(userId);
      }
    });
  }
  
  runApp(const HospitalApp());
}

class HospitalApp extends StatelessWidget {
  const HospitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'РЕХА SUPPLY - Засвар үйлчилгээний систем',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: LogoColors.green, // Логоны ногоон өнгө
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        // Homescreen өнгө тохируулах
        primaryColor: LogoColors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user is logged in
    if (AuthService.isLoggedIn) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}

// Логоны өнгөнүүд
class LogoColors {
  static const Color green = Color(0xFF4CAF50);      // Ногоон
  static const Color red = Color(0xFFE53935);         // Улаан
  static const Color amber = Color(0xFFFFB300);      // Улбар шар
  static const Color blue = Color(0xFF2196F3);       // Хөх
}

// РЕХА МЕД лого
class RehaMedLogo extends StatelessWidget {
  final double size;

  const RehaMedLogo({super.key, this.size = 60});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Custom painted logo as background
          CustomPaint(
            painter: LogoPainter(),
          ),
          // Image on top
          Center(
            child: Image.asset(
              'img/logo-removebg-preview.png',
              width: size * 0.8,
              height: size * 0.8,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Хэрэв зураг олдохгүй бол хоосон widget
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;
    
    // 4 өнгийн навч/дэлбээ хэлбэртэй бэлгэдэл
    final colors = [
      LogoColors.green,   // Баруун дээд
      LogoColors.red,     // Баруун доод
      LogoColors.amber,   // Зүүн доод
      LogoColors.blue,    // Зүүн дээд
    ];
    
    final angles = [
      -math.pi / 4,      // Баруун дээд
      math.pi / 4,       // Баруун доод
      3 * math.pi / 4,   // Зүүн доод
      -3 * math.pi / 4,  // Зүүн дээд
    ];
    
    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;
      
      final path = Path();
      final startAngle = angles[i];
      final sweepAngle = math.pi / 2;
      
      // Навч/дэлбээ хэлбэртэй зурах
      path.moveTo(center.dx, center.dy);
      
      // Гадна талын нумыг зурах
      for (double angle = startAngle; angle <= startAngle + sweepAngle; angle += 0.1) {
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);
        if (angle == startAngle) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      // Дотор талын нумыг зурах (жижиг)
      final innerRadius = radius * 0.3;
      for (double angle = startAngle + sweepAngle; angle >= startAngle; angle -= 0.1) {
        final x = center.dx + innerRadius * math.cos(angle);
        final y = center.dy + innerRadius * math.sin(angle);
        path.lineTo(x, y);
      }
      
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

