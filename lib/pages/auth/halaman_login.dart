import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/core/validators/auth_validator.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/pages/beranda/halaman_beranda.dart';
import 'package:test23/pages/auth/halaman_daftar.dart';
import 'package:test23/pages/auth/halaman_lupa_pw.dart';

class HalamanLogin extends StatefulWidget {
  const HalamanLogin({super.key});

  @override
  State<HalamanLogin> createState() => _HalamanLoginState();
}

class _HalamanLoginState extends State<HalamanLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Warna tema – hijau TR4SH
  static const Color _hijauUtama = AppColors.authPrimary;
  static const Color _hijauMuda = AppColors.authLightGreen;
  static const Color _abuLatar = AppColors.authBgGrey;

  void _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final error = AuthValidator.validateLogin(
      username: username,
      password: password,
    );

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Memanggil API backend Laravel TR4SH (/api/auth/login)
    final response = await ApiService.login(
      username: username,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message.isNotEmpty ? response.message : 'Login berhasil!',
          ),
          backgroundColor: _hijauUtama,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigasi ke halaman beranda TR4SH!
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HalamanBeranda()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _abuLatar,
      appBar: AppBar(
        backgroundColor: _abuLatar,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
              )
            : null,
        title: const Text(
          'Masuk Akun',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // ── Logo Brand ──
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6F5E1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.recycling_rounded,
                    color: AppColors.darkGreen,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Judul ──
              const Text(
                'Masuk Akun',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Masuk untuk melanjutkan ke akun TR4SH Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // ── Label Username ──
              const Text(
                'Nama Pengguna / Username',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // ── Field Username ──
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                maxLength: 50,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                  LengthLimitingTextInputFormatter(50),
                ],
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Masukkan nama pengguna / username (huruf saja)',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: _hijauMuda,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _hijauUtama, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Row: Label Kata Sandi + Lupa ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kata Sandi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HalamanLupaPw(),
                        ),
                      );
                    },
                    child: const Text(
                      'Lupa Kata Sandi?',
                      style: TextStyle(
                        fontSize: 13,
                        color: _hijauUtama,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Field Kata Sandi ──
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                maxLength: 32,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  LengthLimitingTextInputFormatter(32),
                ],
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  counterText: '',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.lock_outline,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  filled: true,
                  fillColor: _hijauMuda,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _hijauUtama, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Tombol Masuk ──
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hijauUtama,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.black87,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Masuk',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Daftar Sekarang ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum punya akun?  ',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HalamanDaftar(),
                        ),
                      );
                    },
                    child: const Text(
                      'Daftar Sekarang',
                      style: TextStyle(
                        fontSize: 13,
                        color: _hijauUtama,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
