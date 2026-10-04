import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/pages/auth/halaman_login.dart';
import 'package:test23/pages/beranda/halaman_beranda.dart';

/// Gate otentikasi: Memeriksa apakah user sudah login sebelum mengizinkan masuk ke aplikasi
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final token = await ApiService.getToken();
      final user = await ApiService.getUserSession();
      if (token != null && token.isNotEmpty && user != null) {
        if (mounted) {
          setState(() {
            _isAuthenticated = true;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bgScreen,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.mintSoft,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkGreen.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.recycling_rounded,
                  color: AppColors.darkGreen,
                  size: 42,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'TR4SH!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkGreen,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Bank Sampah Digital',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.darkGreen,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isAuthenticated) {
      return const HalamanBeranda();
    }

    // Jika belum login, wajib masuk atau daftar akun terlebih dahulu
    return const HalamanLogin();
  }
}
