import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class BannerKirimSampah extends StatelessWidget {
  final VoidCallback onSetorTap;

  const BannerKirimSampah({super.key, required this.onSetorTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE5F5EC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFD0ECDC), width: 1.2),
        ),
        child: Row(
          children: [
            // Left Circle Icon
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.darkGreen,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.recycling_rounded,
                  color: AppColors.limeAccent,
                  size: 24,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Middle Texts
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Kirim Sampah Anda',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Turunkan sampah pilah dengan poin belanja.',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF4C6656),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Right Button: Setor Sekarang
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onSetorTap,
              child: const Text(
                'Setor Sekarang',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
