import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/pages/halaman_beranda.dart';
import 'package:test23/pages/halaman_konten.dart';
import 'package:test23/pages/halaman_login.dart';
import 'package:test23/pages/halaman_produk.dart';
import 'package:test23/pages/halaman_tracking.dart';
import 'package:test23/widgets/akun/banner_dampak_positif.dart';
import 'package:test23/widgets/akun/card_menu_akun.dart';
import 'package:test23/widgets/akun/card_profil_user.dart';
import 'package:test23/widgets/akun/card_statistik_akun.dart';
import 'package:test23/widgets/akun/header_akun.dart';
import 'package:test23/widgets/akun/tombol_keluar.dart';
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
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: userCtrl,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
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
                    setState(() {
                      _namaLengkap = nameCtrl.text.trim();
                      _username = userCtrl.text.trim();
                      _nomorTelepon = phoneCtrl.text.trim();
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
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
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
                onNotificationTap: () => _showMenuDetail(
                  'Notifikasi',
                  'Tidak ada notifikasi baru saat ini. Semua setoran sampah Anda telah diproses.',
                ),
                onSettingsTap: () => _showMenuDetail(
                  'Pengaturan Aplikasi',
                  'Pengaturan preferensi bahasa, notifikasi push, dan keamanan akun Anda.',
                ),
              ),

              const SizedBox(height: 16),

              // ── 2. User Profile Card (CardProfilUser) ──
              CardProfilUser(
                name: _namaLengkap,
                username: _username,
                onEditTap: _showEditProfileModal,
              ),

              const SizedBox(height: 16),

              // ── 3. Stats / Metrics Card (CardStatistikAkun) ──
              const CardStatistikAkun(),

              const SizedBox(height: 16),

              // ── 4. Dampak Positifmu Banner (BannerDampakPositif) ──
              const BannerDampakPositif(),

              const SizedBox(height: 16),

              // ── 5. Menu List Card (CardMenuAkun) ──
              CardMenuAkun(
                onMenuTap: (menuTitle) {
                  _showMenuDetail(
                    menuTitle,
                    'Informasi detail dan pengaturan untuk menu $menuTitle.',
                  );
                },
              ),

              const SizedBox(height: 18),

              // ── 6. Tombol Keluar (TombolKeluar) ──
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
              MaterialPageRoute(builder: (_) => const HalamanKonten()),
            );
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HalamanProduk()),
            );
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HalamanBeranda()),
            );
          } else if (index == 3) {
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
