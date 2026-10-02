import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/core/validators/konten_validator.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/pages/akun/halaman_akun.dart';
import 'package:test23/pages/beranda/halaman_beranda.dart';
import 'package:test23/pages/konten/halaman_upload_konten.dart';
import 'package:test23/pages/produk/halaman_produk.dart';
import 'package:test23/pages/tracking/halaman_tracking.dart';
import 'package:test23/widgets/konten/banner_kontributor_konten.dart';
import 'package:test23/widgets/konten/card_sorotan_utama.dart';
import 'package:test23/widgets/konten/header_konten.dart';
import 'package:test23/widgets/konten/kategori_konten_tabs.dart';
import 'package:test23/widgets/konten/search_konten_bar.dart';
import 'package:test23/widgets/konten/section_wawasan_komunitas.dart';
import 'package:test23/widgets/umum/bottom_nav_bar.dart';

class HalamanKonten extends StatefulWidget {
  const HalamanKonten({super.key});

  @override
  State<HalamanKonten> createState() => _HalamanKontenState();
}

class _HalamanKontenState extends State<HalamanKonten> {
  final int _currentNavIndex = 0; // Konten is active (Index 0)
  int _selectedCategoryIndex = 0;
  bool _isHeaderBookmarked = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _listEdukasiPublik = [];
  bool _isLoadingEdukasi = true;
  String _searchQuery = '';

  final List<String> _categories = [
    'Konten Terbaru',
    'Event',
    'Profil',
    'Kategori Daur Ulang',
    'Komunitas',
  ];

  @override
  void initState() {
    super.initState();
    _loadEdukasiPublik();
  }

  Future<void> _loadEdukasiPublik() async {
    try {
      final res = await ApiService.fetchEdukasi();
      if (res.success && res.data is List && mounted) {
        setState(() {
          _listEdukasiPublik = res.data as List;
          _isLoadingEdukasi = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoadingEdukasi = false);
    }
  }

  String? _getYoutubeThumbnail(String? url) => KontenValidator.getYoutubeThumbnail(url);

  List<dynamic> get _filteredEdukasi {
    if (_listEdukasiPublik.isEmpty) return [];
    return _listEdukasiPublik.where((item) {
      final map = item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{};
      final title = (map['title'] ?? '').toString().toLowerCase();
      final desc = (map['description'] ?? '').toString().toLowerCase();
      final penulis = (map['penulis'] ?? '').toString().toLowerCase();
      final jenis = (map['jenis_edukasi'] ?? '').toString().toLowerCase();

      // Search Query filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchSearch = title.contains(q) || desc.contains(q) || penulis.contains(q) || jenis.contains(q);
        if (!matchSearch) return false;
      }

      // Category Tab filter
      if (_selectedCategoryIndex == 1) { // Event
        return jenis.contains('event');
      } else if (_selectedCategoryIndex == 2) { // Profil
        return jenis.contains('profil');
      } else if (_selectedCategoryIndex == 3) { // Kategori Daur Ulang
        return jenis.contains('daur') || jenis.contains('plastik') || jenis.contains('reduce') || jenis.contains('reuse') || jenis.contains('recycle');
      } else if (_selectedCategoryIndex == 4) { // Komunitas
        return jenis.contains('komunitas');
      }

      return true; // 'Konten Terbaru' (Index 0) shows all
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── 1. Video Player Modal ──
  void _showVideoPlayerModal([Map<String, dynamic>? item]) {
    final currentItem = item ?? (_listEdukasiPublik.isNotEmpty && _listEdukasiPublik.first is Map ? Map<String, dynamic>.from(_listEdukasiPublik.first as Map) : null);
    final title = currentItem?['title']?.toString() ?? 'Video Edukasi TR4SH';
    final desc = currentItem?['description']?.toString() ?? 'Pelajari langkah bijak memilah dan mengolah sampah untuk lingkungan yang lebih asri.';
    String author = 'Administrator';
    if (currentItem != null) {
      if (currentItem['penulis'] != null && currentItem['penulis'].toString().isNotEmpty) {
        author = currentItem['penulis'].toString();
      } else if (currentItem['user'] is Map && (currentItem['user'] as Map)['nama'] != null) {
        author = (currentItem['user'] as Map)['nama'].toString();
      }
    }
    final mediaUrl = currentItem?['media_url']?.toString() ?? '';
    final jenis = currentItem?['jenis_edukasi']?.toString() ?? 'Edukasi Lingkungan';
    final thumbUrl = _getYoutubeThumbnail(mediaUrl);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (thumbUrl != null && thumbUrl.startsWith('http'))
                    Image.network(
                      thumbUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        height: 200,
                        color: AppColors.darkGreen,
                        child: const Center(
                          child: Icon(Icons.videocam_rounded, size: 60, color: Colors.white),
                        ),
                      ),
                    )
                  else
                    Image.asset(
                      'assets/images/konten_video_thumb.jpg',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        height: 200,
                        color: AppColors.darkGreen,
                        child: const Center(
                          child: Icon(Icons.videocam_rounded, size: 60, color: Colors.white),
                        ),
                      ),
                    ),
                  Container(
                    height: 200,
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.darkGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, size: 12, color: AppColors.limeAccent),
                          SizedBox(width: 4),
                          Text(
                            'DISETUJUI ADMIN • PUBLIK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.limeAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 38,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8F4E4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    jenis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B6B44),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Oleh: $author',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (mediaUrl.isNotEmpty)
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: mediaUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tautan video berhasil disalin!'),
                          backgroundColor: AppColors.darkGreen,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8F4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFDCEFE3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.link_rounded, size: 13, color: AppColors.darkGreen),
                          SizedBox(width: 4),
                          Text('Salin Link', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF465A50), height: 1.4),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup Pemutar', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. Filter Bottom Sheet ──
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(22),
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
                  'Filter Konten',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Semua',
                'Tutorial Video',
                'Artikel Daur Ulang',
                'Komunitas',
                'Organik',
                'An-organik',
                'DIY & Kerajinan',
              ].map((label) {
                return Chip(
                  backgroundColor: label == 'Semua' ? AppColors.darkGreen : const Color(0xFFE8F5EE),
                  label: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: label == 'Semua' ? AppColors.limeAccent : AppColors.darkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
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
                child: const Text('Terapkan Filter', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. Notification Sheet ──
  void _showNotificationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(22),
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
                  'Notifikasi Konten',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
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
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFD6F5E1),
                    child: Icon(Icons.article_rounded, color: AppColors.darkGreen, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _listEdukasiPublik.isNotEmpty
                          ? 'Konten baru "${_listEdukasiPublik.first['title']}" baru saja diterbitkan!'
                          : 'Konten edukasi baru telah disetujui dan siap ditonton!',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.darkGreen),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── 4. Comments Sheet ──
  void _showCommentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
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
              'Komentar (238)',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildCommentItem('Farhan Rizky', 'Sangat inspiratif! Tutup botol HDPE juga bisa dijadikan tatakan cangkir teh yang estetik.'),
                  _buildCommentItem('Siti Rahmawati', 'Langkah pemilahannya sangat detail dan gampang diikuti di rumah tangga.'),
                  _buildCommentItem('Dewi Lestari', 'Terima kasih atas materi edukasinya, ilmunya sangat praktis untuk dipraktikkan!'),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.bgScreen,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tulis komentar Anda...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.darkGreen, size: 20),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Komentar berhasil dikirim!'),
                          backgroundColor: AppColors.darkGreen,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(String author, String comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.mintSoft,
            child: Text(
              author.substring(0, 1),
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkGreen),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                ),
                const SizedBox(height: 2),
                Text(
                  comment,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF465A50)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. Contributor Upload Navigation ──
  void _showContributorModal() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HalamanUploadKonten()),
    );
    _loadEdukasiPublik();
  }

