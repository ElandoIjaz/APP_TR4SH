import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/core/validators/auth_validator.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/pages/auth/halaman_login.dart';

class HalamanResetPw extends StatefulWidget {
  final String initialNoWa;

  const HalamanResetPw({super.key, this.initialNoWa = ''});

  @override
  State<HalamanResetPw> createState() => _HalamanResetPwState();
}

class _HalamanResetPwState extends State<HalamanResetPw> {
  late final TextEditingController _waCtrl;
  final TextEditingController _kodeCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  static const Color _hijauUtama = AppColors.authPrimary;
  static const Color _hijauMuda = AppColors.authLightGreen;
  static const Color _abuLatar = AppColors.authBgGrey;

  @override
  void initState() {
    super.initState();
    _waCtrl = TextEditingController(text: widget.initialNoWa);
  }

  @override
  void dispose() {
    _waCtrl.dispose();
    _kodeCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitResetPassword() async {
    final noWa = _waCtrl.text.trim();
    final kode = _kodeCtrl.text.trim().toUpperCase();
    final pass = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    final hpError = AuthValidator.validateNomorHp(noWa);
    if (hpError != null) {
      _showSnackBar(hpError, Colors.redAccent);
      return;
    }
    if (kode.length != 8) {
      _showSnackBar('Kode pemulihan harus tepat 8 karakter.', Colors.redAccent);
      return;
    }
    if (pass.length < 6) {
      _showSnackBar('Kata sandi baru minimal 6 karakter.', Colors.redAccent);
      return;
    }
    if (pass != confirm) {
      _showSnackBar('Konfirmasi kata sandi baru tidak cocok.', Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);
    final res = await ApiService.confirmPasswordReset(
      noWa: noWa,
      kode: kode,
      newPassword: pass,
      confirmPassword: confirm,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.success) {
      _showSnackBar(res.message, AppColors.darkGreen);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HalamanLogin()),
        (route) => false,
      );
    } else {
      _showSnackBar(res.message, Colors.redAccent);
    }
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

  InputDecoration _inputStyle(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      counterText: '',
      prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: _hijauMuda,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _hijauUtama, width: 2),
      ),
    );
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Masukkan Kode Pemulihan',
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
              const Text(
                'Atur Ulang Sandi',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masukkan kode pemulihan 8 karakter yang dikirimkan otomatis ke WhatsApp Anda beserta kata sandi baru.',
                style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 24),
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
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _waCtrl,
                      keyboardType: TextInputType.phone,
                      maxLength: 15,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _inputStyle(
                        'Contoh: 081234567890',
                        Icons.phone_android_rounded,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Kode Pemulihan (8 Karakter)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _kodeCtrl,
                      maxLength: 8,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                      ],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      decoration: _inputStyle(
                        'Contoh: A7K9M2P4',
                        Icons.vpn_key_outlined,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Kata Sandi Baru',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePass,
                      decoration: _inputStyle(
                        'Minimal 6 karakter',
                        Icons.lock_outline,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePass ? Icons.visibility_off : Icons.visibility,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Konfirmasi Kata Sandi Baru',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _confirmCtrl,
                      obscureText: _obscureConfirm,
                      decoration: _inputStyle(
                        'Ulangi kata sandi baru',
                        Icons.lock_reset_outlined,
                        suffix: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
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
                  onPressed: _isLoading ? null : _submitResetPassword,
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
                      : const Text(
                          'Simpan Kata Sandi Baru',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}