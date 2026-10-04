import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/pages/auth/halaman_login.dart';

class AuthRequiredModal {
  AuthRequiredModal._();

  static Future<void> show(
    BuildContext context, {
    String title = 'Akses Akun Diperlukan',
    String message = 'Fitur ini memerlukan akun TR4SH! Silakan masuk atau daftar terlebih dahulu untuk melanjutkan.',
    IconData icon = Icons.lock_outline_rounded,
    String confirmText = 'Masuk / Daftar Akun',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Drag handle indicator
            Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),

            // Icon Badge
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.mintSoft,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC0EAD3), width: 1.5),
              ),
              child: Icon(
                icon,
                color: AppColors.darkGreen,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.darkGreen,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),

            // Message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Feature Highlights Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgScreen,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2EFE7)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFeatureItem(Icons.recycling_rounded, 'Tracking\nSampah'),
                  Container(width: 1, height: 28, color: Colors.grey.shade300),
                  _buildFeatureItem(Icons.card_giftcard_rounded, 'Tukar\nPoin Hadiah'),
                  Container(width: 1, height: 28, color: Colors.grey.shade300),
                  _buildFeatureItem(Icons.video_collection_rounded, 'Upload\nKonten Edukasi'),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Primary Action Button (Login / Register)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.login_rounded, size: 20),
                label: Text(
                  confirmText,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HalamanLogin()),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Secondary Cancel / Explore Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Lanjutkan Jelajahi Aplikasi',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildFeatureItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.darkGreen),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E6B4E),
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
