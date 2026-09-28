import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class CardTrackingChart extends StatefulWidget {
  final String totalDisetor;
  final String trendPercent;
  final ValueChanged<String>? onCategoryFilterChanged;

  const CardTrackingChart({
    super.key,
    this.totalDisetor = '14.8 kg',
    this.trendPercent = '+28% dari minggu lalu',
    this.onCategoryFilterChanged,
  });

  @override
  State<CardTrackingChart> createState() => _CardTrackingChartState();
}

class _CardTrackingChartState extends State<CardTrackingChart> {
  int _selectedFilterIndex = 0;

  final List<Map<String, dynamic>> _filters = [
    {'name': 'Botol Plastik', 'icon': Icons.recycling_rounded},
    {'name': 'Kertas Bekas', 'icon': Icons.description_outlined},
    {'name': 'Baterai (B3)', 'icon': Icons.battery_charging_full_rounded},
    {'name': 'Bungkus Kaleng', 'icon': Icons.takeout_dining_outlined},
  ];

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
          // Header Row with Title & Graph Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Riwayat Setor Sampah',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tren setoran limbah daur ulangmu',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.mintSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  size: 18,
                  color: AppColors.darkGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Total Metric + Trend Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Disetor:',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.totalDisetor,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkGreen,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
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
                      widget.trendPercent,
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

          const SizedBox(height: 16),

          // ── Curved Line Chart ──
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: _CurvedLineChartPainter(),
            ),
          ),

          const SizedBox(height: 6),

          // X-Axis Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Sen - Sel', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
              Text('Rab - Kam', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
              Text('Jum - Sab', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
              Text('Minggu', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
            ],
          ),

          const SizedBox(height: 16),

          // ── Filter Chips 2x2 Row ──
          Row(
            children: [
              _buildFilterChip(0),
              const SizedBox(width: 8),
              _buildFilterChip(1),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildFilterChip(2),
              const SizedBox(width: 8),
              _buildFilterChip(3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index) {
    final item = _filters[index];
    final bool isSelected = _selectedFilterIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilterIndex = index;
          });
          if (widget.onCategoryFilterChanged != null) {
            widget.onCategoryFilterChanged!(item['name'] as String);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE8F6ED) : const Color(0xFFF9FCFA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.darkGreen : const Color(0xFFE2EFE7),
              width: isSelected ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item['icon'] as IconData,
                size: 14,
                color: isSelected ? AppColors.darkGreen : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item['name'] as String,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppColors.darkGreen : const Color(0xFF334A3E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurvedLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Define 4 Key Points matching the mockup
    final p0 = Offset(w * 0.08, h * 0.72);
    final p1 = Offset(w * 0.38, h * 0.52);
    final p2 = Offset(w * 0.68, h * 0.25); // Peak point (Jum-Sab)
    final p3 = Offset(w * 0.94, h * 0.48);

    // Baseline grid dashed lines
    final gridPaint = Paint()
      ..color = const Color(0xFFEAF2ED)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, h * 0.25), Offset(w, h * 0.25), gridPaint);
    canvas.drawLine(Offset(0, h * 0.52), Offset(w, h * 0.52), gridPaint);
    canvas.drawLine(Offset(0, h * 0.72), Offset(w, h * 0.72), gridPaint);

    // Create Smooth Curved Path
    final path = Path();
    path.moveTo(p0.dx, p0.dy);
    path.cubicTo(w * 0.22, h * 0.65, w * 0.28, h * 0.55, p1.dx, p1.dy);
    path.cubicTo(w * 0.48, h * 0.48, w * 0.55, h * 0.25, p2.dx, p2.dy);
    path.cubicTo(w * 0.78, h * 0.25, w * 0.86, h * 0.38, p3.dx, p3.dy);

    // Gradient Fill under Path
    final fillPath = Path.from(path)
      ..lineTo(p3.dx, h)
      ..lineTo(p0.dx, h)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF0D4330).withValues(alpha: 0.18),
          const Color(0xFF0D4330).withValues(alpha: 0.02),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Stroke Path
    final strokePaint = Paint()
      ..color = AppColors.darkGreen
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // Draw Normal Dots
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = AppColors.darkGreen
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (final pt in [p0, p1, p3]) {
      canvas.drawCircle(pt, 5, dotPaint);
      canvas.drawCircle(pt, 5, dotBorderPaint);
    }

    // Draw Peak Highlight Dot (p2)
    final peakDotPaint = Paint()
      ..color = AppColors.limeAccent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(p2, 6, peakDotPaint);
    canvas.drawCircle(p2, 6, dotBorderPaint);

    // Tooltip Badge above Peak Dot: "● 4.2 kg"
    final tooltipOffset = Offset(p2.dx - 32, p2.dy - 32);
    final tooltipRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tooltipOffset.dx, tooltipOffset.dy, 64, 22),
      const Radius.circular(12),
    );
    final tooltipBgPaint = Paint()
      ..color = AppColors.darkGreen
      ..style = PaintingStyle.fill;
    canvas.drawRRect(tooltipRRect, tooltipBgPaint);

    // Small green dot inside tooltip
    final badgeDotPaint = Paint()
      ..color = AppColors.limeAccent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(tooltipOffset.dx + 12, tooltipOffset.dy + 11), 3.5, badgeDotPaint);

    // Text in tooltip
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '4.2 kg',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(tooltipOffset.dx + 22, tooltipOffset.dy + 4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
