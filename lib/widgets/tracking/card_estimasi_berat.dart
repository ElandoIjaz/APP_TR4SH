import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class CardEstimasiBerat extends StatefulWidget {
  final String categoryName;
  final String itemUnit;
  final double weightPerUnit;
  final int pointsPerUnit;
  final void Function(int itemCount, double totalWeight, int totalPoints)?
  onInputSampah;

  const CardEstimasiBerat({
    super.key,
    this.categoryName = 'Plastik',
    this.itemUnit = 'Botol',
    this.weightPerUnit = 0.1,
    this.pointsPerUnit = 10,
    this.onInputSampah,
  });

  @override
  State<CardEstimasiBerat> createState() => _CardEstimasiBeratState();
}

class _CardEstimasiBeratState extends State<CardEstimasiBerat> {
  int _itemCount = 5; // Default 5 items matching mockup

  void _increment() {
    setState(() {
      _itemCount++;
    });
  }

  void _decrement() {
    if (_itemCount > 1) {
      setState(() {
        _itemCount--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double totalWeight = _itemCount * widget.weightPerUnit;
    final int totalPoints = _itemCount * widget.pointsPerUnit;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ESTIMASI JUMLAH / BERAT',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.mintSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 13,
                      color: Color(0xFF1E8850),
                    ),
                    SizedBox(width: 3),
                    Text(
                      'Auto-Converted',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E8850),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Selected Item Preview Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2EFE7)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.darkGreen,
                  child: Icon(
                    Icons.hourglass_empty_rounded,
                    color: AppColors.limeAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_itemCount ${widget.itemUnit} (±${totalWeight.toStringAsFixed(1)} kg)',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Potensi Poin: +$totalPoints EcoPoints',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF266147),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Counter Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5EFE8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Minus Button
                IconButton(
                  onPressed: _decrement,
                  icon: const Icon(
                    Icons.remove,
                    size: 20,
                    color: AppColors.darkGreen,
                  ),
                  splashRadius: 20,
                ),

                // Count text
                Text(
                  '$_itemCount Item',
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),

                // Plus Button
                IconButton(
                  onPressed: _increment,
                  icon: const Icon(
                    Icons.add,
                    size: 20,
                    color: AppColors.darkGreen,
                  ),
                  splashRadius: 20,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Action Button "+ Input Sampah"
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (widget.onInputSampah != null) {
                  widget.onInputSampah!(_itemCount, totalWeight, totalPoints);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Berhasil mencatat $_itemCount ${widget.itemUnit} (+$totalPoints EcoPoints)!',
                      ),
                      backgroundColor: AppColors.darkGreen,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.limeAccent,
                foregroundColor: AppColors.darkGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    size: 18,
                    color: AppColors.darkGreen,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '+ Input Sampah',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
