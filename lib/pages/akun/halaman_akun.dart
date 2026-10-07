import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/core/validators/auth_validator.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/akun/halaman_alamat_pengiriman.dart';
import 'package:test23/pages/akun/halaman_bantuan_faq.dart';
import 'package:test23/pages/beranda/halaman_beranda.dart';
import 'package:test23/pages/konten/halaman_konten.dart';
import 'package:test23/pages/konten/halaman_upload_konten.dart';
import 'package:test23/pages/auth/halaman_login.dart';
import 'package:test23/pages/akun/halaman_notifikasi.dart';
import 'package:test23/pages/akun/halaman_pengaturan_akun.dart';
import 'package:test23/pages/akun/halaman_poin_hadiah.dart';
import 'package:test23/pages/produk/halaman_produk.dart';
import 'package:test23/pages/akun/halaman_riwayat_setor.dart';
import 'package:test23/pages/akun/halaman_riwayat_transaksi.dart';
import 'package:test23/pages/tracking/halaman_tracking.dart';
import 'package:test23/widgets/akun/banner_dampak_positif.dart';
import 'package:test23/widgets/akun/card_menu_akun.dart';
import 'package:test23/widgets/akun/card_profil_user.dart';
import 'package:test23/widgets/akun/card_statistik_akun.dart';
import 'package:test23/widgets/akun/header_akun.dart';
import 'package:test23/widgets/akun/tombol_keluar.dart';
import 'package:test23/widgets/umum/auth_required_modal.dart';
import 'package:test23/widgets/umum/bottom_nav_bar.dart';

class HalamanAkun extends StatefulWidget {
  const HalamanAkun({super.key});

  @override
  State<HalamanAkun> createState() => _HalamanAkunState();
}

class _HalamanAkunState extends State<HalamanAkun> {
  final int _currentNavIndex = 4; // Akun is active (Index 4)

  // User state
  String _namaLengkap = 'Bintang Pratama';
  String _username = '@bintang_eco';
  String _nomorTelepon = '081234567890';

  @override
  void initState() {
    super.initState();
    if (UserAccountData.isGuest) {
      _namaLengkap = 'Tamu';
      _username = '@tamu_eco';
    } else {
      if (UserAccountData.currentNama.isNotEmpty) {
        _namaLengkap = UserAccountData.currentNama;
      }
      if (UserAccountData.currentUsername.isNotEmpty) {
        _username = UserAccountData.currentUsername.startsWith('@')
            ? UserAccountData.currentUsername
            : '@${UserAccountData.currentUsername}';
      }
    }
  }

