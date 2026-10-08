import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class CardBankSampah extends StatelessWidget {
  final VoidCallback onMulaiSetorTap;
  final String bonusText;

  const CardBankSampah({
    super.key,
    required this.onMulaiSetorTap,
    this.bonusText = '+150 Poin/kg',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4733), Color(0xFF093927)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background organic leaf / tree watermark
          const Positioned(
            right: -10,
            bottom: -15,
            child: Opacity(
              opacity: 0.12,
              child: Icon(
                Icons.park_rounded,
                size: 150,
                color: Colors.white,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge Bank Sampah Digital
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.limeAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.limeAccent, width: 1.2),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.recycling_rounded,
                      size: 14,
                      color: AppColors.limeAccent,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Bank Sampah Digital',
                      style: TextStyle(
                        color: AppColors.limeAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Title
              const Text(
                'Setor Sampah Jadi Berkah',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 5),

              // Subtitle
              const Text(
                'Kumpulkan poin belanja dari pilah sampah harianmu.',
                style: TextStyle(color: Color(0xFFD0E9DA), fontSize: 12),
              ),

              const SizedBox(height: 18),

              // Action button & Bonus point
              Row(
                children: [
                  ElevatedButton(
                    onPressed: onMulaiSetorTap,
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
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Mulai Setor',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: AppColors.darkGreen,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    bonusText,
                    style: const TextStyle(
                      color: AppColors.limeAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
