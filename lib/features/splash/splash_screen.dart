import 'dart:async';
import 'package:flutter/material.dart';
import 'package:test23/core/painters/green_corner_painter.dart';
import 'package:test23/core/routes/white_page_route.dart' show WhiteFadePageRoute;
import 'package:test23/pages/beranda/halaman_beranda.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
        WhiteFadePageRoute(page: const HalamanBeranda()),
      );
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFDFB),
      body: Stack(
        children: [
          //pakai positioned.fill supaya canvas hijau memenuhi layar
          Positioned.fill(
            child: ListenableBuilder(
              listenable: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: GreenCornerPainter(
            animationValue: _waveController.value,
                ),
              );
            },
          ),
          ),

          //2. Logo utama (tambah errorBuilder kalau asset gambar belum terbaca)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Image.asset(
                'assets/images/logo_trash.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace){
                  return const Text(
                    'TRASH',
                    style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                    letterSpacing: 2,
                    ),
                    );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

