import 'package:flutter/material.dart';
import 'package:test23/core/api_config.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/core/validators/konten_validator.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/akun/halaman_notifikasi.dart';
import 'package:test23/pages/auth/halaman_login.dart';
import 'package:test23/pages/beranda/halaman_peta_cabang.dart';
import 'package:test23/pages/konten/halaman_konten.dart';
import 'package:test23/pages/konten/halaman_upload_konten.dart';
import 'package:test23/pages/main_navigation.dart';
import 'package:test23/widgets/beranda/card_riwayat_sampah.dart';
import 'package:test23/widgets/beranda/card_video_tutorial.dart';
import 'package:test23/widgets/beranda/card_workshop.dart';
import 'package:test23/widgets/beranda/grid_jenis_sampah.dart';
import 'package:test23/widgets/umum/auth_required_modal.dart';
import 'package:test23/widgets/umum/tr4sh_brand_logo.dart';

class HalamanBeranda extends StatefulWidget {
  const HalamanBeranda({super.key});

  @override
  State<HalamanBeranda> createState() => _HalamanBerandaState();
}

class _HalamanBerandaState extends State<HalamanBeranda> {
  List<dynamic> _listEdukasi = [];
  bool _isLoadingEdukasi = true;
  List<dynamic> _listSampah = [];
  double _totalKg = 0.0;
  int _totalCount = 0;
  bool _adaBelumDibaca = false;

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
          message.isNotEmpty
              ? message
              : 'Akun Anda sedang diblokir atau dinonaktifkan oleh Administrator TR4SH.',
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
    _loadNotifikasiStatus();
  }

  Future<void> _loadNotifikasiStatus() async {
    final belumDibaca = await HalamanNotifikasi.hasUnreadNotifications();
    if (!mounted) return;
    setState(() => _adaBelumDibaca = belumDibaca);
  }

  Future<void> _navigateToNotifikasi() async {
    if (!UserAccountData.isLoggedIn) {
      AuthRequiredModal.show(
        context,
        title: 'Notifikasi Memerlukan Akun',
        message: 'Silakan masuk terlebih dahulu untuk melihat notifikasi Anda.',
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HalamanNotifikasi()),
    );
    _loadNotifikasiStatus();
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
        final totalKg = (dataMap['total_kg'] is num)
            ? (dataMap['total_kg'] as num).toDouble()
            : 0.0;
        final totalCount =
            (dataMap['total'] is int) ? (dataMap['total'] as int) : items.length;

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
      if (res.statusCode == 403 ||
          (res.data is Map && res.data['is_blocked'] == true)) {
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

  String? _getYoutubeThumbnail(String? url) =>
      KontenValidator.getYoutubeThumbnail(url);

  String? _resolveMediaImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;
    final trimmed = rawUrl.trim();
    final ytThumb = _getYoutubeThumbnail(trimmed);
    if (ytThumb != null && ytThumb.startsWith('http')) {
      return ytThumb;
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final base = ApiConfig.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    final cleanPath = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    return '$base/$cleanPath';
  }

  void _bukaHalamanKonten([Map<String, dynamic>? item]) {
    if (item == null) {
      MainNavigationPage.jumpToTab(context, 2);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HalamanKonten(
          initialSelectedKonten: item,
        ),
      ),
    );
  }

  void _navigateToTracking() {
    if (UserAccountData.isGuest) {
      AuthRequiredModal.show(
        context,
        title: 'Fitur Setor Sampah Memerlukan Akun',
        message:
            'Silakan masuk atau daftar akun terlebih dahulu untuk menyetor sampah daur ulang dan mengelola saldo uang Anda.',
        icon: Icons.recycling_rounded,
      );
      return;
    }
    MainNavigationPage.jumpToTab(context, 3);
  }

  void _navigateToMap() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HalamanPetaCabang()),
    );
  }

  void _navigateToUploadKonten() {
    if (UserAccountData.isGuest) {
      AuthRequiredModal.show(
        context,
        title: 'Upload Konten Memerlukan Akun',
        message:
            'Silakan masuk atau daftar akun terlebih dahulu untuk mengirimkan konten edukasi dan mendapatkan EcoPoints.',
        icon: Icons.video_collection_rounded,
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HalamanUploadKonten()),
    );
  }

  Widget _buildCustomCardBankSampah() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
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
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 14,
                      color: AppColors.limeAccent,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Bank Sampah Digital',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                      Icon(
                        Icons.map_rounded,
                        size: 13,
                        color: AppColors.darkGreen,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Cari Cabang',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Setor Sampah Jadi Berkah',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ubah limbah pilah harianmu menjadi tambahan saldo rupiah secara instan.',
            style: TextStyle(
              color: Color(0xFFB8D8C9),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.limeAccent,
              foregroundColor: AppColors.darkGreen,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: _navigateToTracking,
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: const Text(
              'Mulai Setor',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
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
              const Text(
                'Konten Edukasi Baru Terupload',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                ),
              ),
              InkWell(
                onTap: () => _bukaHalamanKonten(),
                child: const Text(
                  'Lihat Semua >',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E8850),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 165,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            itemCount: _listEdukasi.length,
            itemBuilder: (context, index) {
              final item = _listEdukasi[index];
              final itemMap = item is Map
                  ? Map<String, dynamic>.from(item)
                  : <String, dynamic>{};
              final title = itemMap['title']?.toString() ?? 'Konten Edukasi';
              final mediaUrl = itemMap['media_url']?.toString() ?? '';
              final isVideo = KontenValidator.extractYoutubeId(mediaUrl) != null ||
                  (itemMap['tipe_media']?.toString().toLowerCase().contains('video') ??
                      false);
              final imgUrl = _resolveMediaImageUrl(mediaUrl);

              return GestureDetector(
                onTap: () => _bukaHalamanKonten(itemMap),
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
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            imgUrl != null && imgUrl.startsWith('http')
                                ? Image.network(
                                    imgUrl,
                                    height: 105,
                                    width: 220,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 105,
                                      width: 220,
                                      color: AppColors.darkGreen,
                                      child: Icon(
                                        isVideo
                                            ? Icons.play_circle_outline
                                            : Icons.image_outlined,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 105,
                                    width: 220,
                                    color: AppColors.darkGreen,
                                    child: Icon(
                                      isVideo
                                          ? Icons.play_circle_outline
                                          : Icons.image_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                            if (isVideo)
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: AppColors.limeAccent,
                                  size: 22,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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

  Widget _buildBannerKontributorBawah() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TERTARIK JADI KONTRIBUTOR?',
            style: TextStyle(
              color: AppColors.limeAccent,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'KIRIM KONTEN ANDA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Jadilah Penggerak #PeduliSampah dan dapatkan EcoPoints untuk setiap karya sirkular terverifikasi.',
            style: TextStyle(
              color: Color(0xFFC8E0D4),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.limeAccent,
                foregroundColor: AppColors.darkGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: _navigateToUploadKonten,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Mulai Berbagi Ide',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryDetail(
    String title,
    String badge,
    String subtitle,
    String description,
    IconData icon,
  ) {
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13.5,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Mengerti & Kembali',
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
    final firstItem = _listEdukasi.isNotEmpty && _listEdukasi.first is Map
        ? Map<String, dynamic>.from(_listEdukasi.first as Map)
        : null;
    final firstUrl = firstItem?['media_url']?.toString();

    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              _loadBerandaEdukasi(),
              _loadRiwayatSampah(),
              _loadNotifikasiStatus(),
            ]);
          },
          color: AppColors.darkGreen,
          backgroundColor: AppColors.limeAccent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Tr4shBrandLogo(subtitle: 'HOME'),
                      Row(
                        children: [
                          Stack(
                            children: [
                              IconButton(
                                onPressed: _navigateToNotifikasi,
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: AppColors.darkGreen,
                                  size: 24,
                                ),
                              ),
                              if (_adaBelumDibaca)
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
                          GestureDetector(
                            onTap: () {
                              MainNavigationPage.jumpToTab(context, 4);
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
                  rawData: (UserAccountData.isGuest || UserAccountData.isNewAccount)
                      ? const []
                      : _listSampah,
                  totalWeight:
                      (UserAccountData.isGuest || UserAccountData.isNewAccount)
                          ? '0.0'
                          : (_totalKg > 0
                              ? _totalKg.toStringAsFixed(1)
                              : '14.8'),
                  trendBadge:
                      (UserAccountData.isGuest || UserAccountData.isNewAccount)
                          ? '+0 setoran'
                          : (_totalCount > 0
                              ? '+$_totalCount setoran'
                              : '+28% minggu ini'),
                ),
                const SizedBox(height: 22),
                CardVideoTutorial(
                  onPlayTap: () => _bukaHalamanKonten(firstItem),
                  onSeeAllTap: () => _bukaHalamanKonten(),
                  thumbnailUrl: _resolveMediaImageUrl(firstUrl),
                  title: firstItem?['title']?.toString() ??
                      'Panduan Pilah Sampah Rumah Tangga',
                  subtitle: firstItem?['description']?.toString() ??
                      'Langkah mudah memisahkan sampah organik & anorganik',
                ),
                if (_listEdukasi.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _buildKontenBaruEdukasiCarousel(),
                ],
                const SizedBox(height: 22),
                GridJenisSampah(onCategoryTap: _showCategoryDetail),
                const SizedBox(height: 18),
                const CardWorkshop(),
                const SizedBox(height: 18),
                _buildBannerKontributorBawah(),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}