  // ── Konten Baru Terupload (Terverifikasi Admin) ──
  Widget _buildSectionKontenBaruEdukasi() {
    final list = _filteredEdukasi;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8F4E4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.new_releases_rounded, size: 16, color: Color(0xFF1B6B44)),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Konten Baru Terupload',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
              if (list.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.limeAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${list.length} Video Disetujui',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingEdukasi)
            Container(
              height: 90,
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
          else if (list.isEmpty)
            if (_listEdukasiPublik.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Center(
                  child: Text(
                    'Tidak ada video untuk filter atau pencarian ini.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                  ),
                ),
              )
            else
              const SizedBox.shrink()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = list[index];
                final itemMap = item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{};
                final title = itemMap['title']?.toString() ?? 'Video Edukasi';
                final desc = itemMap['description']?.toString() ?? '';
                final author = itemMap['penulis']?.toString() ?? 'Komunitas TR4SH';
                final jenis = itemMap['jenis_edukasi']?.toString() ?? 'Edukasi Lingkungan';
                final mediaUrl = itemMap['media_url']?.toString() ?? '';
                final thumb = _getYoutubeThumbnail(mediaUrl);

                return InkWell(
                  onTap: () => _showVideoPlayerModal(itemMap),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (thumb != null && thumb.startsWith('http'))
                                Image.network(
                                  thumb,
                                  width: 110,
                                  height: 76,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) => Container(
                                    width: 110,
                                    height: 76,
                                    color: AppColors.darkGreen,
                                    child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 28),
                                  ),
                                )
                              else
                                Container(
                                  width: 110,
                                  height: 76,
                                  color: AppColors.darkGreen,
                                  child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 28),
                                ),
                              Container(
                                width: 110,
                                height: 76,
                                color: Colors.black.withValues(alpha: 0.25),
                              ),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.limeAccent,
                                child: const Icon(Icons.play_arrow_rounded, color: AppColors.darkGreen, size: 20),
                              ),
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'YouTube',
                                    style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD8F4E4),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 115),
                                      child: Text(
                                        jenis,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1B6B44),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.limeAccent.withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle_rounded, size: 10, color: AppColors.darkGreen),
                                        SizedBox(width: 2),
                                        Text(
                                          'Disetujui',
                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGreen,
                                  height: 1.25,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              if (desc.isNotEmpty)
                                Text(
                                  desc,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 4),
                              Text(
                                'by: $author',
                                style: const TextStyle(fontSize: 10.5, color: Color(0xFF1E8850), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ── 6. Detail Wawasan Modal ──
  void _showWawasanDetail(String title, String desc, String author) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(22),
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
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              author,
              style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              desc,
              style: const TextStyle(fontSize: 13, color: Color(0xFF465A50), height: 1.45),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
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
        child: RefreshIndicator(
          onRefresh: _loadEdukasiPublik,
          color: AppColors.darkGreen,
          backgroundColor: AppColors.limeAccent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. Top Header (Logo TR4SH! & Actions) ──
                HeaderKonten(
                  isBookmarked: _isHeaderBookmarked,
                  hasUnreadNotification: true,
                  onBookmarkTap: () {
                    setState(() {
                      _isHeaderBookmarked = !_isHeaderBookmarked;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isHeaderBookmarked ? 'Konten tersimpan ke bookmark' : 'Bookmark dihapus',
                        ),
                        duration: const Duration(milliseconds: 900),
                        backgroundColor: AppColors.darkGreen,
                      ),
                    );
                  },
                  onNotificationTap: _showNotificationSheet,
                ),

                const SizedBox(height: 6),

                // ── 2. Search Bar with Filter Button ──
                SearchKontenBar(
                  controller: _searchController,
                  onFilterTap: _showFilterSheet,
                  onChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                ),

                const SizedBox(height: 12),

                // ── 3. Category Filter Chips (Horizontal) ──
                KategoriKontenTabs(
                  categories: _categories,
                  selectedIndex: _selectedCategoryIndex,
                  onSelectIndex: (index) {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // ── 4. Sorotan Utama (Featured Video Card) ──
                Builder(
                  builder: (context) {
                    final featuredItem = _filteredEdukasi.isNotEmpty
                        ? (_filteredEdukasi.first is Map ? Map<String, dynamic>.from(_filteredEdukasi.first as Map) : null)
                        : (_listEdukasiPublik.isNotEmpty && _listEdukasiPublik.first is Map
                            ? Map<String, dynamic>.from(_listEdukasiPublik.first as Map)
                            : null);

                    return CardSorotanUtama(
                      item: featuredItem,
                      onPlayTap: () => _showVideoPlayerModal(featuredItem),
                      onCommentTap: _showCommentsSheet,
                      onShareTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tautan video berhasil disalin ke clipboard!'),
                            duration: Duration(milliseconds: 900),
                            backgroundColor: AppColors.darkGreen,
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),

                // ── 5. Konten Baru Terupload (Terverifikasi Admin) ──
                _buildSectionKontenBaruEdukasi(),

                const SizedBox(height: 20),

                // ── 6. Wawasan Komunitas (Q&A & DIY Coaster Cards) ──
                SectionWawasanKomunitas(
                  onSeeAllTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Membuka semua wawasan komunitas...'),
                        duration: Duration(milliseconds: 900),
                        backgroundColor: AppColors.darkGreen,
                      ),
                    );
                  },
                  onCardQnATap: () {
                    _showWawasanDetail(
                      'Apakah sampah dapat berguna kembali?',
                      'Tentu! Lebih dari 78% sampah an-organik rumah tangga dapat dikonversi menjadi filament 3D printer atau pot bibit mandiri dengan teknik shredder sederhana. Pengurangan sampah dimulai dari pemilahan yang konsisten di tingkat rumah tangga.',
                      'Oleh: Budi Prakoso • Komunitas Depok',
                    );
                  },
                  onCardKreasiTap: () {
                    _showWawasanDetail(
                      'Kreasi Daur Ulang: Tatakan Gelas Marmer HDPE',
                      'Ide sulap tutup botol HDPE jadi tatakan gelas marmer minimalis yang tahan panas dan bernilai jual tinggi. Cukup kumpulkan tutup botol beraneka warna, lelehkan pada cetakan silikon dengan oven pemanas, lalu ratakan.',
                      'Dilihat 892 kali • Terverifikasi Komunitas',
                    );
                  },
                ),

                const SizedBox(height: 20),

                // ── 7. Contributor CTA Banner ──
                BannerKontributorKonten(
                  onBerbagiIdeTap: _showContributorModal,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),

      // ── 7. Floating Action Button: Upload Konten ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showContributorModal,
        backgroundColor: AppColors.limeAccent,
        foregroundColor: AppColors.darkGreen,
        icon: const Icon(Icons.video_call_rounded, size: 22),
        label: const Text(
          'Upload Konten',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
        ),
      ),

      // ── 8. Bottom Navigation Bar ──
      bottomNavigationBar: TrashBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 1) {
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
          } else if (index == 4) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HalamanAkun()),
            );
          } else if (index != 0) {
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
