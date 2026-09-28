import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/pages/halaman_akun.dart';
import 'package:test23/pages/halaman_beranda.dart';
import 'package:test23/pages/halaman_produk.dart';
import 'package:test23/pages/halaman_tracking.dart';
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

  final List<String> _categories = [
    'Konten Terbaru',
    'Event',
    'Profil',
    'Kategori Daur Ulang',
    'Komunitas',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── 1. Video Player Modal ──
  void _showVideoPlayerModal() {
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
                  Image.asset(
                    'assets/images/konten_video_thumb.jpg',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: 200,
                    color: Colors.black.withValues(alpha: 0.3),
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
            const Text(
              'Cara Mendaur Ulang Botol Plastik Minuman',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Diputar oleh Ibu Anin • Durasi: 12:45 menit • Kategori: Plastik An-organik',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
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
                children: const [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFD6F5E1),
                    child: Icon(Icons.article_rounded, color: AppColors.darkGreen, size: 18),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tutorial baru "Cara Mendaur Ulang Botol Plastik Minuman" baru saja diterbitkan!',
                      style: TextStyle(fontSize: 12.5, color: AppColors.darkGreen),
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
                  _buildCommentItem('Dewi Lestari', 'Terima kasih tipsnya Ibu Anin, langsung dipraktikkan hari ini!'),
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

  // ── 5. Contributor Submission Modal ──
  void _showContributorModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
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
                  Icon(Icons.workspace_premium_rounded, color: Color(0xFFD7B000), size: 26),
                  SizedBox(width: 10),
                  Text(
                    'Kirim Karya Sirkular Anda',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Bagikan artikel, tutorial video, atau foto kerajinan daur ulang Anda dan raih EcoPoints!',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Judul Ide / Tutorial',
                  labelStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.bgScreen,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Singkat Karya Anda',
                  labelStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.bgScreen,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Terima kasih! Konten Anda sedang ditinjau kurator TR4SH!.'),
                        backgroundColor: AppColors.darkGreen,
                      ),
                    );
                  },
                  child: const Text('Kirim Konten Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
                  // Realtime search handler
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
              CardSorotanUtama(
                onPlayTap: _showVideoPlayerModal,
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
              ),

              const SizedBox(height: 20),

              // ── 5. Wawasan Komunitas (Q&A & DIY Coaster Cards) ──
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

              // ── 6. Contributor CTA Banner ──
              BannerKontributorKonten(
                onBerbagiIdeTap: _showContributorModal,
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
