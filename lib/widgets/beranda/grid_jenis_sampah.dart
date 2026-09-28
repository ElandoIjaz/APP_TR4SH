import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class GridJenisSampah extends StatelessWidget {
  final void Function(String title, String badge, String subtitle, String description, IconData icon) onCategoryTap;

  const GridJenisSampah({
    super.key,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kenali Jenis Sampah',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 12),

          // 2x2 Grid
          Row(
            children: [
              Expanded(
                child: _buildCategoryCard(
                  icon: Icons.water_drop_outlined,
                  title: 'Plastik',
                  subtitle: 'Botol & Kresek',
                  badge: '100% Recyclable',
                  badgeBg: const Color(0xFFD8F4E4),
                  badgeTextColor: const Color(0xFF1E8850),
                  onTap: () => onCategoryTap(
                    'Plastik',
                    '100% Recyclable',
                    'Botol & Kresek',
                    'Sampah plastik seperti botol air mineral (PET) dan tutup botol (HDPE) bernilai tinggi. Pastikan dicuci bersih dan dikeringkan sebelum disetorkan.',
                    Icons.water_drop_outlined,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCategoryCard(
                  icon: Icons.wine_bar_rounded,
                  title: 'Kaca',
                  subtitle: 'Beling & Botol',
                  badge: 'Rapuh',
                  badgeBg: const Color(0xFFE1F5FE),
                  badgeTextColor: const Color(0xFF0288D1),
                  onTap: () => onCategoryTap(
                    'Kaca',
                    'Rapuh',
                    'Beling & Botol',
                    'Botol kecap, sirup, dan toples kaca dapat didaur ulang tanpa batas waktu. Bungkus secara aman untuk menghindari pecahan.',
                    Icons.wine_bar_rounded,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildCategoryCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'Kertas & Karton',
                  subtitle: 'Kardus & Majalah',
                  badge: 'Mudah Terurai',
                  badgeBg: const Color(0xFFE8F5E9),
                  badgeTextColor: const Color(0xFF2E7D32),
                  onTap: () => onCategoryTap(
                    'Kertas & Karton',
                    'Mudah Terurai',
                    'Kardus & Majalah',
                    'Kardus belanja online, koran, dan kertas HVS dapat diproses ulang menjadi pulp kertas baru. Hindari kertas yang basah atau berminyak.',
                    Icons.inventory_2_outlined,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCategoryCard(
                  icon: Icons.delete_outline_rounded,
                  title: 'Logam / Kaleng',
                  subtitle: 'Aluminium & Seng',
                  badge: 'Nilai Tinggi',
                  badgeBg: const Color(0xFFFFF9C4),
                  badgeTextColor: const Color(0xFFF57F17),
                  onTap: () => onCategoryTap(
                    'Logam / Kaleng',
                    'Nilai Tinggi',
                    'Aluminium & Seng',
                    'Kaleng minuman soda aluminium dan kaleng susu memiliki nilai jual tertinggi di bank sampah. Pipihkan kaleng untuk menghemat tempat.',
                    Icons.delete_outline_rounded,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeBg,
    required Color badgeTextColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon circle + Pill Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.mintSoft,
                  child: Icon(icon, color: AppColors.darkGreen, size: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),

            const SizedBox(height: 2),

            // Subtitle
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
