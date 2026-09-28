import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class SectionWawasanKomunitas extends StatelessWidget {
  final VoidCallback onSeeAllTap;
  final VoidCallback onCardQnATap;
  final VoidCallback onCardKreasiTap;

  const SectionWawasanKomunitas({
    super.key,
    required this.onSeeAllTap,
    required this.onCardQnATap,
    required this.onCardKreasiTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.groups_outlined,
                    size: 20,
                    color: AppColors.darkGreen,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Wawasan Komunitas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onSeeAllTap,
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Semua >',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E8850),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Card 1: Tanya Jawab / Q&A ──
          InkWell(
            onTap: onCardQnATap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Category Tag & Verified Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD8F4E4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Tanya Jawab',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B6B44),
                          ),
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: Color(0xFF2E9B5F),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Jawaban Terverifikasi',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E9B5F),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Question Title
                  const Text(
                    'Apakah sampah dapat berguna kembali?',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Snippet / Preview
                  const Text(
                    'Tentu! Lebih dari 78% sampah an-organik rumah tangga dapat dikonversi menjadi filament 3D printer atau pot bibit mandiri dengan teknik shredder sederhana...',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF5E7569),
                      height: 1.35,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Bottom Author & Replies Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Budi Prakoso • Komunitas Depok',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: const [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '45 balasan',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Card 2: Kreasi Daur Ulang Showcase ──
          InkWell(
            onTap: onCardKreasiTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pill Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD8F4E4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Kreasi Daur Ulang',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B6B44),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Title
                        const Text(
                          'Daripada tidak digunakan kembali, ...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkGreen,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Snippet
                        const Text(
                          'Ide sulap tutup botol HDPE jadi tatakan gelas marmer minimalis yang...',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF5E7569),
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 10),

                        // Views Counter
                        Row(
                          children: const [
                            Icon(
                              Icons.visibility_outlined,
                              size: 13,
                              color: AppColors.textMuted,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '892 dilihat',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Right Image Thumbnail with DIY badge
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/images/konten_diy_coaster.jpg',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            color: AppColors.mintSoft,
                            child: const Icon(Icons.coffee_rounded, color: AppColors.darkGreen),
                          ),
                        ),
                        Positioned(
                          right: 5,
                          bottom: 5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.darkGreen,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'DIY',
                              style: TextStyle(
                                color: AppColors.limeAccent,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
