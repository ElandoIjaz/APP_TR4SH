import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/lokasi_service.dart';
import 'package:test23/pages/halaman_akun.dart';
import 'package:test23/pages/halaman_konten.dart';
import 'package:test23/pages/halaman_pilih_lokasi_akurat.dart';
import 'package:test23/pages/halaman_produk.dart';
import 'package:test23/pages/halaman_tracking.dart';
import 'package:test23/widgets/beranda/card_bank_sampah.dart';
import 'package:test23/widgets/beranda/card_riwayat_sampah.dart';
import 'package:test23/widgets/beranda/card_video_tutorial.dart';
import 'package:test23/widgets/beranda/card_workshop.dart';
import 'package:test23/widgets/beranda/grid_jenis_sampah.dart';
import 'package:test23/widgets/umum/bottom_nav_bar.dart';
import 'package:test23/widgets/umum/header_beranda.dart';

class HalamanBeranda extends StatefulWidget {
  const HalamanBeranda({super.key});

  @override
  State<HalamanBeranda> createState() => _HalamanBerandaState();
}

class _HalamanBerandaState extends State<HalamanBeranda> {
  int _currentNavIndex = 2; // Default to 'Beranda' (Index 2)
  bool _isBookmarked = false;

  void _showNotificationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifikasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildNotificationItem(
              icon: Icons.check_circle_rounded,
              iconColor: Colors.green,
              title: 'Penyetoran Sampah Berhasil!',
              desc: 'Setoran 4.2 kg botol plastik telah diverifikasi (+630 poin).',
              time: '10 menit yang lalu',
            ),
            _buildNotificationItem(
              icon: Icons.calendar_today_rounded,
              iconColor: AppColors.darkGreen,
              title: 'Pengingat Workshop',
              desc: 'Workshop "Kreasi Lilin Minyak" dimulai besok pukul 09.00 WIB.',
              time: '2 jam yang lalu',
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgScreen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2EFE7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: iconColor.withValues(alpha: 0.15),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkGreen),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSetorSampahModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
            const SizedBox(height: 14),
            const Text(
              'Setor Sampah Mandiri',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pilih jenis sampah yang ingin kamu tukarkan menjadi poin.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            _buildSetorItem(Icons.water_drop_outlined, 'Plastik (PET/HDPE)', 'Rp 3.500 / kg (+150 Poin)'),
            _buildSetorItem(Icons.inventory_2_outlined, 'Kertas & Karton', 'Rp 2.200 / kg (+100 Poin)'),
            _buildSetorItem(Icons.delete_outline_rounded, 'Logam & Kaleng', 'Rp 9.000 / kg (+300 Poin)'),
            _buildSetorItem(Icons.wine_bar_rounded, 'Kaca & Beling', 'Rp 1.000 / kg (+50 Poin)'),
            const SizedBox(height: 10),

            // Live Auto-Tracked GPS Pickup Location (Compact)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8F4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFDCEFE3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location_rounded, size: 14, color: Color(0xFF00C853)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Auto-Track GPS: ${LokasiTrackingService.currentAddress} (${LokasiTrackingService.currentAccuracy})',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.darkGreen),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HalamanPilihLokasiAkurat()),
                      );
                    },
                    child: const Text(
                      'GMaps >',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.limeAccent,
                  foregroundColor: AppColors.darkGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Jadwal penjemputan sampah berhasil dibuat ke ${LokasiTrackingService.currentAddress}!'),
                      backgroundColor: AppColors.darkGreen,
                    ),
                  );
                },
                child: const Text('Buat Jadwal Penjemputan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSetorItem(IconData icon, String title, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgScreen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCECE2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.mintSoft,
            child: Icon(icon, color: AppColors.darkGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkGreen)),
                Text(price, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }

  void _showVideoPlayerModal() {
    bool isPlaying = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
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
                // Video Screen Preview Box
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/waste_guide.jpg',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: AppColors.darkGreen,
                            child: const Center(
                              child: Icon(Icons.videocam_rounded, size: 60, color: Colors.white),
                            ),
                          );
                        },
                      ),
                      Container(
                        height: 200,
                        color: Colors.black.withValues(alpha: 0.35),
                      ),
                      GestureDetector(
                        onTap: () {
                          setModalState(() {
                            isPlaying = !isPlaying;
                          });
                        },
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.limeAccent,
                          child: Icon(
                            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 34,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('01:15 / 03:40', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                            Icon(Icons.fullscreen_rounded, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Panduan Pilah Sampah Rumah Tangga',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pelajari cara memilah sampah organik dan anorganik dari dapur rumah tangga Anda dengan metode 3R praktis untuk pemula.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.darkGreen,
                          side: const BorderSide(color: Color(0xFFD0E5D7)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          setState(() => _isBookmarked = !_isBookmarked);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_isBookmarked ? 'Video disimpan ke favorit' : 'Dihapus dari favorit'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: Icon(_isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
                        label: Text(_isBookmarked ? 'Tersimpan' : 'Simpan'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: const Text('Selesai Nonton'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCategoryDetail(String title, String badge, String subtitle, String description, IconData icon) {
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
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.mintSoft,
                  child: Icon(icon, color: AppColors.darkGreen, size: 26),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mintSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(description, style: const TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.5)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Mengerti & Kembali', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showWorkshopModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Pendaftaran Workshop', style: TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Kreasi Lilin dari Limbah Minyak',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.darkGreen),
            ),
            SizedBox(height: 8),
            Text('📅 Tanggal: Minggu, 27 September 2026\n⏰ Waktu: 09:00 - 12:00 WIB\n📍 Lokasi: Rumah Komunitas TR4SH!, Jakarta\n🎟 Kuota: Tersisa 8 Kursi',
                style: TextStyle(fontSize: 13, height: 1.5)),
            SizedBox(height: 12),
            Text('Biaya: GRATIS (Ditanggung Bank Sampah Digital)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.limeAccent,
              foregroundColor: AppColors.darkGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Selamat! Anda berhasil mendaftar workshop.'),
                  backgroundColor: AppColors.darkGreen,
                ),
              );
            },
            child: const Text('Konfirmasi Daftar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
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

              // ── 1. Top Header Bar & Greeting (HeaderBeranda) ──
              HeaderBeranda(
                onNotificationTap: _showNotificationSheet,
                onProfileTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HalamanAkun()),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ── 2. Hero Card: "Bank Sampah Digital" ──
              CardBankSampah(
                onMulaiSetorTap: _showSetorSampahModal,
              ),

              const SizedBox(height: 16),

              // ── 3. Card Riwayat Setor Sampah (Chart & Summary) ──
              const CardRiwayatSampah(),

              const SizedBox(height: 22),

              // ── 4. Cara Menabung Sampah (Video Tutorial) ──
              CardVideoTutorial(
                onPlayTap: _showVideoPlayerModal,
                onSeeAllTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Menampilkan semua tutorial menabung sampah...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),

              const SizedBox(height: 22),

              // ── 5. Kenali Jenis Sampah (2x2 Grid) ──
              GridJenisSampah(
                onCategoryTap: _showCategoryDetail,
              ),

              const SizedBox(height: 18),

              // ── 6. Workshop Card Banner ──
              CardWorkshop(
                onDaftarTap: _showWorkshopModal,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // ── 7. Bottom Navigation Bar ──
      bottomNavigationBar: TrashBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HalamanKonten()),
            );
          } else if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HalamanProduk()),
            );
          } else if (index == 4) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HalamanAkun()),
            );
          } else if (index == 3) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HalamanTracking()),
            );
          } else {
            setState(() {
              _currentNavIndex = index;
            });
            if (index != 2) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Menu index $index dipilih'),
                  duration: const Duration(milliseconds: 800),
                  backgroundColor: AppColors.darkGreen,
                ),
              );
            }
          }
        },
      ),
    );
  }
}
