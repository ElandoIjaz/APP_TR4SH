import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class SpesifikasiCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const SpesifikasiCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spesifikasi Produk',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F9F5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD6EFE1)),
          ),
          child: Column(
            children: [
              _buildSpecRow('Bahan', product['bahan'] ?? '-'),
              const Divider(height: 1, color: Color(0xFFE2EFE7)),
              _buildSpecRow('Dimensi', product['dimensi'] ?? '-'),
              const Divider(height: 1, color: Color(0xFFE2EFE7)),
              _buildSpecRow('Fitur Utama', product['fitur_utama'] ?? '-'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11.5, color: AppColors.darkGreen, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}