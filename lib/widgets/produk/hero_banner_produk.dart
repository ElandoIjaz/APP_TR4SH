import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class HeroBannerProduk extends StatelessWidget {
  final VoidCallback onJelajahiTap;

  const HeroBannerProduk({super.key, required this.onJelajahiTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF0D4330),
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F4733), Color(0xFF083323)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D4330).withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Left Column: Texts and CTA ──
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Impact Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.limeAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.eco_outlined,
                          size: 11,
                          color: AppColors.limeAccent,
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '1.200+ kg sampah terdaur ulang',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.limeAccent,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Title
                  const Text(
                    'Karya Daur Ulang Penuh Makna',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Subtitle
                  Text(
                    'Dukung pengrajin lokal kurangi limbah bumi dengan belanja berdampak.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.78),
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Button Jelajahi Sekarang
                  GestureDetector(
                    onTap: onJelajahiTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.limeAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Jelajahi Sekarang',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: AppColors.darkGreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ── Right Column: Circular Plant Cutout ──
            ClipOval(
              child: Image.asset(
                'assets/images/produk_banner_plant.jpg',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 90,
                  height: 90,
                  color: AppColors.mintSoft,
                  child: const Icon(
                    Icons.yard_rounded,
                    color: AppColors.darkGreen,
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