  void _showEditProfileModal() {
    final nameCtrl = TextEditingController(text: _namaLengkap);
    final userCtrl = TextEditingController(text: _username);
    final phoneCtrl = TextEditingController(text: _nomorTelepon);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
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
              const Text(
                'Edit Profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                  LengthLimitingTextInputFormatter(60),
                ],
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap (huruf saja)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: userCtrl,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                  LengthLimitingTextInputFormatter(30),
                ],
                decoration: InputDecoration(
                  labelText: 'Username (huruf saja)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 13,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ],
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon (11-13 digit)',
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.limeAccent,
                    foregroundColor: AppColors.darkGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    final cleanPhone = phoneCtrl.text.trim();
                    final hpError = AuthValidator.validateNomorHp(cleanPhone);
                    if (hpError != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(hpError),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _namaLengkap = nameCtrl.text.trim();
                      _username = userCtrl.text.trim();
                      _nomorTelepon = cleanPhone;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profil berhasil diperbarui!'),
                        backgroundColor: AppColors.darkGreen,
                      ),
                    );
                  },
                  child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Konfirmasi Keluar',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkGreen),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun TR4SH!?',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final navigator = Navigator.of(context);
              navigator.pop();
              await ApiService.logout();
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HalamanLogin()),
                (route) => false,
              );
            },
            child: const Text('Ya, Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showMenuDetail(String title, String description) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 14),

              // ── 1. Header (HeaderAkun) ──
              HeaderAkun(
                onNotificationTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HalamanNotifikasi()),
                  );
                },
                onSettingsTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HalamanPengaturanAkun()),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ── 2. User Profile Card (CardProfilUser) ──
              CardProfilUser(
                name: _namaLengkap,
                username: _username,
                status: UserAccountData.isGuest ? 'Mode Eksplorasi' : 'Anggota Aktif',
                isGuest: UserAccountData.isGuest,
                isVerified: !UserAccountData.isGuest,
                avatarAsset: UserAccountData.isGuest ? null : UserAccountData.currentFoto,
                onEditTap: () {
                  if (UserAccountData.isGuest) {
                    AuthRequiredModal.show(
                      context,
                      title: 'Masuk ke Akun',
                      message: 'Mode Tamu tidak dapat mengubah profil. Silakan masuk atau buat akun terlebih dahulu.',
                    );
                  } else {
                    _showEditProfileModal();
                  }
                },
              ),

              const SizedBox(height: 16),

              // ── 3. Stats / Metrics Card (CardStatistikAkun) ──
              CardStatistikAkun(
                sampahTerkumpul: (UserAccountData.isNewAccount || UserAccountData.isGuest)
                    ? '0.0 kg'
                    : (UserAccountData.totalSampahKg > 0
                        ? '${UserAccountData.totalSampahKg.toStringAsFixed(1)} kg'
                        : '12.5 kg'),
                poinHijau: (UserAccountData.isNewAccount || UserAccountData.isGuest) ? '0 Poin' : '5 Poin',
                misiSelesai: (UserAccountData.isNewAccount || UserAccountData.isGuest)
                    ? '0 Misi'
                    : '${UserAccountData.totalMisiSelesai > 0 ? UserAccountData.totalMisiSelesai : 3} Misi',
              ),

              const SizedBox(height: 16),

              // ── 4. Dampak Positifmu Banner (BannerDampakPositif) ──
              BannerDampakPositif(
                sampahDikurangi: (UserAccountData.isNewAccount || UserAccountData.isGuest)
                    ? 'Total 0.0 kg sampah berhasil dikurangi dari TPA'
                    : (UserAccountData.totalSampahKg > 0
                        ? 'Total ${UserAccountData.totalSampahKg.toStringAsFixed(1)} kg sampah berhasil dikurangi dari TPA'
                        : 'Total 12.5 kg sampah berhasil dikurangi dari TPA'),
                reduksiCO2: (UserAccountData.isNewAccount || UserAccountData.isGuest)
                    ? 'Setara 0.0 kg reduksi CO2e'
                    : (UserAccountData.totalSampahKg > 0
                        ? 'Setara ${(UserAccountData.totalSampahKg * 1.45).toStringAsFixed(1)} kg reduksi CO2e'
                        : 'Setara 18.2 kg reduksi CO2e'),
              ),

              const SizedBox(height: 16),

              // ── 5. Menu List Card (CardMenuAkun) ──
              CardMenuAkun(
                poinReward: (UserAccountData.isNewAccount || UserAccountData.isGuest)
                    ? '${UserAccountData.userPoints} Pts'
                    : '500 Pts',
                onMenuTap: (menuTitle) {
                  if (UserAccountData.isGuest &&
                      (menuTitle == 'Riwayat Transaksi' ||
                          menuTitle == 'Riwayat Setor Sampah' ||
                          menuTitle == 'Konten Edukasi Saya' ||
                          menuTitle == 'Poin & Hadiah' ||
                          menuTitle == 'Alamat Pengiriman' ||
                          menuTitle == 'Pengaturan Akun')) {
                    AuthRequiredModal.show(
                      context,
                      title: '$menuTitle Memerlukan Akun',
                      message: 'Silakan masuk atau daftar akun terlebih dahulu untuk mengakses menu $menuTitle.',
                    );
                    return;
                  }

                  if (menuTitle == 'Riwayat Transaksi') {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HalamanRiwayatTransaksi()),
                    );
                  } else if (menuTitle == 'Riwayat Setor Sampah') {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HalamanRiwayatSetor()),
                    );
                  } else if (menuTitle == 'Konten Edukasi Saya') {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HalamanUploadKonten()),
                    );
                  } else if (menuTitle == 'Poin & Hadiah') {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HalamanPoinHadiah()),
                    );
                  } else if (menuTitle == 'Alamat Pengiriman') {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HalamanAlamatPengiriman()),
                    );
                  } else if (menuTitle == 'Notifikasi') {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HalamanNotifikasi()),
                    );
                  } else if (menuTitle == 'Bantuan & FAQ') {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HalamanBantuanFaq()),
                    );
                  } else if (menuTitle == 'Pengaturan Akun') {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HalamanPengaturanAkun()),
                    );
                  } else {
                    _showMenuDetail(
                      menuTitle,
                      'Informasi detail dan pengaturan untuk menu $menuTitle.',
                    );
                  }
                },
              ),

              const SizedBox(height: 18),

              // ── 6. Tombol Masuk (Tamu) / Keluar (Member) ──
              if (UserAccountData.isGuest)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const HalamanLogin()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.login_rounded, size: 20),
                      label: const Text(
                        'Masuk / Buat Akun Baru',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                )
              else
                TombolKeluar(
                  onLogoutTap: _showLogoutDialog,
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // ── 7. Bottom Navigation Bar (TrashBottomNav) ──
      bottomNavigationBar: TrashBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HalamanBeranda()),
            );
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HalamanProduk()),
            );
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HalamanKonten()),
            );
          } else if (index == 3) {
            if (UserAccountData.isGuest) {
              AuthRequiredModal.show(
                context,
                title: 'Fitur Tracking Sampah Memerlukan Akun',
                message: 'Pelacakan sampah daur ulang, grafik analitik, dan perolehan poin hanya dapat digunakan setelah Anda masuk atau membuat akun.',
                icon: Icons.query_stats_rounded,
              );
              return;
            }
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HalamanTracking()),
            );
          } else if (index != 4) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Menu index $index dipilih'),
                duration: const Duration(milliseconds: 800),
                backgroundColor: AppColors.darkGreen,
              ),
            );
          }
        },
      ),
    );
  }
}
