import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class CardRiwayatSampah extends StatefulWidget {
  final String totalWeight;
  final String targetWeight;
  final String trendBadge;
  final List<Map<String, dynamic>> chartData;

  const CardRiwayatSampah({
    super.key,
    this.totalWeight = '14.8',
    this.targetWeight = 'Target: 20 kg',
    this.trendBadge = '+28% minggu ini',
    this.chartData = const [
      {'day': 'Sen-Sel', 'val': 6.5, 'color': Color(0xFF5AB67B)},
      {'day': 'Rab-Kam', 'val': 11.2, 'color': Color(0xFF2D8053)},
      {'day': 'Jum-Sab', 'val': 14.8, 'color': Color(0xFF0D4330), 'isPeak': true},
      {'day': 'Minggu', 'val': 5.2, 'color': Color(0xFF76C993)},
    ],
  });

  @override
  State<CardRiwayatSampah> createState() => _CardRiwayatSampahState();
}

class _CardRiwayatSampahState extends State<CardRiwayatSampah> {
  int? _selectedBarIndex = 2; // Default Jum-Sab

  @override
  Widget build(BuildContext context) {
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
          // Header Row with Trend Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RIWAYAT SETOR SAMPAH',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF334A3E),
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.mintSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up_rounded, size: 14, color: Color(0xFF1E8850)),
                    const SizedBox(width: 4),
                    Text(
                      widget.trendBadge,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E8850),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),
          const Text(
            'Aktivitas Minggu Ini',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),

          const SizedBox(height: 10),

          // Total Metric + Target
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.totalWeight,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkGreen,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'kg',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E6B4E),
                    ),
                  ),
                ],
              ),
              Text(
                widget.targetWeight,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Chart Area ──
          _buildBarChartWidget(),

          const SizedBox(height: 20),

          // ── Chips / Table Breakdown 2x2 ──
          Row(
            children: [
              Expanded(
                child: _buildBreakdownChip(
                  color: AppColors.darkGreen,
                  title: 'Botol Plastik',
                  weight: '4.2 kg',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBreakdownChip(
                  color: const Color(0xFF2E8055),
                  title: 'Kertas Bekas',
                  weight: '5.1 kg',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildBreakdownChip(
                  color: const Color(0xFFE53935),
                  title: 'Baterai (B3)',
                  weight: '1.0 kg',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBreakdownChip(
                  color: const Color(0xFF75CB95),
                  title: 'Bungkus Kaleng',
                  weight: '4.15 kg',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Chart Bars Container
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(widget.chartData.length, (index) {
                final item = widget.chartData[index];
                const double maxVal = 16.0;
                final double heightRatio = (item['val'] as double) / maxVal;
                final bool isSelected = _selectedBarIndex == index;
                final bool isPeak = item['isPeak'] == true;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBarIndex = index;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Peak marker dot if highest
                      if (isPeak)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE1F829),
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(height: 12),

                      // Bar Column
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isPeak ? 46 : 42,
                        height: 90 * heightRatio,
                        decoration: BoxDecoration(
                          color: isSelected ? item['color'] : (item['color'] as Color).withValues(alpha: 0.65),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          border: isSelected ? Border.all(color: AppColors.limeAccent, width: 1.5) : null,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Baseline Line
          Container(
            height: 2,
            color: const Color(0xFFE2EFE7),
          ),
          const SizedBox(height: 8),

          // X-Axis Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(widget.chartData.length, (index) {
              final item = widget.chartData[index];
              final bool isPeak = item['isPeak'] == true;

              return SizedBox(
                width: 60,
                child: Text(
                  item['day'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isPeak ? FontWeight.w800 : FontWeight.w500,
                    color: isPeak ? AppColors.darkGreen : AppColors.textMuted,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownChip({
    required Color color,
    required String title,
    required String weight,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FCFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5EFE8)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334A3E),
              ),
            ),
          ),
          Text(
            weight,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}
