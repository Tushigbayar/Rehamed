import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const HospitalApp());
}

class HospitalApp extends StatelessWidget {
  const HospitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'РЕХА МЕД - Засвар үйлчилгээний систем',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // Ногоон өнгө
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
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
      child: CustomPaint(
        painter: LogoPainter(),
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

