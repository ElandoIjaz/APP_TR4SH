import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/core/validators/konten_validator.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/akun/halaman_akun.dart';
import 'package:test23/pages/auth/halaman_login.dart';
import 'package:test23/pages/beranda/halaman_peta_cabang.dart';
import 'package:test23/pages/konten/halaman_konten.dart';
import 'package:test23/pages/produk/halaman_produk.dart';
import 'package:test23/pages/tracking/halaman_tracking.dart';
import 'package:test23/widgets/beranda/card_riwayat_sampah.dart';
import 'package:test23/widgets/beranda/card_video_tutorial.dart';
import 'package:test23/widgets/beranda/card_workshop.dart';
import 'package:test23/widgets/beranda/grid_jenis_sampah.dart';
import 'package:test23/widgets/umum/auth_required_modal.dart';
import 'package:test23/widgets/umum/bottom_nav_bar.dart';

class HalamanBeranda extends StatefulWidget {
  const HalamanBeranda({super.key});

  @override
  State<HalamanBeranda> createState() => _HalamanBerandaState();
}

class _HalamanBerandaState extends State<HalamanBeranda> {
  int _currentNavIndex = 0;
  List<dynamic> _listEdukasi = [];
  bool _isLoadingEdukasi = true;
  List<dynamic> _listSampah = [];
  double _totalKg = 0.0;
  int _totalCount = 0;

