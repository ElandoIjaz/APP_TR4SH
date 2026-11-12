import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class CardStatistikAkun extends StatelessWidget {
  final String totalSetoran;
  final String sampahTerkumpul;

  const CardStatistikAkun({
    super.key,
    required this.totalSetoran,
    required this.sampahTerkumpul,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F4733),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Stat 1: Total Kali Setoran
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.recycling_rounded,
                      size: 18,
                      color: AppColors.limeAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      totalSetoran,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.limeAccent,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Frekuensi Setoran',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFFD2E8DB),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 42, width: 1.5, color: Colors.white24),

          // Stat 2: Total Sampah (Kg)
          Expanded(
            child: Column(
              children: [
                Text(
                  sampahTerkumpul,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Total Sampah Disetor',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, color: Color(0xFFD2E8DB)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}