import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class CardProdukGrid extends StatefulWidget {
  final Map<String, dynamic> product; // Menerima data JSON dari API
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const CardProdukGrid({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  State<CardProdukGrid> createState() => _CardProdukGridState();
}

class _CardProdukGridState extends State<CardProdukGrid> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    // Ekstraksi data dari API Laravel
    final String namaProduk =
        product['nama_product'] ??
        product['nama_produk'] ??
        product['title'] ??
        'Tanpa Nama';

    // Penanganan Harga Normal vs Harga Final (Diskon)
    final int hargaAsli =
        int.tryParse(product['harga']?.toString() ?? '0') ?? 0;
    final double diskonPersen =
        double.tryParse(product['diskon_persen']?.toString() ?? '0') ?? 0.0;
    final int hargaFinal = diskonPersen > 0
        ? (hargaAsli - (hargaAsli * (diskonPersen / 100))).round()
        : hargaAsli;

    // Terjual Riil
    final int terjualRiil =
        int.tryParse(product['terjual']?.toString() ?? '0') ?? 0;

    // Penanganan URL Gambar yang aman
    final String fotoUrl =
        product['foto'] ??
        product['gambar'] ??
        product['image'] ??
        'https://via.placeholder.com/150';

    // Dummy data untuk mempertahankan desain UI aslimu
    const String badgeDummy = 'Eco Friendly';
    const String materialDummy = 'Upcycled Material';

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image with Badges ──
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.15,
                    child: Image.network(
                      fotoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.mintSoft,
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.darkGreen,
                          size: 36,
                        ),
                      ),
                    ),
                  ),

                  // Top-Left Category Badge (Dummy)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: badgeDummy == 'Eco Friendly'
                            ? Colors.white.withValues(alpha: 0.9)
                            : AppColors.darkGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        badgeDummy,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: badgeDummy == 'Eco Friendly'
                              ? AppColors.darkGreen
                              : AppColors.limeAccent,
                        ),
                      ),
                    ),
                  ),

                  // Top-Right Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isFavorite = !_isFavorite;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                          color: _isFavorite
                              ? Colors.redAccent
                              : AppColors.darkGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Product Details ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Material Tag
                        // Material Tag
                        Wrap(
                          spacing: 4, // Jarak horizontal antar badge
                          runSpacing:
                              4, // Jarak vertikal jika badge turun baris
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F6EE),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.recycling_rounded,
                                    size: 10,
                                    color: Color(0xFF1E8850),
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    materialDummy, // "Upcycled Material"
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E8850),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Tambahkan indikator diskon di katalog depan jika ada
                            if (diskonPersen > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${diskonPersen.toInt()}% OFF',
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        // Status Terjual Menggunakan Data API Riil
                        Text(
                          'Terjual $terjualRiil',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Title dari API
                        Text(
                          namaProduk,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkGreen,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // Price dari API & Add to Cart Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Jika ada diskon, tampilkan harga coret tipis di atasnya
                              if (diskonPersen > 0)
                                Text(
                                  'Rp${_formatPrice(hargaAsli)}',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    color: AppColors.textMuted,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                'Rp${_formatPrice(hargaFinal)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.darkGreen,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onAddToCart,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: AppColors.limeAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              size: 16,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi bawaanmu tetap dipertahankan
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
