import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/core/validators/auth_validator.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/data/user_account_data.dart';

class HalamanPengaturanAkun extends StatefulWidget {
  const HalamanPengaturanAkun({super.key});

  @override
  State<HalamanPengaturanAkun> createState() => _HalamanPengaturanAkunState();
}

class _HalamanPengaturanAkunState extends State<HalamanPengaturanAkun> {
  String _formatNomorWa(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'Belum diatur (lengkapi di Edit Profil)';
    if (digits.startsWith('62') && digits.length >= 10) {
      return '0${digits.substring(2)}';
    }
    return digits;
  }

  void _showChangePasswordDialog() {
    final currentPwController = TextEditingController();
    final newPwController = TextEditingController();
    final confirmPwController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (innerContext, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.mintSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: AppColors.darkGreen,
                  size: 20,
                ),
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
                const Text(
                  'Kata Sandi Saat Ini',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: currentPwController,
                  enabled: !isSubmitting,
                  obscureText: obscureCurrent,
                  maxLength: 32,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    LengthLimitingTextInputFormatter(32),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Masukkan kata sandi lama',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFFF9FCFA),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrent
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kata Sandi Baru',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    Text(
                      '6 - 32 karakter',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: newPwController,
                  enabled: !isSubmitting,
                  obscureText: obscureNew,
                  maxLength: 32,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    LengthLimitingTextInputFormatter(32),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Minimal 6 karakter (tanpa spasi)',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFFF9FCFA),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNew
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
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
                const Text(
                  'Konfirmasi Kata Sandi Baru',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: confirmPwController,
                  enabled: !isSubmitting,
                  obscureText: obscureConfirm,
                  maxLength: 32,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    LengthLimitingTextInputFormatter(32),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Ulangi kata sandi baru',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFFF9FCFA),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
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
              onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
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
                            content: Text(
                              'Konfirmasi kata sandi baru tidak cocok!',
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      final userId = UserAccountData.currentUserId;
                      if (userId == null) return;

                      setDialogState(() => isSubmitting = true);

                      final res = await ApiService.changePassword(
                        idUser: userId,
                        currentPassword: curr,
                        newPassword: newP,
                        confirmPassword: conf,
                      );

                      if (!mounted) return;
                      setDialogState(() => isSubmitting = false);

                      if (res.success) {
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res.message),
                            backgroundColor: AppColors.darkGreen,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res.message),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Simpan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLegalSheet({
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> sections,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.78,
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.mintSoft,
                  child: Icon(icon, size: 20, color: AppColors.darkGreen),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sections.map((sec) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sec['judul']!,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sec['isi']!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF4C6656),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text(
                  'Mengerti',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedWa = _formatNomorWa(UserAccountData.currentPhone);

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
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.darkGreen,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Pengaturan Akun',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGreen,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Keamanan Akun
              _buildSectionTitle('KEAMANAN AKUN'),
              _buildSettingGroup([
                _buildActionTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Ubah Kata Sandi',
                  subtitle: 'Perbarui kata sandi masuk akun Anda secara berkala',
                  onTap: _showChangePasswordDialog,
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFEDF5F0)),
                ListTile(
                  leading: const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.mintSoft,
                    child: Icon(
                      Icons.chat_rounded,
                      size: 18,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  title: const Text(
                    'WhatsApp Pemulihan Akun',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  subtitle: Text(
                    '$formattedWa • Digunakan untuk kode reset kata sandi otomatis',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 20),

              // Tentang & Hukum
              _buildSectionTitle('TENTANG & HUKUM'),
              _buildSettingGroup([
                _buildActionTile(
                  icon: Icons.shield_outlined,
                  title: 'Kebijakan Privasi',
                  subtitle: 'Perlindungan data pribadi pengguna TR4SH!',
                  onTap: () => _showLegalSheet(
                    title: 'Kebijakan Privasi',
                    icon: Icons.shield_outlined,
                    sections: const [
                      {
                        'judul': '1. Data yang Dikumpulkan',
                        'isi':
                            'TR4SH! menyimpan data akun berupa Nama Lengkap, Username, Nomor WhatsApp, Foto Profil, riwayat setor sampah, serta riwayat transaksi pembelian produk kreasi daur ulang.',
                      },
                      {
                        'judul': '2. Penggunaan Data',
                        'isi':
                            'Nomor WhatsApp digunakan khusus untuk pengiriman kode pemulihan kata sandi otomatis dan konfirmasi layanan. Data transaksi digunakan untuk memverifikasi status pembayaran melalui Midtrans dan pengambilan barang di Bank Sampah.',
                      },
                      {
                        'judul': '3. Keamanan Informasi',
                        'isi':
                            'Kata sandi Anda disimpan dalam bentuk terenkripsi (hash) di server kami dan tidak pernah dibagikan kepada pihak ketiga di luar kebutuhan pemrosesan pembayaran dan notifikasi sistem.',
                      },
                    ],
                  ),
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFEDF5F0)),
                _buildActionTile(
                  icon: Icons.article_outlined,
                  title: 'Syarat & Ketentuan Layanan',
                  subtitle: 'Aturan penggunaan platform TR4SH!',
                  onTap: () => _showLegalSheet(
                    title: 'Syarat & Ketentuan Layanan',
                    icon: Icons.article_outlined,
                    sections: const [
                      {
                        'judul': '1. Akun Pengguna',
                        'isi':
                            'Setiap pengguna bertanggung jawab atas kerahasiaan kata sandi dan keakuratan nomor WhatsApp yang didaftarkan. Username bersifat permanen dan tidak dapat dipindahtangankan.',
                      },
                      {
                        'judul': '2. Setor Sampah & Konten Edukasi',
                        'isi':
                            'Setoran sampah diverifikasi oleh petugas cabang Bank Sampah TR4SH. Konten edukasi yang diunggah pengguna akan melalui proses peninjauan admin sebelum tampil ke publik.',
                      },
                      {
                        'judul': '3. Transaksi & Pengambilan Produk',
                        'isi':
                            'Pembayaran produk memiliki batas waktu 15 menit sejak pesanan dibuat. Pesanan yang telah berstatus lunas diambil langsung di Bank Sampah Sahabat Ibu TR4SH dengan menunjukkan Nomor Order resmi.',
                      },
                    ],
                  ),
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFEDF5F0)),
                const ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.mintSoft,
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  title: Text(
                    'Versi Aplikasi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  subtitle: Text(
                    'TR4SH! Bank Sampah Digital • v1.0.0',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
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
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGreen,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFFB5C7BD),
        size: 20,
      ),
      onTap: onTap,
    );
  }
}