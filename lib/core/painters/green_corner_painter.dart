import 'dart:math' as math;
import 'package:flutter/material.dart';

class GreenCornerPainter extends CustomPainter {
  final double animationValue;

  GreenCornerPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFA8E0B0).withOpacity(0.6),
          const Color(0xFF4CAF50).withOpacity(0.3),
          const Color(0xFF2E7D32).withOpacity(0.1),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Pergeseran gelombang dari animasi
    double shift = math.sin(animationValue * 2 * math.pi) * 12;

    // --- Kurva Kiri Atas ---
    Path topLeftPath = Path();
    topLeftPath.moveTo(0, 0);
    topLeftPath.lineTo(size.width * 0.45, 0);
    topLeftPath.quadraticBezierTo(
      size.width * 0.25 + shift,
      size.height * 0.15 + shift,
      0,
      size.height * 0.25,
    );
    topLeftPath.close();
    canvas.drawPath(topLeftPath, paint);

    // --- Kurva Kanan Bawah ---
    Path bottomRightPath = Path();
    bottomRightPath.moveTo(size.width, size.height);
    bottomRightPath.lineTo(size.width * 0.55, size.height);
    bottomRightPath.quadraticBezierTo(
      size.width * 0.75 - shift,
      size.height * 0.85 - shift,
      size.width,
      size.height * 0.75,
    );
    bottomRightPath.close();
    canvas.drawPath(bottomRightPath, paint);
  }

  @override
  bool shouldRepaint(covariant GreenCornerPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}