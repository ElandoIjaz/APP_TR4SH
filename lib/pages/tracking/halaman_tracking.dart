import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/data/lokasi_service.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/akun/halaman_akun.dart';
import 'package:test23/pages/auth/halaman_login.dart';
import 'package:test23/pages/beranda/halaman_beranda.dart';
import 'package:test23/pages/konten/halaman_konten.dart';
import 'package:test23/pages/produk/halaman_produk.dart';
import 'package:test23/widgets/tracking/card_auto_track_lokasi.dart';
import 'package:test23/widgets/tracking/card_estimasi_berat.dart';
import 'package:test23/widgets/tracking/card_tracking_chart.dart';
import 'package:test23/widgets/tracking/grid_kategori_setor.dart';
import 'package:test23/widgets/umum/auth_required_modal.dart';
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

  // Real-time backend state
  bool _isLoading = true;
  List<dynamic> _listSampah = [];
  double _totalKg = 0.0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadRiwayatSampah();
  }

  Future<void> _loadRiwayatSampah() async {
    try {
      final res = await ApiService.fetchRiwayatSetor();
      if (res.success && res.data is Map && mounted) {
        final dataMap = res.data as Map;
        final items = (dataMap['items'] is List) ? (dataMap['items'] as List) : [];
        final totalKg = (dataMap['total_kg'] is num) ? (dataMap['total_kg'] as num).toDouble() : 0.0;
        final totalCount = (dataMap['total'] is int) ? (dataMap['total'] as int) : items.length;

        setState(() {
          _listSampah = items;
          _totalKg = totalKg;
          _totalCount = totalCount;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (UserAccountData.isNewAccount) {
          _totalKg = 0.0;
          _totalCount = 0;
          _listSampah = [];
        } else if (UserAccountData.totalSampahKg > 0) {
          _totalKg = UserAccountData.totalSampahKg;
        }
      });
    }
  }

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
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFD6F5E1),
                    child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _listSampah.isNotEmpty
                          ? 'Terdapat ${_listSampah.length} setoran sampah tercatat aktif di server database.'
                          : 'Penyetoran 5 Botol Plastik telah masuk dalam riwayat tracking.',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.darkGreen),
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

  void _handleInputSampah(int count, double totalWeight, int totalPoints) async {
    if (UserAccountData.isGuest) {
      AuthRequiredModal.show(
        context,
        title: 'Input Sampah Memerlukan Akun',
        message: 'Mode Tamu tidak dapat melakukan tracking sampah. Silakan masuk atau buat akun terlebih dahulu untuk mencatat data setoran ke database.',
        icon: Icons.recycling_rounded,
      );
      return;
    }

    // 1. Tentukan kategori ID untuk database Laravel (1: Plastik, 2: Kertas, 3: Logam, 4: Kaca, 5: Organik)
    int idKategori = 1;
    final catLower = _selectedCategory.toLowerCase();
    if (catLower.contains('kertas')) {
      idKategori = 2;
    } else if (catLower.contains('logam') || catLower.contains('kaleng')) {
      idKategori = 3;
    } else if (catLower.contains('kaca') || catLower.contains('beling')) {
      idKategori = 4;
    } else if (catLower.contains('organik')) {
      idKategori = 5;
    }

    final double beratHitung = totalWeight > 0 ? totalWeight : (count * _weightPerUnit);
    final double beratFinal = double.parse((beratHitung > 0 ? beratHitung : 0.1).toStringAsFixed(2));

    // 2. Kirim request asynchronous ke API backend Laravel (/api/sampah/setor)
    final res = await ApiService.kirimSetorSampah(
      idUser: UserAccountData.currentUserId ?? 1,
      idKategori: idKategori,
      jenisSampah: '$count $_selectedUnit $_selectedCategory',
      jumlah: beratFinal,
      satuan: 'kg',
      keterangan: 'Auto-Track Titik Jemput: ${LokasiTrackingService.currentAddress}',
    );

    // 3. Update state lokal dan muat ulang riwayat dari database
    if (res.success) {
      UserAccountData.userPoints += totalPoints;
      _loadRiwayatSampah();
    }

    if (!mounted) return;

    // 4. Tampilkan bottom sheet konfirmasi sukses
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
            const SizedBox(height: 8),

            // Server database status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: res.success ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: res.success ? const Color(0xFFC8E6C9) : const Color(0xFFFFE0B2)),
              ),
              child: Row(
                children: [
                  Icon(
                    res.success ? Icons.cloud_done_rounded : Icons.info_outline_rounded,
                    size: 14,
                    color: res.success ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      res.success
                          ? 'Tersimpan di Database Laravel TR4SH (ID: #${res.data != null && res.data['id_sampah'] != null ? res.data['id_sampah'] : 'OK'})'
                          : 'Mode offline: ${res.message}',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: res.success ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8F4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDCEFE3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location_rounded, size: 16, color: Color(0xFF00C853)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Auto-Track Titik Jemput: ${LokasiTrackingService.currentAddress}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF235E40)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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

  String _formatDate(dynamic rawDate) {
    if (rawDate == null) return 'Baru saja';
    try {
      final dt = DateTime.parse(rawDate.toString()).toLocal();
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB';
    } catch (_) {
      return rawDate.toString();
    }
  }

  IconData _getKategoriIcon(dynamic kategoriName) {
    final name = (kategoriName ?? '').toString().toLowerCase();
    if (name.contains('plastik')) return Icons.water_drop_outlined;
    if (name.contains('kertas')) return Icons.inventory_2_outlined;
    if (name.contains('logam') || name.contains('kaleng')) return Icons.delete_outline_rounded;
    if (name.contains('kaca') || name.contains('beling')) return Icons.wine_bar_rounded;
    return Icons.eco_rounded;
  }

  Color _getKategoriColor(dynamic kategoriName) {
    final name = (kategoriName ?? '').toString().toLowerCase();
    if (name.contains('plastik')) return const Color(0xFF1E8850);
    if (name.contains('kertas')) return const Color(0xFFE65100);
    if (name.contains('logam') || name.contains('kaleng')) return const Color(0xFF0D47A1);
    if (name.contains('kaca') || name.contains('beling')) return const Color(0xFF7B1FA2);
    return AppColors.darkGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadRiwayatSampah,
          color: AppColors.darkGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 14),

                // ── 1. Top Header Bar (HeaderBeranda) ──
                HeaderBeranda(
                  userName: UserAccountData.isGuest
                      ? 'Tamu'
                      : (UserAccountData.currentNama.isNotEmpty
                          ? UserAccountData.currentNama.split(' ').first
                          : 'Bintang'),
                  onNotificationTap: _showNotificationSheet,
                  onProfileTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HalamanAkun()),
                    );
                  },
                ),

                if (UserAccountData.isGuest) ...[
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFEEBA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline_rounded, color: Color(0xFF856404), size: 22),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mode Tamu: Tracking Terkunci',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF856404)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Masuk ke akun Anda untuk mencatat setoran dan mengumpulkan poin.',
                                style: TextStyle(fontSize: 11, color: Color(0xFF856404)),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.darkGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const HalamanLogin()));
                          },
                          child: const Text('Masuk', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // ── 2. Card: Auto-Track Lokasi Penjemputan Sampah ──
                CardAutoTrackLokasi(
                  onLocationUpdated: () => setState(() {}),
                ),

                const SizedBox(height: 16),

                // ── 3. Card 1: Riwayat Setor Sampah (Line Chart & Trend dari Database) ──
                CardTrackingChart(
                  totalDisetor: UserAccountData.isNewAccount
                      ? '${_totalKg.toStringAsFixed(1)} kg'
                      : '${_totalKg > 0 ? _totalKg.toStringAsFixed(1) : '14.8'} kg',
                  trendPercent: UserAccountData.isNewAccount
                      ? '+$_totalCount setoran'
                      : (_totalCount > 0 ? '+$_totalCount setoran tercatat' : '+28% dari minggu lalu'),
                  rawData: _listSampah,
                ),

                const SizedBox(height: 16),

                // ── 4. Card 2: ESTIMASI JUMLAH / BERAT (Counter & Input ke Database) ──
                CardEstimasiBerat(
                  categoryName: _selectedCategory,
                  itemUnit: _selectedUnit,
                  weightPerUnit: _weightPerUnit,
                  pointsPerUnit: _pointsPerUnit,
                  onInputSampah: _handleInputSampah,
                ),

                const SizedBox(height: 20),

                // ── 5. Section Kategori Sampah (2x2 Grid) ──
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

                const SizedBox(height: 20),

                // ── 6. Section: Data Setoran Masuk Terkini (Real-Time Database Laravel) ──
                _buildSectionDataMasuk(),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),

      // ── 7. Bottom Navigation Bar ──
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

  Widget _buildSectionDataMasuk() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6F3DD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.storage_rounded, size: 16, color: AppColors.darkGreen),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Data Setoran Masuk (${_listSampah.length})',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircleAvatar(radius: 3.5, backgroundColor: Color(0xFF00C853)),
                    SizedBox(width: 5),
                    Text(
                      'Database Live',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E8850),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Catatan data sampah yang benar-benar tersimpan di server Laravel TR4SH',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),

          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.darkGreen),
                ),
              ),
            )
          else if (_listSampah.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 36, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  const Text(
                    'Belum Ada Setoran Masuk di Database',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tekan tombol "+ Input Sampah" di atas untuk menyetor dan data Anda akan langsung tersimpan di database.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _listSampah.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _listSampah[index] as Map<String, dynamic>;
                final namaKategori = item['nama_kategori']?.toString() ?? 'Sampah';
                final jenisSampah = item['jenis_sampah']?.toString() ?? 'Setoran';
                final jumlah = item['jumlah']?.toString() ?? '0';
                final satuan = item['satuan']?.toString() ?? 'kg';
                final tgl = _formatDate(item['created_at']);
                final ket = item['keterangan']?.toString() ?? '';
                final catColor = _getKategoriColor(namaKategori);

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon Kategori Avatar
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getKategoriIcon(namaKategori),
                          color: catColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Informasi Setoran
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    jenisSampah,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.mintSoft,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$jumlah $satuan',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.darkGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: catColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    namaKategori,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: catColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  tgl,
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            if (ket.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.place_outlined, size: 12, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      ket,
                                      style: TextStyle(fontSize: 10.5, color: Colors.grey.shade700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
