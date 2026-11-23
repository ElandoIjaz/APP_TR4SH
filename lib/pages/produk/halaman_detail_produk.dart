import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/data/cart_service.dart';
import 'package:test23/data/models/bank_sampah_model.dart';
import 'package:test23/data/models/produk_model.dart';
import 'package:test23/pages/produk/halaman_keranjang.dart';
import 'package:test23/widgets/produk/dampak_lingkungan_card.dart';
import 'package:test23/widgets/produk/merchant_card.dart';
import 'package:test23/widgets/produk/spesifikasi_card.dart';

class HalamanDetailProduk extends StatefulWidget {
  final ProdukModel productData;

  const HalamanDetailProduk({
    super.key,
    required this.productData,
  });

  @override
  State<HalamanDetailProduk> createState() => _HalamanDetailProdukState();
}

class _HalamanDetailProdukState extends State<HalamanDetailProduk> {
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
            _buildImageGallery(product.foto),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPricingAndTitle(product),
                  const SizedBox(height: 18),

                  DampakLingkunganCard(
                    plastikPet: product.plastikPet,
                    jejakKarbon: product.jejakKarbon,
                  ),
                  const SizedBox(height: 18),

                  _buildMerchantSection(),
                  const SizedBox(height: 20),

                  SpesifikasiCard(product: product),
                  const SizedBox(height: 20),

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
                    product.tentangKoleksi,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF4C6656),
                      height: 1.45,
                    ),
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
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.darkGreen,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildImageGallery(String imageUrl) {
    return AspectRatio(
      aspectRatio: 1.08,
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.mintSoft,
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.darkGreen,
                  size: 64,
                ),
              ),
            )
          : Container(
              color: AppColors.mintSoft,
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.darkGreen,
                size: 64,
              ),
            ),
    );
  }

  String _formatRupiah(int nominal) {
    return nominal.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Widget _buildPricingAndTitle(ProdukModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Rp ${_formatRupiah(product.hargaFinal)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.darkGreen,
              ),
            ),
            if (product.adaDiskon) ...[
              const SizedBox(width: 10),
              Text(
                'Rp ${_formatRupiah(product.harga)}',
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
                  '${product.diskonPersen.toInt()}% OFF',
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
          product.namaProduk,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGreen,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Terjual ${product.terjual} • ${product.stok} Produk Tersedia',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (product.grosir.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: product.grosir.map((g) {
              final discText = g.diskonPersen % 1 == 0
                  ? '${g.diskonPersen.toInt()}'
                  : '${g.diskonPersen}';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFCC80)),
                ),
                child: Text(
                  'Beli ${g.minQty}+ Disc $discText%',
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

  Widget _buildBottomActionBar(ProdukModel product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  final bool berhasil = await CartService.tambahProduk(
                    product.toCartMap(),
                    context: context,
                  );

                  if (!mounted || !berhasil) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${product.namaProduk} ditambahkan ke keranjang!',
                      ),
                      duration: const Duration(milliseconds: 800),
                      backgroundColor: AppColors.darkGreen,
                    ),
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HalamanKeranjang()),
                  );
                },
                icon: const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.limeAccent,
                  size: 18,
                ),
                label: const Text(
                  'Beli Sekarang',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}