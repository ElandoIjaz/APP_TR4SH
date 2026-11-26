import 'dart:async';
import 'package:flutter/material.dart';
import 'package:test23/core/painters/green_corner_painter.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _initApp();
  }

  Future<void> _initApp() async {
    await Future.wait([
      _restoreSession(),
      Future.delayed(const Duration(seconds: 2)),
    ]);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationPage()),
    );
  }

  Future<void> _restoreSession() async {
    try {
      final token = await ApiService.getToken();
      final user = await ApiService.getUserSession();
      if (token != null && token.isNotEmpty && user != null) {
        UserAccountData.updateFromUserData(Map<String, dynamic>.from(user));

        if (UserAccountData.currentUserId != null) {
          final statusRes = await ApiService.checkUserStatus(
            UserAccountData.currentUserId,
          );
          if (statusRes.statusCode == 401 ||
              statusRes.statusCode == 403 ||
              statusRes.statusCode == 404) {
            UserAccountData.setGuestMode();
            return;
          }
        }
        return;
      }
    } catch (_) {}
    UserAccountData.setGuestMode();
  }

  @override
  void dispose() {
    _navTimer?.cancel();
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

