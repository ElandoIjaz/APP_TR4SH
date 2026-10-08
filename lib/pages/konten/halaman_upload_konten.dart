import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/core/validators/konten_validator.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/auth/halaman_login.dart';
import 'package:test23/widgets/umum/auth_required_modal.dart';

class HalamanUploadKonten extends StatefulWidget {
  const HalamanUploadKonten({super.key});

  @override
  State<HalamanUploadKonten> createState() => _HalamanUploadKontenState();
}

class _HalamanUploadKontenState extends State<HalamanUploadKonten>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form Controllers
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  final List<String> _kategoriList = [
    'Edukasi Lingkungan',
    'Daur Ulang (Recycle)',
    'Pengurangan Sampah (Reduce)',
    'Pemanfaatan Kembali (Reuse)',
    'Prakarya Kreatif',
    'Tips Kompos',
  ];
  String _selectedKategori = 'Edukasi Lingkungan';

  bool _isLoading = false;
  String? _detectedYoutubeId;

  // Riwayat State
  bool _isLoadingRiwayat = false;
  List<dynamic> _listKontenSaya = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        _muatKontenSaya();
      }
    });

    _urlController.addListener(_onUrlChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.removeListener(_onUrlChanged);
    _urlController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onUrlChanged() {
    final rawUrl = _urlController.text;
    final id = KontenValidator.extractYoutubeId(rawUrl);
    if (id != _detectedYoutubeId) {
      setState(() {
        _detectedYoutubeId = id;
      });
    }
  }

  Future<void> _muatKontenSaya() async {
    if (UserAccountData.isNewAccount &&
        UserAccountData.listKontenSaya.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoadingRiwayat = false;
          _listKontenSaya = [];
        });
      }
      return;
    }
    setState(() => _isLoadingRiwayat = true);
    final res = await ApiService.fetchKontenSaya();
    if (!mounted) return;
    setState(() {
      _isLoadingRiwayat = false;
      if (res.success && res.data is List) {
        _listKontenSaya = res.data as List;
      }
    });
  }

  Future<void> _kirimKonten() async {
    if (UserAccountData.isGuest) {
      AuthRequiredModal.show(
        context,
        title: 'Upload Konten Memerlukan Akun',
        message: 'Mode Tamu tidak dapat mengunggah konten. Silakan masuk atau daftar akun terlebih dahulu.',
        icon: Icons.video_collection_rounded,
      );
      return;
    }

    final title = _titleController.text;
    final url = _urlController.text;
    final desc = _descController.text;

    // Bersih dan rapi: Logic if-else form diekstrak ke KontenValidator
    final error = KontenValidator.validateUploadForm(
      rawUrl: url,
      detectedYoutubeId: _detectedYoutubeId,
      title: title,
      description: desc,
    );

    if (error != null) {
      _showSnackBar(error, Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    final normalizedUrl = KontenValidator.normalizeYoutubeUrl(url)!;

    final res = await ApiService.uploadKonten(
      idUser: UserAccountData.currentUserId,
      title: title,
      mediaUrl: normalizedUrl,
      description: desc,
      jenisEdukasi: _selectedKategori,
      tipeMedia: 'Video YouTube',
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.success) {
      _tampilkanDialogSukses(
        title: title,
        youtubeId: _detectedYoutubeId!,
        kategori: _selectedKategori,
      );
      // Reset form
      _urlController.clear();
      _titleController.clear();
      _descController.clear();
      setState(() {
        _detectedYoutubeId = null;
      });
    } else {
      _showSnackBar(res.message, Colors.redAccent);
    }
  }

  void _tampilkanDialogSukses({
    required String title,
    required String youtubeId,
    required String kategori,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Icon & Badge
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF59E0B), width: 2),
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                size: 38,
                color: Color(0xFFD97706),
              ),
            ),
            const SizedBox(height: 16),

            // Tag status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 14, color: Color(0xFFB45309)),
                  SizedBox(width: 6),
                  Text(
                    'Menunggu Konfirmasi Admin',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'Konten Berhasil Terkirim!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Karya video Anda telah masuk ke sistem TR4SH dan saat ini sedang menunggu tinjauan dari tim Admin sebelum ditampilkan di katalog publik.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Card Mini Preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgScreen,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg',
                      width: 70,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 70,
                        height: 48,
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.play_circle_outline,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          kategori,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _tabController.animateTo(1);
                  _muatKontenSaya();
                },
                child: const Text(
                  'Lihat Status Konten Saya',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Unggah Konten Lainnya',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Unggah Konten Edukasi',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.limeAccent,
          indicatorWeight: 3.5,
          labelColor: AppColors.limeAccent,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.video_library_rounded, size: 20),
              text: 'Formulir Konten',
            ),
            Tab(
              icon: Icon(Icons.history_rounded, size: 20),
              text: 'Konten Saya',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFormUploadTab(), _buildRiwayatKontenTab()],
      ),
    );
  }

  // ── TAB 1: FORM UPLOAD KONTEN ──
  Widget _buildFormUploadTab() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (UserAccountData.isGuest) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFEEBA)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFF856404),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Mode Tamu: Anda harus masuk untuk dapat mengunggah konten edukasi.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF856404),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HalamanLogin()),
                      );
                    },
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Banner Info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFC8E6C9)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFF2E7D32),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Bagikan inspirasi daur ulang melalui tautan video YouTube Anda. Setelah dikirim, konten akan berstatus "Menunggu Konfirmasi Admin" sebelum dipublikasikan.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade900,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 1. Link Video YouTube
          const Text(
            'Link Video YouTube *',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            style: const TextStyle(fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'https://www.youtube.com/watch?v=... atau youtu.be/...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12.5),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(
                Icons.smart_display_rounded,
                color: Colors.redAccent,
              ),
              suffixIcon: _urlController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        _urlController.clear();
                        setState(() => _detectedYoutubeId = null);
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.darkGreen,
                  width: 1.8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // YouTube Thumbnail Live Preview
          _buildLiveThumbnailPreview(),
          const SizedBox(height: 20),

          // 2. Judul Konten
          const Text(
            'Judul Konten Edukasi *',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Contoh: Membuat Pot Hias dari Limbah Galon Air',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12.5),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.title, color: AppColors.darkGreen),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.darkGreen,
                  width: 1.8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Kategori Edukasi
          const Text(
            'Kategori Edukasi *',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedKategori,
                isExpanded: true,
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.darkGreen,
                ),
                items: _kategoriList.map((String k) {
                  return DropdownMenuItem<String>(
                    value: k,
                    child: Text(
                      k,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? val) {
                  if (val != null) {
                    setState(() => _selectedKategori = val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 4. Deskripsi Konten
          const Text(
            'Deskripsi Konten *',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _descController,
            maxLines: 5,
            style: const TextStyle(fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Tuliskan ringkasan video, alat/bahan yang dibutuhkan, atau poin penting yang bisa dipelajari penonton...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12.5),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.darkGreen,
                  width: 1.8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Tombol Kirim Konten
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isLoading ? null : _kirimKonten,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Kirim Konten',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Preview YouTube Thumbnail
  Widget _buildLiveThumbnailPreview() {
    if (_detectedYoutubeId == null) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.cardBorder,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 32,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 6),
              Text(
                'Pratinjau video YouTube akan muncul di sini',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    final thumbUrl =
        'https://img.youtube.com/vi/$_detectedYoutubeId/hqdefault.jpg';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  thumbUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.black87,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Video YouTube Terdeteksi (ID: $_detectedYoutubeId)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TAB 2: RIWAYAT KONTEN SAYA & STATUS MODERASI ──
  Widget _buildRiwayatKontenTab() {
    if (_isLoadingRiwayat) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.darkGreen),
      );
    }

    if (_listKontenSaya.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: AppColors.mintSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.video_library_outlined,
                  size: 38,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Belum Ada Konten Diunggah',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kirimkan video edukasi YouTube pertama Anda untuk menginspirasi komunitas TR4SH!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _tabController.animateTo(0),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Unggah Sekarang'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.darkGreen,
      onRefresh: _muatKontenSaya,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        padding: const EdgeInsets.all(16),
        itemCount: _listKontenSaya.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = _listKontenSaya[index] as Map<String, dynamic>;
          return _buildKartuKontenUser(item);
        },
      ),
    );
  }

  Widget _buildKartuKontenUser(Map<String, dynamic> item) {
    final title = item['title']?.toString() ?? 'Konten Edukasi';
    final status = (item['status_moderasi']?.toString() ?? 'pending')
        .toLowerCase();
    final kategori = item['jenis_edukasi']?.toString() ?? 'Edukasi Lingkungan';
    final desc = item['description']?.toString() ?? '';
    final mediaUrl = item['media_url']?.toString() ?? '';
    final alasan = item['alasan_penolakan']?.toString();
    final youtubeId = KontenValidator.extractYoutubeId(mediaUrl);

    Color badgeBg;
    Color badgeText;
    IconData badgeIcon;
    String labelStatus;

    if (status == 'approved') {
      badgeBg = const Color(0xFFD1FAE5);
      badgeText = const Color(0xFF065F46);
      badgeIcon = Icons.check_circle_outline;
      labelStatus = 'Disetujui & Diterbitkan';
    } else if (status == 'rejected') {
      badgeBg = const Color(0xFFFEE2E2);
      badgeText = const Color(0xFF991B1B);
      badgeIcon = Icons.cancel_outlined;
      labelStatus = 'Ditolak oleh Admin';
    } else {
      badgeBg = const Color(0xFFFEF3C7);
      badgeText = const Color(0xFF92400E);
      badgeIcon = Icons.hourglass_top_rounded;
      labelStatus = 'Menunggu Konfirmasi Admin';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: Status Badge & Kategori
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 13, color: badgeText),
                    const SizedBox(width: 5),
                    Text(
                      labelStatus,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: badgeText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                kategori,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Title & Thumbnail
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (youtubeId != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg',
                        width: 80,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 56,
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.smart_display,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Alasan Penolakan jika ada
          if (status == 'rejected' && alasan != null && alasan.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Catatan Admin: $alasan',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
