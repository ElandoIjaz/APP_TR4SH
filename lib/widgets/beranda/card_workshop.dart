import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class CardWorkshop extends StatelessWidget {
  final VoidCallback onDaftarTap;
  final String date;
  final String title;
  final String description;

  const CardWorkshop({
    super.key,
    required this.onDaftarTap,
    this.date = 'Minggu, 27 September 2026',
    this.title = 'KREASI LILIN DARI LIMBAH\nMINYAK',
    this.description = 'Ubah jelantah dapurmu menjadi lilin aromaterapi ramah lingkungan bernilai jual.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F4733),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background organic leaf pattern
          const Positioned(
            right: -25,
            bottom: -30,
            child: Opacity(
              opacity: 0.15,
              child: Icon(
                Icons.spa_rounded,
                size: 140,
                color: Colors.white,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Row
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: AppColors.limeAccent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    date,
                    style: const TextStyle(
                      color: AppColors.limeAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Title
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 6),

              // Description
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFFD2E8DB),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 16),

              // Button
              ElevatedButton(
                onPressed: onDaftarTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.limeAccent,
                  foregroundColor: AppColors.darkGreen,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Daftar Workshop',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
