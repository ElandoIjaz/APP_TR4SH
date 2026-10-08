import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class CardStatistikAkun extends StatelessWidget {
  final String sampahTerkumpul;
  final String poinHijau;
  final String misiSelesai;

  const CardStatistikAkun({
    super.key,
    this.sampahTerkumpul = '12.5 kg',
    this.poinHijau = '5 Poin',
    this.misiSelesai = '3 Misi',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
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
        children: [
          // Stat 1: Sampah Terkumpul
          Expanded(
            child: Column(
              children: [
                Text(
                  sampahTerkumpul,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.limeAccent,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sampah\nTerkumpul',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFFD2E8DB),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 38, width: 1, color: Colors.white24),

          // Stat 2: Poin Hijau
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.eco_rounded,
                      size: 16,
                      color: AppColors.limeAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      poinHijau,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.limeAccent,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Poin Hijau',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10.5, color: Color(0xFFD2E8DB)),
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 38, width: 1, color: Colors.white24),

          // Stat 3: Misi Selesai
          Expanded(
            child: Column(
              children: [
                Text(
                  misiSelesai,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Misi Selesai',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10.5, color: Color(0xFFD2E8DB)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