  void _showAccountBlockedDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.block_rounded, color: Colors.redAccent, size: 28),
            SizedBox(width: 10),
            Text(
              'Akun Dinonaktifkan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B4632),
              ),
            ),
          ],
        ),
        content: Text(
          message.isNotEmpty ? message : 'Akun Anda sedang diblokir atau dinonaktifkan oleh Administrator TR4SH.',
          style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HalamanLogin()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Ke Halaman Login', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadBerandaEdukasi();
    _loadRiwayatSampah();
  }

  Future<void> _loadRiwayatSampah() async {
    if (UserAccountData.isGuest || UserAccountData.isNewAccount) {
      if (mounted) {
        setState(() {
          _listSampah = [];
          _totalKg = 0.0;
          _totalCount = 0;
        });
      }
      return;
    }

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
        });
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        if (UserAccountData.isNewAccount || UserAccountData.isGuest) {
          _totalKg = 0.0;
          _totalCount = 0;
          _listSampah = [];
        } else {
          _totalKg = UserAccountData.totalSampahKg;
          _totalCount = UserAccountData.totalSetoran;
        }
      });
    }
  }

  Future<void> _loadBerandaEdukasi() async {
    try {
      final res = await ApiService.fetchBeranda();
      if (res.statusCode == 403 || (res.data is Map && res.data['is_blocked'] == true)) {
        if (mounted) _showAccountBlockedDialog(res.message);
        return;
      }
      if (res.success && res.data is Map && res.data['edukasi_terbaru'] is List) {
        final list = res.data['edukasi_terbaru'] as List;
        if (mounted) {
          setState(() {
            _listEdukasi = list;
            _isLoadingEdukasi = false;
          });
          return;
        }
      }
      final edukasiRes = await ApiService.fetchEdukasi();
      if (edukasiRes.success && edukasiRes.data is List && mounted) {
        setState(() {
          _listEdukasi = edukasiRes.data as List;
          _isLoadingEdukasi = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingEdukasi = false);
  }

  String? _getYoutubeThumbnail(String? url) => KontenValidator.getYoutubeThumbnail(url);

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
                const Text('Notifikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 12),
            _buildNotificationItem(
              icon: Icons.check_circle_rounded,
              iconColor: Colors.green,
              title: 'Penyetoran Sampah Berhasil!',
              desc: 'Setoran 4.2 kg botol plastik telah diverifikasi (+Rp 14.700).',
              time: '10 menit yang lalu',
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkGreen)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToTracking() {
    if (UserAccountData.isGuest) {
      AuthRequiredModal.show(
        context,
        title: 'Fitur Setor Sampah Memerlukan Akun',
        message: 'Silakan masuk atau daftar akun terlebih dahulu untuk menyetor sampah daur ulang dan mengelola saldo uang Anda.',
        icon: Icons.recycling_rounded,
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HalamanTracking()));
  }

  void _navigateToMap() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HalamanPetaCabang()));
  }

  Widget _buildCustomCardBankSampah() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_balance_wallet_rounded, size: 14, color: AppColors.limeAccent),
                    SizedBox(width: 6),
                    Text('Bank Sampah Digital', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              InkWell(
                onTap: _navigateToMap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.limeAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map_rounded, size: 13, color: AppColors.darkGreen),
                      SizedBox(width: 4),
                      Text('Cari Cabang', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Setor Sampah Jadi Berkah',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ubah limbah pilah harianmu menjadi tambahan saldo rupiah secara instan.',
            style: TextStyle(color: Color(0xFFB8D8C9), fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.limeAccent,
              foregroundColor: AppColors.darkGreen,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: _navigateToTracking,
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: const Text('Mulai Setor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showVideoPlayerModal([Map<String, dynamic>? item]) {
    final isDynamic = item != null;
    final title = isDynamic ? (item['title']?.toString() ?? 'Panduan Pilah Sampah Rumah Tangga') : 'Panduan Pilah Sampah Rumah Tangga';
    final desc = isDynamic ? (item['description']?.toString() ?? 'Pelajari cara memilah sampah organik dan anorganik.') : 'Pelajari cara memilah sampah organik dan anorganik.';

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
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                const SizedBox(height: 6),
                Text(desc, style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4)),
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
                    child: const Text('Selesai Nonton', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKontenBaruEdukasiCarousel() {
    if (_isLoadingEdukasi) return const SizedBox.shrink();
    if (_listEdukasi.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Konten Edukasi Baru Terupload', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
              InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HalamanKonten())),
                child: const Text('Lihat Semua >', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1E8850))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 185,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            itemCount: _listEdukasi.length,
            itemBuilder: (context, index) {
              final item = _listEdukasi[index];
              final itemMap = item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{};
              final title = itemMap['title']?.toString() ?? 'Video Edukasi';
              final author = itemMap['penulis']?.toString() ?? 'Komunitas TR4SH';
              final mediaUrl = itemMap['media_url']?.toString() ?? '';
              final thumb = _getYoutubeThumbnail(mediaUrl);

              return GestureDetector(
                onTap: () => _showVideoPlayerModal(itemMap),
                child: Container(
                  width: 220,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: thumb != null && thumb.startsWith('http')
                            ? Image.network(thumb, height: 105, width: 220, fit: BoxFit.cover)
                            : Container(height: 105, width: 220, color: AppColors.darkGreen, child: const Icon(Icons.play_circle_outline, color: Colors.white)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkGreen), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 3),
                            Text('Oleh: $author', style: const TextStyle(fontSize: 11, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(radius: 24, backgroundColor: AppColors.mintSoft, child: Icon(icon, color: AppColors.darkGreen, size: 26)),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  ],
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
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () => Navigator.pop(context),
                child: const Text('Mengerti & Kembali', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
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
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kreasi Lilin dari Limbah Minyak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.darkGreen)),
            SizedBox(height: 8),
            Text('• Tanggal: Minggu, 27 September 2026\n• Waktu: 09:00 - 12:00 WIB\n• Lokasi: Rumah Komunitas TR4SH!, Jakarta\n• Kuota: Tersisa 8 Kursi', style: TextStyle(fontSize: 13, height: 1.5)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.limeAccent, foregroundColor: AppColors.darkGreen),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil mendaftar workshop!')));
            },
            child: const Text('Konfirmasi'),
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
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([_loadBerandaEdukasi(), _loadRiwayatSampah()]);
          },
          color: AppColors.darkGreen,
          backgroundColor: AppColors.limeAccent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 14),

                // ========================================================
                // HEADER BARU: TR4SH! HOME (TANPA KERANJANG BELANJA)
                // ========================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo & Judul TR4SH! HOME
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.darkGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.eco_rounded,
                                color: AppColors.limeAccent,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TR4SH!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.darkGreen,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'HOME',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textMuted,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Ikon Aksi Kanan (Notifikasi & Profil Saja)
                      Row(
                        children: [
                          // Tombol Notifikasi
                          Stack(
                            children: [
                              IconButton(
                                onPressed: _showNotificationSheet,
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: AppColors.darkGreen,
                                  size: 24,
                                ),
                              ),
                              Positioned(
                                right: 10,
                                top: 10,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.amber,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),

                          // Tombol Akun / Profil
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const HalamanAkun()),
                              );
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD6F3DD),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: AppColors.darkGreen,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                _buildCustomCardBankSampah(),
                const SizedBox(height: 16),
                CardRiwayatSampah(
                  rawData: (UserAccountData.isGuest || UserAccountData.isNewAccount) ? const [] : _listSampah,
                  totalWeight: (UserAccountData.isGuest || UserAccountData.isNewAccount) ? '0.0' : (_totalKg > 0 ? _totalKg.toStringAsFixed(1) : '14.8'),
                  trendBadge: (UserAccountData.isGuest || UserAccountData.isNewAccount) ? '+0 setoran' : (_totalCount > 0 ? '+$_totalCount setoran' : '+28% minggu ini'),
                ),
                const SizedBox(height: 22),
                CardVideoTutorial(
                  onPlayTap: () => _showVideoPlayerModal(_listEdukasi.isNotEmpty ? Map<String, dynamic>.from(_listEdukasi.first) : null),
                  onSeeAllTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HalamanKonten())),
                  thumbnailUrl: _listEdukasi.isNotEmpty ? _getYoutubeThumbnail(_listEdukasi.first['media_url']?.toString()) : null,
                  title: _listEdukasi.isNotEmpty && _listEdukasi.first['title'] != null ? _listEdukasi.first['title'].toString() : 'Panduan Pilah Sampah Rumah Tangga',
                  subtitle: 'Langkah mudah memisahkan sampah organik & anorganik',
                ),
                if (_listEdukasi.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _buildKontenBaruEdukasiCarousel(),
                ],
                const SizedBox(height: 22),
                GridJenisSampah(onCategoryTap: _showCategoryDetail),
                const SizedBox(height: 18),
                CardWorkshop(onDaftarTap: _showWorkshopModal),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: TrashBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 2) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HalamanKonten()));
          } else if (index == 1) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HalamanProduk()));
          } else if (index == 4) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HalamanAkun()));
          } else if (index == 3) {
            if (UserAccountData.isGuest) {
              AuthRequiredModal.show(
                context,
                title: 'Fitur Tracking Sampah Memerlukan Akun',
                message: 'Pelacakan sampah daur ulang, grafik analitik, dan perolehan saldo uang hanya dapat digunakan setelah Anda masuk.',
                icon: Icons.query_stats_rounded,
              );
              return;
            }
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HalamanTracking()));
          } else {
            setState(() => _currentNavIndex = index);
          }
        },
      ),
    );
  }
}