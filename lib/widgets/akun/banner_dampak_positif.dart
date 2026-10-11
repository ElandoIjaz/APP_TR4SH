import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class BannerDampakPositif extends StatelessWidget {
  final String sampahDikurangi;
  final String reduksiCO2;

  const BannerDampakPositif({
    super.key,
    this.sampahDikurangi = 'Total 12.5 kg sampah berhasil dikurangi dari TPA',
    this.reduksiCO2 = 'Setara 18.2 kg reduksi CO2e',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD8F4E6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC0EAD3)),
      ),
      child: Row(
        children: [
          // Globe / Earth Icon Box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.darkGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.public_rounded,
              color: AppColors.limeAccent,
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DAMPAK POSITIFMU',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF266147),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sampahDikurangi,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.eco_rounded,
                        size: 13,
                        color: Color(0xFF1E8850),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reduksiCO2,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E8850),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
