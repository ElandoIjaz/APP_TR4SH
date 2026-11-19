import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/core/validators/auth_validator.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/pages/auth/halaman_login.dart';
import 'package:test23/pages/auth/resetpw.dart';

class HalamanLupaPw extends StatefulWidget {
  const HalamanLupaPw({super.key});

  @override
  State<HalamanLupaPw> createState() => _HalamanLupaPwState();
}

class _HalamanLupaPwState extends State<HalamanLupaPw> {
  final TextEditingController _waController = TextEditingController();
  bool _isLoading = false;

  static const Color _hijauUtama = AppColors.authPrimary;
  static const Color _hijauMuda = AppColors.authLightGreen;
  static const Color _abuLatar = AppColors.authBgGrey;

  Future<void> _kirimKodeWa() async {
    final noWa = _waController.text.trim();

    final hpError = AuthValidator.validateNomorHp(noWa);
    if (hpError != null) {
      _showSnackBar(hpError, Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    final res = await ApiService.requestPasswordReset(noWa: noWa);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!res.success) {
      _showSnackBar(res.message, Colors.redAccent);
      return;
    }

    _showSnackBar(res.message, AppColors.darkGreen);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HalamanResetPw(initialNoWa: noWa),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _kembaliKeLogin() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HalamanLogin()),
      );
    }
  }

  @override
  void dispose() {
    _waController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _abuLatar,
      appBar: AppBar(
        backgroundColor: _abuLatar,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _kembaliKeLogin,
        ),
        title: const Text(
          'Lupa Kata Sandi',
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Lupa Kata Sandi?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Masukkan nomor WhatsApp yang terdaftar pada akun Anda. Sistem akan mengirimkan kode pemulihan 8 karakter secara otomatis ke WhatsApp Anda.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nomor WhatsApp Terdaftar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _waController,
                      keyboardType: TextInputType.phone,
                      maxLength: 15,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(15),
                      ],
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Contoh: 081234567890',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                        counterText: '',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.phone_android_rounded,
                            color: Colors.grey[600],
                            size: 20,
                          ),
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: _hijauUtama,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _kirimKodeWa,
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
                              'Kirim Kode ke WhatsApp',
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
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HalamanResetPw(
                        initialNoWa: _waController.text.trim(),
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkGreen,
                  side: const BorderSide(color: AppColors.darkGreen),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.vpn_key_outlined, size: 18),
                label: const Text(
                  'Sudah Terima Kode? Masukkan Kode',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _kembaliKeLogin,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, size: 15, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      'Kembali ke Masuk',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}