import 'package:flutter/material.dart';
import 'package:test23/pages/halaman_login.dart';

class HalamanLupaPw extends StatefulWidget {
  const HalamanLupaPw({super.key});

  @override
  State<HalamanLupaPw> createState() => _HalamanLupaPwState();
}

class _HalamanLupaPwState extends State<HalamanLupaPw> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;

  // Warna tema – hijau TR4SH
  static const Color _hijauUtama = Color(0xFF8DD832);
  static const Color _hijauMuda = Color(0xFFE8F5C8);
  static const Color _abuLatar = Color(0xFFF2F2F2);

  void _kirimKodeVerifikasi() async {
    final input = _usernameController.text.trim();

    if (input.isEmpty) {
      _showSnackBar(
        'Masukkan username atau nomor telepon terlebih dahulu!',
        Colors.redAccent,
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulasi pengiriman kode verifikasi
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    _showSnackBar(
      'Kode verifikasi telah dikirim ke akun Anda.',
      _hijauUtama,
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
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
    _usernameController.dispose();
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
          'Forgot Password',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF2D2D2D),
              radius: 20,
              child: const Icon(Icons.person, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // ── Judul Besar ──
              const Text(
                'Lupa Kata Sandi?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // ── Deskripsi ──
              const Text(
                'Masukkan username atau nomor telepon yang terdaftar '
                'pada akun Anda untuk menerima kode verifikasi pemulihan '
                'sandi.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 32),

              // ── Card input ──
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
                    // Label
                    const Text(
                      'Username atau No. Telepon',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Field input
                    TextField(
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Username atau 08xxxxxxxxxx',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.manage_accounts_outlined,
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
                        enabledBorder: OutlineInputBorder(
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
              const SizedBox(height: 28),

              // ── Tombol Kirim Kode Verifikasi ──
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _kirimKodeVerifikasi,
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
                              'Kirim Kode Verifikasi',
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

              // ── Kembali ke Masuk ──
              GestureDetector(
                onTap: _kembaliKeLogin,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
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
