import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test23/core/app_colors.dart';

class HalamanBantuanFaq extends StatefulWidget {
  const HalamanBantuanFaq({super.key});

  @override
  State<HalamanBantuanFaq> createState() => _HalamanBantuanFaqState();
}

class _HalamanBantuanFaqState extends State<HalamanBantuanFaq> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

  static const String _adminWhatsApp = '0856-4974-5782';
  static const String _adminWhatsAppRaw = '6285649745782';

  final List<String> _categories = [
    'Semua',
    'Setor Sampah',
    'Marketplace',
    'Akun & Keamanan',
  ];

  final List<Map<String, dynamic>> _faqItems = [
    {
      'kategori': 'Setor Sampah',
      'tanya': 'Bagaimana cara menyetor sampah di TR4SH!?',
      'jawab':
          'Masuk ke menu Setor / Tracking, pilih jenis sampah yang sudah dipilah, masukkan perkiraan berat, lalu serahkan langsung ke cabang Bank Sampah TR4SH terdekat. Anda bisa mengecek lokasi cabang melalui tombol "Cari Cabang" di halaman Beranda.',
    },
    {
      'kategori': 'Setor Sampah',
      'tanya': 'Jenis sampah apa saja yang diterima untuk disetor?',
      'jawab':
          'Kami menerima sampah terpilah seperti botol plastik (PET/HDPE), kertas dan kardus kemasan, kaleng aluminium/logam, kaca tebal, serta limbah daur ulang lain sesuai daftar kategori di menu Setor Sampah.',
    },
    {
      'kategori': 'Marketplace',
      'tanya': 'Bagaimana cara mengambil produk yang sudah dibeli?',
      'jawab':
          'Setelah pembayaran berstatus lunas, produk kreasi daur ulang dapat diambil langsung di Bank Sampah Sahabat Ibu TR4SH (Perumahan Taman Gading, Tumpengsari, Tegal Besar, Kec. Kaliwates, Jember) dengan menunjukkan Nomor Order (TR4SH-...) kepada petugas.',
    },
    {
      'kategori': 'Marketplace',
      'tanya': 'Metode pembayaran apa saja yang tersedia?',
      'jawab':
          'Pembayaran produk di TR4SH! didukung oleh Midtrans melalui QRIS dan Transfer Virtual Account (BCA, BNI, BRI, Mandiri, Permata). Status pembayaran akan diperbarui otomatis setelah transaksi berhasil.',
    },
    {
      'kategori': 'Marketplace',
      'tanya': 'Apakah produk yang dijual terbuat dari sampah daur ulang asli?',
      'jawab':
          'Ya, seluruh produk di TR4SH! Eco Marketplace telah melalui kurasi dan dibuat dari bahan limbah daur ulang terverifikasi seperti botol plastik PET, karung goni, dan kardus bekas.',
    },
    {
      'kategori': 'Akun & Keamanan',
      'tanya': 'Bagaimana jika saya lupa kata sandi akun?',
      'jawab':
          'Pilih "Lupa Kata Sandi" di halaman Login lalu masukkan nomor WhatsApp yang terdaftar pada akun Anda. Sistem akan mengirimkan kode pemulihan 8 karakter secara otomatis ke WhatsApp Anda yang berlaku selama 15 menit.',
    },
    {
      'kategori': 'Akun & Keamanan',
      'tanya': 'Mengapa Username tidak dapat diubah di Edit Profil?',
      'jawab':
          'Username bersifat permanen karena digunakan sebagai identitas unik untuk login akun Anda. Anda tetap dapat memperbarui Nama Lengkap, Nomor WhatsApp, dan Foto Profil kapan saja melalui menu Edit Profil.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showContactSupportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                const Row(
                  children: [
                    Icon(
                      Icons.support_agent_rounded,
                      color: AppColors.darkGreen,
                      size: 24,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Layanan Bantuan TR4SH!',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgScreen,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WhatsApp Admin',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        _adminWhatsApp,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Lokasi Pengambilan & Bank Sampah',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Bank Sampah Sahabat Ibu TR4SH\nPerumahan Taman Gading, Tumpengsari, Tegal Besar, Kec. Kaliwates, Jember, Jawa Timur',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF3A5245),
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Jam Operasional: Setiap hari, 08.00 - 20.00 WIB',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Clipboard.setData(
                        const ClipboardData(text: _adminWhatsAppRaw),
                      );
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Nomor WhatsApp Admin ($_adminWhatsApp) berhasil disalin!',
                          ),
                          backgroundColor: AppColors.darkGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 17),
                    label: const Text(
                      'Salin Nomor WhatsApp Admin',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _faqItems.where((item) {
      final matchesCategory =
          _selectedCategoryIndex == 0 ||
          item['kategori'] == _categories[_selectedCategoryIndex];
      final query = _searchController.text.trim().toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          item['tanya']!.toLowerCase().contains(query) ||
          item['jawab']!.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6F3DD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.darkGreen,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Bantuan & FAQ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGreen,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // Search Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.bgScreen,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.textMuted,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.darkGreen,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Cari pertanyaan atau kendala Anda...',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Category Chips
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                height: 34,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final bool isSelected = _selectedCategoryIndex == index;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategoryIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.darkGreen
                              : AppColors.bgScreen,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.darkGreen
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: Text(
                          _categories[index],
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected
                                ? AppColors.limeAccent
                                : AppColors.darkGreen,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 14),

            // FAQ Expansion Tiles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: filtered.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 28,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 36,
                            color: AppColors.textMuted,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Pertanyaan tidak ditemukan',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Coba kata kunci lain atau hubungi Layanan Bantuan di bawah.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: filtered.map<Widget>((faq) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                color: AppColors.cardBorder,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                              ),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                iconColor: AppColors.darkGreen,
                                collapsedIconColor: AppColors.textMuted,
                                title: Text(
                                  faq['tanya']!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      16,
                                    ),
                                    child: Text(
                                      faq['jawab']!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF4C6656),
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),

            const SizedBox(height: 16),

            // Contact Support Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D4330),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.headset_mic_rounded,
                          color: AppColors.limeAccent,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Butuh Bantuan Lebih Lanjut?',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tim Layanan Pelanggan TR4SH! siap membantu kendala Anda setiap hari pukul 08.00 - 20.00 WIB.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.limeAccent,
                          foregroundColor: AppColors.darkGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _showContactSupportSheet,
                        icon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 16,
                        ),
                        label: const Text(
                          'Hubungi Layanan Bantuan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}