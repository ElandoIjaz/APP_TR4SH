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
    
    // Ekstraksi data dari API Laravel (Disempurnakan)
    final String namaProduk = product['nama_product'] ?? 'Tanpa Nama'; // Menggunakan nama_product
    final int harga = int.tryParse(product['harga'].toString()) ?? 0;
    
    // Penanganan URL Gambar yang aman
    final String fotoUrl = product['foto'] ?? 'https://via.placeholder.com/150';

    // Dummy data untuk mempertahankan desain UI aslimu
    const String badgeDummy = 'Eco Friendly';
    const String materialDummy = 'Upcycled Material';
    const double ratingDummy = 4.8;
    const int reviewCountDummy = 120;

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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.15,
                    child: Image.network(
                      fotoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.mintSoft,
                        child: const Icon(Icons.inventory_2_outlined, color: AppColors.darkGreen, size: 36),
                      ),
                    ),
                  ),

                  // Top-Left Category Badge (Dummy)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: badgeDummy == 'Eco Friendly'
                            ? Colors.white.withValues(alpha: 0.9)
                            : AppColors.darkGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
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
                          _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 16,
                          color: _isFavorite ? Colors.redAccent : AppColors.darkGreen,
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
                        // Material Tag (Dummy)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F6EE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.recycling_rounded,
                                size: 10,
                                color: Color(0xFF1E8850),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                materialDummy,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E8850),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Rating Row (Dummy)
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFF9A825),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '$ratingDummy',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkGreen,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '($reviewCountDummy)',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
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
                      children: [
                        Expanded(
                          child: Text(
                            'Rp${_formatPrice(harga)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.darkGreen,
                            ),
                            overflow: TextOverflow.ellipsis,
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