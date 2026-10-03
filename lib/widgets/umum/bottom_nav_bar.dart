import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class TrashBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const TrashBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.forestGreen,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Beranda'),
              _buildNavItem(1, Icons.storefront_outlined, 'Produk'),
              _buildNavItem(2, Icons.article_outlined, 'Konten'),
              _buildNavItem(3, Icons.local_shipping_outlined, 'Tracking'),
              _buildNavItem(4, Icons.person_rounded, 'Akun'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isActive ? 12 : 8, vertical: 4),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.limeAccent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isActive ? 24 : 22,
              color: isActive ? AppColors.limeAccent : Colors.white60,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                color: isActive ? AppColors.limeAccent : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
