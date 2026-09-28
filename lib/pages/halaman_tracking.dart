import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/pages/halaman_akun.dart';
import 'package:test23/pages/halaman_beranda.dart';
import 'package:test23/pages/halaman_konten.dart';
import 'package:test23/pages/halaman_produk.dart';
import 'package:test23/widgets/tracking/card_estimasi_berat.dart';
import 'package:test23/widgets/tracking/card_tracking_chart.dart';
import 'package:test23/widgets/tracking/grid_kategori_setor.dart';
import 'package:test23/widgets/umum/bottom_nav_bar.dart';
import 'package:test23/widgets/umum/header_beranda.dart';

class HalamanTracking extends StatefulWidget {
  const HalamanTracking({super.key});

  @override
  State<HalamanTracking> createState() => _HalamanTrackingState();
}

class _HalamanTrackingState extends State<HalamanTracking> {
  final int _currentNavIndex = 3; // Tracking is active (Index 3)

  String _selectedCategory = 'Plastik';
  String _selectedUnit = 'Botol';
  double _weightPerUnit = 0.1;
  int _pointsPerUnit = 10;

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
                  'Notifikasi Tracking',
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgScreen,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2EFE7)),
              ),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFD6F5E1),
                    child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Penyetoran 5 Botol Plastik telah masuk dalam riwayat tracking.',
                      style: TextStyle(fontSize: 12.5, color: AppColors.darkGreen),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  void _handleInputSampah(int count, double totalWeight, int totalPoints) {
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
              children: const [
                Icon(Icons.check_circle_rounded, color: Color(0xFF1E8850), size: 28),
                SizedBox(width: 10),
                Text(
                  'Sampah Berhasil Diinput!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Rincian: $count $_selectedUnit $_selectedCategory (±${totalWeight.toStringAsFixed(1)} kg)',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              'Potensi Poin yang diperoleh: +$totalPoints EcoPoints',
              style: const TextStyle(fontSize: 13, color: Color(0xFF266147), fontWeight: FontWeight.bold),
            ),
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
                child: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
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

              // ── 1. Top Header Bar (HeaderBeranda) ──
              HeaderBeranda(
                onNotificationTap: _showNotificationSheet,
                onProfileTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HalamanAkun()),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ── 2. Card 1: Riwayat Setor Sampah (Line Chart & Trend) ──
              CardTrackingChart(
                onCategoryFilterChanged: (filterName) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Filter $filterName dipilih'),
                      duration: const Duration(milliseconds: 600),
                      backgroundColor: AppColors.darkGreen,
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ── 3. Card 2: ESTIMASI JUMLAH / BERAT (Counter & Input) ──
              CardEstimasiBerat(
                categoryName: _selectedCategory,
                itemUnit: _selectedUnit,
                weightPerUnit: _weightPerUnit,
                pointsPerUnit: _pointsPerUnit,
                onInputSampah: _handleInputSampah,
              ),

              const SizedBox(height: 20),

              // ── 4. Section Kategori Sampah (2x2 Grid) ──
              GridKategoriSetor(
                onCategorySelected: (index, title, unit, weight, points) {
                  setState(() {
                    _selectedCategory = title;
                    _selectedUnit = unit;
                    _weightPerUnit = weight;
                    _pointsPerUnit = points;
                  });
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // ── 5. Bottom Navigation Bar ──
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
          } else if (index == 4) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HalamanAkun()),
            );
          } else if (index != 3) {
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
