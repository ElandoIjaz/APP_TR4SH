import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class BannerKontributorKonten extends StatelessWidget {
  final VoidCallback onBerbagiIdeTap;

  const BannerKontributorKonten({super.key, required this.onBerbagiIdeTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF083523),
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D4330), Color(0xFF072B1C)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D4330).withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Accent Label
            const Text(
              'TERTARIK JADI KONTRIBUTOR?',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.limeAccent,
                letterSpacing: 0.8,
              ),
            ),

            const SizedBox(height: 6),

            // Main Title
            const Text(
              'KIRIM KONTEN ANDA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),

            const SizedBox(height: 6),

            // Subtitle Description
            Text(
              'Jadilah Penggerak #PeduliSampah dan dapatkan EcoPoints untuk setiap karya sirkular terverifikasi.',
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.white.withValues(alpha: 0.78),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 18),

            // CTA Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.limeAccent,
                  foregroundColor: AppColors.darkGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                onPressed: onBerbagiIdeTap,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Mulai Berbagi Ide',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: AppColors.darkGreen,
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
}
