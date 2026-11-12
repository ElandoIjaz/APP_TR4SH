import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/data/models/bank_sampah_model.dart';
import 'package:test23/pages/produk/halaman_keranjang.dart';
import 'package:test23/widgets/produk/merchant_card.dart';
import 'package:test23/widgets/produk/dampak_lingkungan_card.dart';
import 'package:test23/widgets/produk/spesifikasi_card.dart';
import 'package:test23/data/cart_service.dart';

class HalamanDetailProduk extends StatefulWidget {
  final Map<String, dynamic> productData;

  const HalamanDetailProduk({
    super.key,
    required this.productData,
  });

  @override
  State<HalamanDetailProduk> createState() => _HalamanDetailProdukState();
}

class _HalamanDetailProdukState extends State<HalamanDetailProduk> {
  bool _isFavorite = false;
  final int _currentImageIndex = 1;

  // Data bank sampah diambil sekali di sini, bukan di dalam build()
  late Future<ApiResponse> _futureBank;

  @override
  void initState() {
    super.initState();
    _futureBank = ApiService.fetchBankSampah();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.productData;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageGallery(product['foto']),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPricingAndTitle(product),
                  const SizedBox(height: 18),

                  // Memanggil Widget Dampak Lingkungan
                  DampakLingkunganCard(
                    plastikPet: product['plastik_pet'] ?? '-',
                    jejakKarbon: product['jejak_karbon'] ?? '-',
                  ),
                  const SizedBox(height: 18),

                  // Memanggil Widget Merchant/Toko (data dari API bank sampah)
                  _buildMerchantSection(),
                  const SizedBox(height: 20),

                  // Memanggil Widget Spesifikasi
                  SpesifikasiCard(product: product),
                  const SizedBox(height: 20),

                  // Deskripsi Koleksi
                  const Text(
                    'Tentang Koleksi Ini',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['tentang_koleksi'] ?? '-',
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF4C6656), height: 1.45),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(product),
    );
  }

  // --- KOMPONEN LOKAL ---

  /// Kartu merchant = Bank Sampah Ibu (baris dengan is_utama == true di database).
  Widget _buildMerchantSection() {
    return FutureBuilder<ApiResponse>(
      future: _futureBank,
      builder: (context, snapshot) {
        final raw = snapshot.data?.data;
        if (raw is! List) return const SizedBox.shrink();

        final bank = raw
            .map((e) => BankSampah.fromJson(Map<String, dynamic>.from(e as Map)))
            .where((b) => b.isUtama)
            .firstOrNull;

        if (bank == null) return const SizedBox.shrink();

        return MerchantCard(
          namaToko: bank.nama,
          lokasiToko: bank.kecamatan ?? 'Jember, Jawa Timur',
          latitude: bank.latitude,
          longitude: bank.longitude,
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkGreen),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Detail Produk',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: _isFavorite ? Colors.redAccent : AppColors.darkGreen,
          ),
          onPressed: () => setState(() => _isFavorite = !_isFavorite),
        ),
      ],
    );
  }

  Widget _buildImageGallery(String? imageUrl) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1.08,
          child: imageUrl != null
              ? Image.network(imageUrl, fit: BoxFit.cover)
              : Container(color: AppColors.mintSoft, child: const Icon(Icons.image, size: 60)),
        ),
        Positioned(
          right: 14,
          bottom: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.darkGreen.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '● $_currentImageIndex/4',
              style: const TextStyle(color: AppColors.limeAccent, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  String _formatRupiah(int nominal) {
    return nominal.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Widget _buildPricingAndTitle(Map<String, dynamic> product) {
    // 1. Ekstraksi data
    final int hargaAsli = int.tryParse(product['harga']?.toString() ?? '0') ?? 0;
    final double diskonPersen = double.tryParse(product['diskon_persen']?.toString() ?? '0') ?? 0.0;
    final int hargaFinal = diskonPersen > 0
        ? (hargaAsli - (hargaAsli * (diskonPersen / 100))).round()
        : hargaAsli;

    final String namaProduk = product['nama_product'] ?? product['nama_produk'] ?? 'Nama Produk';
    final List<dynamic> grosirList = product['grosir'] as List<dynamic>? ?? [];
    
    // 2. Ekstraksi Terjual & Stok dari API
    final int terjual = int.tryParse(product['terjual']?.toString() ?? '0') ?? 0;
    final int stok = int.tryParse(product['jumlah']?.toString() ?? '0') ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Rp ${_formatRupiah(hargaFinal)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.darkGreen),
            ),
            if (diskonPersen > 0) ...[
              const SizedBox(width: 10),
              Text(
                'Rp ${_formatRupiah(hargaAsli)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6F5E1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${diskonPersen.toInt()}% OFF',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E8850),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          namaProduk,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkGreen, height: 1.3),
        ),
        const SizedBox(height: 8),
        
        // Menampilkan Info Terjual dan Stok Tersedia
        Text(
          'Terjual $terjual • $stok Produk Tersedia',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
        ),

        if (grosirList.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: grosirList.map((g) {
              final minQty = g['min_qty'] ?? 0;
              final disc = g['diskon_persen'] ?? 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFCC80)),
                ),
                child: Text(
                  'Beli $minQty+ Disc $disc%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE65100),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomActionBar(Map<String, dynamic> product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, -3))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  // 1. Masukkan produk ke keranjang (Panggil SATU KALI saja)
                  final bool berhasil = await CartService.tambahProduk(
                    product,
                    context: context,
                  );
                  
                  // 2. Gunakan pengecekan "mounted" sebelum menggunakan context
                  if (!mounted || !berhasil) return;

                  // 3. Beri notifikasi singkat
                  final nama = product['nama_product'] ?? product['nama_produk'] ?? 'Produk';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$nama ditambahkan ke keranjang!'),
                      duration: const Duration(milliseconds: 800),
                      backgroundColor: AppColors.darkGreen,
                    ),
                  );

                  // 4. Pindah langsung ke halaman keranjang belanja
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HalamanKeranjang()),
                  );
                },
                icon: const Icon(Icons.bolt_rounded, color: AppColors.limeAccent, size: 18),
                label: const Text('Beli Sekarang', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}