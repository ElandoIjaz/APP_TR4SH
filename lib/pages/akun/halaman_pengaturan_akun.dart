import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/core/validators/auth_validator.dart';

class HalamanPengaturanAkun extends StatefulWidget {
  const HalamanPengaturanAkun({super.key});

  @override
  State<HalamanPengaturanAkun> createState() => _HalamanPengaturanAkunState();
}

class _HalamanPengaturanAkunState extends State<HalamanPengaturanAkun> {
  bool _twoFactorEnabled = true;
  bool _notifSetor = true;
  bool _notifKurir = true;
  bool _notifPromo = false;
  bool _dataSaver = false;

  void _showChangePasswordDialog() {
    final currentPwController = TextEditingController();
    final newPwController = TextEditingController();
    final confirmPwController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.mintSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock_rounded, color: AppColors.darkGreen, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Ubah Kata Sandi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F7F3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 16, color: AppColors.darkGreen),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Keamanan akun menggunakan kata sandi teks murni (tanpa sidik jari/biometrik).',
                          style: TextStyle(fontSize: 10.5, color: Color(0xFF386B52), height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Kata Sandi Saat Ini',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                const SizedBox(height: 6),
                TextField(
                  controller: currentPwController,
                  obscureText: obscureCurrent,
                  maxLength: 32,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    LengthLimitingTextInputFormatter(32),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Masukkan kata sandi lama',
                    hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFFF9FCFA),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscureCurrent = !obscureCurrent;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Kata Sandi Baru',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                    Text('6 - 32 karakter',
                        style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: newPwController,
                  obscureText: obscureNew,
                  maxLength: 32,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    LengthLimitingTextInputFormatter(32),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Minimal 6 karakter kombinasi (tanpa spasi)',
                    hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFFF9FCFA),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscureNew = !obscureNew;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Konfirmasi Kata Sandi Baru',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                const SizedBox(height: 6),
                TextField(
                  controller: confirmPwController,
                  obscureText: obscureConfirm,
                  maxLength: 32,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    LengthLimitingTextInputFormatter(32),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Ulangi kata sandi baru',
                    hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFFF9FCFA),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscureConfirm = !obscureConfirm;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              onPressed: () {
                final curr = currentPwController.text.trim();
                final newP = newPwController.text.trim();
                final conf = confirmPwController.text.trim();

                if (curr.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kata sandi saat ini harus diisi!'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                final pwErr = AuthValidator.validatePassword(newP);
                if (pwErr != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(pwErr),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                if (newP != conf) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Konfirmasi kata sandi baru tidak cocok!'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kata sandi berhasil diperbarui dengan aman!'),
                    backgroundColor: AppColors.darkGreen,
                  ),
                );
              },
              child: const Text(
                'Simpan Perubahan',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPinDialog() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.mintSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.pin_outlined, color: AppColors.darkGreen, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'PIN Transaksi 6-Digit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PIN angka ini digunakan sebagai verifikasi keamanan saat menukar poin atau melakukan pesanan tanpa sidik jari.',
              style: TextStyle(fontSize: 11.5, color: Color(0xFF4C6656), height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, letterSpacing: 8, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '••••••',
                hintStyle: const TextStyle(letterSpacing: 8),
                filled: true,
                fillColor: const Color(0xFFF9FCFA),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PIN Transaksi berhasil disimpan!'),
                  backgroundColor: AppColors.darkGreen,
                ),
              );
            },
            child: const Text('Simpan PIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6F3DD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.darkGreen, size: 20),
              ),
            ),
          ),
        ),
        title: const Text(
          'Pengaturan Akun',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Keamanan Tanpa Biometrik
              _buildSectionTitle('KEAMANAN & MASUK (KATA SANDI & PIN)'),
              _buildSettingGroup([
                _buildActionTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Ubah Kata Sandi',
                  subtitle: 'Kata sandi teks utama (tanpa sidik jari)',
                  onTap: _showChangePasswordDialog,
                ),
                const Divider(height: 1, indent: 50, color: Color(0xFFEDF5F0)),
                _buildActionTile(
                  icon: Icons.pin_outlined,
                  title: 'PIN Transaksi & Dompet',
                  subtitle: 'PIN 6-digit untuk verifikasi penukaran poin & saldo',
                  onTap: _showPinDialog,
                ),
                const Divider(height: 1, indent: 50, color: Color(0xFFEDF5F0)),
                _buildSwitchTile(
                  icon: Icons.security_rounded,
                  title: 'Verifikasi 2 Langkah (2FA)',
                  subtitle: 'Konfirmasi kode OTP via SMS/WhatsApp saat login baru',
                  value: _twoFactorEnabled,
                  onChanged: (val) => setState(() => _twoFactorEnabled = val),
                ),
              ]),

              const SizedBox(height: 20),

              // Notifikasi
              _buildSectionTitle('PREFERENSI NOTIFIKASI'),
              _buildSettingGroup([
                _buildSwitchTile(
                  icon: Icons.recycling_rounded,
                  title: 'Notifikasi Sampah & Poin',
                  subtitle: 'Pemberitahuan verifikasi timbangan & penambahan poin',
                  value: _notifSetor,
                  onChanged: (val) => setState(() => _notifSetor = val),
                ),
                const Divider(height: 1, indent: 50, color: Color(0xFFEDF5F0)),
                _buildSwitchTile(
                  icon: Icons.local_shipping_outlined,
                  title: 'Update Pengiriman Kurir',
                  subtitle: 'Pelacakan real-time lokasi kurir pesanan produk',
                  value: _notifKurir,
                  onChanged: (val) => setState(() => _notifKurir = val),
                ),
                const Divider(height: 1, indent: 50, color: Color(0xFFEDF5F0)),
                _buildSwitchTile(
                  icon: Icons.local_offer_outlined,
                  title: 'Promo & Acara Komunitas',
                  subtitle: 'Info workshop dan penawaran produk sirkular',
                  value: _notifPromo,
                  onChanged: (val) => setState(() => _notifPromo = val),
                ),
              ]),

              const SizedBox(height: 20),

              // Preferensi Umum
              _buildSectionTitle('PREFERENSI APLIKASI'),
              _buildSettingGroup([
                _buildActionTile(
                  icon: Icons.language_rounded,
                  title: 'Bahasa',
                  subtitle: 'Bahasa Indonesia (Standar)',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 50, color: Color(0xFFEDF5F0)),
                _buildSwitchTile(
                  icon: Icons.network_cell_rounded,
                  title: 'Mode Hemat Kuota Data',
                  subtitle: 'Menurunkan resolusi gambar video dan peta',
                  value: _dataSaver,
                  onChanged: (val) => setState(() => _dataSaver = val),
                ),
              ]),

              const SizedBox(height: 20),

              // Kebijakan & Privasi
              _buildSectionTitle('TENTANG & HUKUM'),
              _buildSettingGroup([
                _buildActionTile(
                  icon: Icons.shield_outlined,
                  title: 'Kebijakan Privasi',
                  subtitle: 'Perlindungan data pribadi Anda',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 50, color: Color(0xFFEDF5F0)),
                _buildActionTile(
                  icon: Icons.article_outlined,
                  title: 'Syarat & Ketentuan Layanan',
                  subtitle: 'Ketentuan penggunaan platform TR4SH!',
                  onTap: () {},
                ),
              ]),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF386B52),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSettingGroup(List<Widget> children) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.cardBorder, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.mintSoft,
        child: Icon(icon, size: 18, color: AppColors.darkGreen),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFB5C7BD), size: 20),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.mintSoft,
        child: Icon(icon, size: 18, color: AppColors.darkGreen),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      trailing: Switch(
        value: value,
        activeThumbColor: AppColors.darkGreen,
        activeTrackColor: AppColors.mintSoft,
        onChanged: onChanged,
      ),
    );
  }
}
