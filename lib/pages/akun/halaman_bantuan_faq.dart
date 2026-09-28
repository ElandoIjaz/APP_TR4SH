import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class HalamanBantuanFaq extends StatefulWidget {
  const HalamanBantuanFaq({super.key});

  @override
  State<HalamanBantuanFaq> createState() => _HalamanBantuanFaqState();
}

class _HalamanBantuanFaqState extends State<HalamanBantuanFaq> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'Semua',
    'Setor Sampah',
    'EcoPoints',
    'Marketplace',
    'Alamat & Kurir',
  ];

  final List<Map<String, String>> _faqItems = [
    {
      'kategori': 'Setor Sampah',
      'tanya': 'Bagaimana cara menyetor sampah di TR4SH!?',
      'jawab':
          'Anda dapat memilih metode Setor Mandiri ke Bank Sampah terdekat atau Pesan Penjemputan ke alamat Anda melalui menu Tracking di aplikasi.',
    },
    {
      'kategori': 'Alamat & Kurir',
      'tanya': 'Mengapa penentuan lokasi alamat pengiriman harus akurat?',
      'jawab':
          'Karena kurir kami memerlukan koordinat GPS presisi dan patokan alamat agar produk hasil daur ulang dan jadwal penjemputan sampah dapat sampai tepat waktu di depan pintu rumah Anda tanpa tersasar.',
    },
    {
      'kategori': 'EcoPoints',
      'tanya': 'Bagaimana cara mendapatkan dan menukar EcoPoints?',
      'jawab':
          'EcoPoints didapatkan setiap kali Anda menyetor sampah terpilah atau membagikan tutorial ide sirkular. Poin dapat ditukar dengan voucher belanja, donasi pohon, dan saldo e-wallet.',
    },
    {
      'kategori': 'Marketplace',
      'tanya': 'Apakah produk yang dijual terbuat dari sampah daur ulang asli?',
      'jawab':
          'Ya, seluruh produk di TR4SH! Eco Marketplace telah melalui kurasi ketat dan diverifikasi dibuat dari bahan limbah daur ulang (seperti botol plastik PET, karung goni, dan kardus bekas).',
    },
    {
      'kategori': 'Setor Sampah',
      'tanya': 'Jenis sampah apa saja yang diterima untuk ditabung?',
      'jawab':
          'Kami menerima botol plastik (PET/HDPE), kertas & kardus kemasan, kaleng aluminium & logam, kaca tebal, dan minyak jelantah bekas.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _faqItems.where((item) {
      final matchesCategory = _selectedCategoryIndex == 0 ||
          item['kategori'] == _categories[_selectedCategoryIndex];
      final query = _searchController.text.toLowerCase();
      final matchesQuery = query.isEmpty ||
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
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.darkGreen, size: 20),
              ),
            ),
          ),
        ),
        title: const Text(
          'Bantuan & FAQ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
                    const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 12.5, color: AppColors.darkGreen),
                        decoration: const InputDecoration(
                          hintText: 'Cari pertanyaan atau kendala Anda...',
                          hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          border: InputBorder.none,
                          isDense: true,
                        ),
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
                  physics: const BouncingScrollPhysics(),
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final bool isSelected = _selectedCategoryIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.darkGreen : AppColors.bgScreen,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.darkGreen : AppColors.cardBorder,
                          ),
                        ),
                        child: Text(
                          _categories[index],
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? AppColors.limeAccent : AppColors.darkGreen,
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
              child: Column(
                children: filtered.map<Widget>((faq) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.cardBorder),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          iconColor: AppColors.darkGreen,
                          collapsedIconColor: AppColors.textMuted,
                          title: Text(
                            faq['tanya']!,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Text(
                                faq['jawab']!,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF4C6656), height: 1.4),
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
                    Row(
                      children: const [
                        Icon(Icons.headset_mic_rounded, color: AppColors.limeAccent, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Butuh Bantuan Lebih Lanjut?',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tim Layanan Pelanggan TR4SH! siap membantu kendala Anda setiap hari pukul 08.00 - 20.00 WIB.',
                      style: TextStyle(fontSize: 11, color: Colors.white70, height: 1.35),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Menghubungi Customer Service TR4SH!...'),
                              backgroundColor: AppColors.darkGreen,
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                        label: const Text(
                          'Hubungi Layanan Bantuan',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
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
