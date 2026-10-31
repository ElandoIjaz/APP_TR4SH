import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class DampakLingkunganCard extends StatelessWidget {
  final String plastikPet;
  final String jejakKarbon;

  const DampakLingkunganCard({
    super.key,
    required this.plastikPet,
    required this.jejakKarbon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F4EB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFC8EADB)),
      ),
      child: Column(
        children: [
          // const dipindahkan ke depan Row
          const Row(
            children: [
              Icon(Icons.recycling_rounded, color: AppColors.darkGreen, size: 20),
              SizedBox(width: 8),
              Text(
                'Dampak Lingkungan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildImpactItem('Plastik PET', plastikPet, 'Sampah didaur ulang', Icons.delete_outline_rounded),
              const SizedBox(width: 10),
              _buildImpactItem('Jejak Karbon', jejakKarbon, 'Setara emisi CO2e', Icons.trending_down_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImpactItem(String title, String value, String subtitle, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: const Color(0xFF1E8850)),
                const SizedBox(width: 4),
                Text(title, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.darkGreen)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}