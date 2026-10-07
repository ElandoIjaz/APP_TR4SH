import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test23/core/validators/auth_validator.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/auth/halaman_login.dart';

class HalamanDaftar extends StatefulWidget {
  const HalamanDaftar({super.key});

  @override
  State<HalamanDaftar> createState() => _HalamanDaftarState();
}

class _HalamanDaftarState extends State<HalamanDaftar> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _setuju = false;
  bool _isLoading = false;

  // Warna tema – hijau TR4SH
  static const Color _hijauUtama = Color(0xFF8DD832);
  static const Color _hijauMuda = Color(0xFFE8F5C8);
  static const Color _abuLatar = Color(0xFFF2F2F2);

  void _daftar() async {
    final nama = _namaController.text;
    final username = _usernameController.text;
    final telepon = _teleponController.text;
    final password = _passwordController.text;

    final error = AuthValidator.validateRegister(
      nama: nama,
      username: username,
      telepon: telepon,
      password: password,
      setuju: _setuju,
    );

    if (error != null) {
      _showSnackBar(error, Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    // Memanggil API backend Laravel TR4SH (/api/auth/register)
    final response = await ApiService.register(
      username: username,
      password: password,
      namaLengkap: nama,
      phone: telepon,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.success) {
      final userId = response.data is Map && response.data['id_user'] != null
          ? int.tryParse(response.data['id_user'].toString())
          : null;

      // Inisialisasi akun baru: semua konten dan tracking sampah diset ke 0
      UserAccountData.initNewUser(
        nama: nama,
        username: username,
        phone: telepon,
        userId: userId,
      );

      _showSnackBar(
        response.message.isNotEmpty ? response.message : 'Pendaftaran berhasil! Silakan masuk.',
        _hijauUtama,
      );

      // Kembali ke halaman login
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HalamanLogin()),
      );
    } else {
      _showSnackBar(response.message, Colors.redAccent);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _teleponController.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HalamanLogin()),
              );
            }
          },
        ),
        title: const Text(
          'Daftar Akun',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // ── Judul ──
              const Text(
                'Buat Akun Baru',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan lengkapi data diri Anda untuk membuat akun\nbaru.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 28),

              // ── Nama Lengkap ──
              _buildLabel('Nama Lengkap'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _namaController,
                hint: 'Nama Lengkap Anda (3-60 karakter)',
                prefixIcon: Icons.badge_outlined,
                keyboardType: TextInputType.name,
                maxLength: 60,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                  LengthLimitingTextInputFormatter(60),
                ],
              ),
              const SizedBox(height: 18),

              // ── Username ──
              _buildLabel('Username'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _usernameController,
                hint: 'username_anda (3-30 karakter, huruf saja)',
                prefixIcon: Icons.account_circle_outlined,
                keyboardType: TextInputType.text,
                maxLength: 30,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                  LengthLimitingTextInputFormatter(30),
                ],
              ),
              const SizedBox(height: 18),

              // ── No. Telepon ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel('No. Telepon / WhatsApp'),
                  const Text(
                    '11 - 13 digit angka',
                    style: TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _teleponController,
                hint: '081234567890 (hanya angka)',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                maxLength: 13,
                showCounter: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ],
              ),
              const SizedBox(height: 18),

              // ── Kata Sandi ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel('Kata Sandi'),
                  const Text(
                    '6 - 32 karakter',
                    style: TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
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
                  hintText: 'Minimal 6 karakter, maks. 32 (tanpa spasi)',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  counterText: '',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.lock_outline,
                        color: Colors.grey[600], size: 20),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: _hijauMuda,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
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
                    borderSide:
                        const BorderSide(color: _hijauUtama, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Checkbox Syarat & Ketentuan ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _setuju,
                    activeColor: _hijauUtama,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) =>
                        setState(() => _setuju = val ?? false),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                          children: [
                            const TextSpan(text: 'Saya menyetujui '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {},
                                child: const Text(
                                  'Syarat & Ketentuan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _hijauUtama,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    decorationColor: _hijauUtama,
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(text: ' serta Kebijakan Privasi.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Tombol Daftar ──
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _daftar,
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
                              'Daftar',
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

              // ── Sudah punya akun? Masuk ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun?  ',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => const HalamanLogin()),
                      );
                    },
                    child: const Text(
                      'Masuk',
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

  // ── Helper: Label field ──
  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  // ── Helper: TextField standar ──
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    bool showCounter = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        counterText: showCounter ? null : '',
        counterStyle: const TextStyle(fontSize: 11, color: Colors.grey),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(prefixIcon, color: Colors.grey[600], size: 20),
        ),
        filled: true,
        fillColor: _hijauMuda,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    );
  }
}
