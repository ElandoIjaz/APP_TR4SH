import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  final List<Map<String, dynamic>> _kategoriOptions = [
    {
      'value': 'Reduce',
      'label': 'Reduce',
      'subtitle': 'Kurangi sampah',
      'icon': Icons.eco_rounded,
    },
    {
      'value': 'Recycle',
      'label': 'Recycle',
      'subtitle': 'Daur ulang',
      'icon': Icons.autorenew_rounded,
    },
    {
      'value': 'Reuse',
      'label': 'Reuse',
      'subtitle': 'Pakai kembali',
      'icon': Icons.recycling_rounded,
    },
  ];
  String _selectedKategori = 'Reduce';
  String _selectedTipeMedia = 'Video';

  bool _isLoading = false;
  String? _detectedYoutubeId;
  XFile? _pickedImageFile;

  bool _isLoadingRiwayat = false;
  List<dynamic> _listKontenSaya = [];

  bool get _isFotoMode => _selectedTipeMedia == 'Foto';

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
    if (_isFotoMode) return;
    final id = KontenValidator.extractYoutubeId(_urlController.text);
    if (id != _detectedYoutubeId) {
      setState(() => _detectedYoutubeId = id);
    }
  }

  void _gantiTipeMedia(String tipe) {
    if (_selectedTipeMedia == tipe) return;
    setState(() {
      _selectedTipeMedia = tipe;
      _urlController.clear();
      _detectedYoutubeId = null;
      _pickedImageFile = null;
    });
  }

  Future<void> _pilihFotoDariPerangkat() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _pickedImageFile = picked);
    }
  }

  Future<void> _muatKontenSaya() async {
    if (UserAccountData.isNewAccount && UserAccountData.listKontenSaya.isEmpty) {
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
        message:
            'Mode Tamu tidak dapat mengunggah konten. Silakan masuk atau daftar akun terlebih dahulu.',
        icon: Icons.video_collection_rounded,
      );
      return;
    }

    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty) {
      _showSnackBar('Judul konten wajib diisi.', Colors.redAccent);
      return;
    }
    if (title.length > 50) {
      _showSnackBar('Judul konten maksimal 50 karakter.', Colors.redAccent);
      return;
    }
    if (desc.isEmpty) {
      _showSnackBar('Deskripsi konten wajib diisi.', Colors.redAccent);
      return;
    }

    String normalizedUrl = '';

    if (_isFotoMode) {
      if (_pickedImageFile == null) {
        _showSnackBar('Pilih foto dari perangkat terlebih dahulu.', Colors.redAccent);
        return;
      }
    } else {
      final error = KontenValidator.validateUploadForm(
        rawUrl: _urlController.text,
        detectedYoutubeId: _detectedYoutubeId,
        title: title,
        description: desc,
      );
      if (error != null) {
        _showSnackBar(error, Colors.redAccent);
        return;
      }
      normalizedUrl = KontenValidator.normalizeYoutubeUrl(_urlController.text)!;
    }

    setState(() => _isLoading = true);

    final res = await ApiService.uploadKonten(
      idUser: UserAccountData.currentUserId,
      title: title,
      mediaUrl: normalizedUrl,
      description: desc,
      jenisEdukasi: _selectedKategori,
      tipeMedia: _selectedTipeMedia,
      fotoFile: _isFotoMode ? _pickedImageFile : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.success) {
      final savedYoutubeId = _detectedYoutubeId;
      final savedFotoPath = _pickedImageFile?.path;
      _tampilkanDialogSukses(
        title: title,
        youtubeId: savedYoutubeId,
        localImagePath: savedFotoPath,
        kategori: _selectedKategori,
        tipeMedia: _selectedTipeMedia,
      );
      _urlController.clear();
      _titleController.clear();
      _descController.clear();
      setState(() {
        _detectedYoutubeId = null;
        _pickedImageFile = null;
      });
    } else {
      _showSnackBar(res.message, Colors.redAccent);
    }
  }

  void _tampilkanDialogSukses({
    required String title,
    required String? youtubeId,
    required String? localImagePath,
    required String kategori,
    required String tipeMedia,
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
              'Konten $tipeMedia Anda telah masuk ke sistem TR4SH dan sedang menunggu tinjauan tim Admin sebelum ditampilkan ke publik.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
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
                    child: youtubeId != null
                        ? Image.network(
                            'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg',
                            width: 70,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _miniThumbFallback(true),
                          )
                        : (localImagePath != null
                            ? Image.file(
                                File(localImagePath),
                                width: 70,
                                height: 48,
                                fit: BoxFit.cover,
                              )
                            : _miniThumbFallback(false)),
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
                          '$kategori • $tipeMedia',
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

  Widget _miniThumbFallback(bool isVideo) {
    return Container(
      width: 70,
      height: 48,
      color: Colors.grey.shade300,
      child: Icon(
        isVideo ? Icons.play_circle_outline : Icons.image_outlined,
        color: Colors.grey,
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
                    'Bagikan inspirasi daur ulang melalui tautan video YouTube atau foto dari perangkat Anda. Konten akan berstatus "Menunggu Konfirmasi Admin" sebelum dipublikasikan.',
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

          const Text(
            'Tipe Media *',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTipeMediaChip(
                  label: 'Video YouTube',
                  value: 'Video',
                  icon: Icons.smart_display_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTipeMediaChip(
                  label: 'Foto Perangkat',
                  value: 'Foto',
                  icon: Icons.photo_library_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_isFotoMode) ...[
            const Text(
              'Pilih Foto dari Perangkat *',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.darkGreen,
                side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _pilihFotoDariPerangkat,
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(
                _pickedImageFile == null
                    ? 'Pilih Gambar dari Galeri / Perangkat'
                    : 'Ganti Foto (${_pickedImageFile!.name})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ] else ...[
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
          ],
          const SizedBox(height: 12),

          _buildLiveMediaPreview(),
          const SizedBox(height: 20),

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
            maxLength: 50,
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
          const SizedBox(height: 14),

          const Text(
            'Kategori Edukasi *',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          _buildKategoriSelector(),
          const SizedBox(height: 20),

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
              hintText:
                  'Tuliskan ringkasan konten, alat/bahan yang dibutuhkan, atau poin penting yang bisa dipelajari penonton...',
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

  Widget _buildKategoriSelector() {
    return Row(
      children: List.generate(_kategoriOptions.length, (index) {
        final option = _kategoriOptions[index];
        final String value = option['value'] as String;
        final String label = option['label'] as String;
        final String subtitle = option['subtitle'] as String;
        final IconData icon = option['icon'] as IconData;
        final bool isSelected = _selectedKategori == value;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < _kategoriOptions.length - 1 ? 8 : 0,
            ),
            child: Material(
              color: isSelected ? AppColors.darkGreen : Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() => _selectedKategori = value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.darkGreen
                          : AppColors.cardBorder,
                      width: isSelected ? 1.8 : 1.2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 22,
                        color: isSelected
                            ? AppColors.limeAccent
                            : AppColors.darkGreen,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isSelected
                              ? Colors.white70
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTipeMediaChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedTipeMedia == value;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _gantiTipeMedia(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.darkGreen : AppColors.cardBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.limeAccent : AppColors.darkGreen,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMediaPreview() {
    if (_isFotoMode) {
      if (_pickedImageFile == null) {
        return _buildEmptyPreviewBox(
          icon: Icons.photo_library_outlined,
          label: 'Pratinjau foto dari perangkat akan muncul di sini',
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
              child: Image.file(
                File(_pickedImageFile!.path),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
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
                      'Foto Terpilih: ${_pickedImageFile!.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

    if (_detectedYoutubeId == null) {
      return _buildEmptyPreviewBox(
        icon: Icons.video_library_outlined,
        label: 'Pratinjau video YouTube akan muncul di sini',
      );
    }

    final thumbUrl =
        'https://img.youtube.com/vi/$_detectedYoutubeId/hqdefault.jpg';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
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
                  errorBuilder: (_, __, ___) => Container(
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

  Widget _buildEmptyPreviewBox({required IconData icon, required String label}) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.grey.shade400),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

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
                'Kirimkan konten edukasi pertama Anda untuk menginspirasi komunitas TR4SH!',
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
          final rawItem = _listKontenSaya[index];
          final item = rawItem is Map
              ? Map<String, dynamic>.from(rawItem)
              : <String, dynamic>{};
          return _buildKartuKontenUser(item);
        },
      ),
    );
  }

  Widget _buildKartuKontenUser(Map<String, dynamic> item) {
    final title = item['title']?.toString() ?? 'Konten Edukasi';
    final status =
        (item['status_moderasi']?.toString() ?? 'pending').toLowerCase();
    final kategori = item['jenis_edukasi']?.toString() ?? 'Reduce';
    final desc = item['description']?.toString() ?? '';
    final mediaUrl = item['media_url']?.toString() ?? '';
    final alasan = item['alasan_penolakan']?.toString();
    final youtubeId = KontenValidator.extractYoutubeId(mediaUrl);

    String? thumbUrl;
    if (youtubeId != null) {
      thumbUrl = 'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';
    } else if (mediaUrl.isNotEmpty) {
      thumbUrl = (mediaUrl.startsWith('http://') || mediaUrl.startsWith('https://'))
          ? mediaUrl
          : 'http://127.0.0.1:8000/${mediaUrl.startsWith('/') ? mediaUrl.substring(1) : mediaUrl}';
    }

    Color badgeBg;
    Color badgeText;
    IconData badgeIcon;
    String labelStatus;

    if (status == 'approved' || status == 'accepted') {
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (thumbUrl != null && thumbUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        thumbUrl,
                        width: 80,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 56,
                          color: Colors.grey.shade300,
                          child: Icon(
                            youtubeId != null
                                ? Icons.smart_display
                                : Icons.image_outlined,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      if (youtubeId != null)
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