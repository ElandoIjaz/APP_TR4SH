import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class CardTrackingChart extends StatefulWidget {
  final String totalDisetor;
  final String trendPercent;
  final ValueChanged<String>? onCategoryFilterChanged;
  final List<dynamic>? rawData;

  const CardTrackingChart({
    super.key,
    this.totalDisetor = '14.8 kg',
    this.trendPercent = '+28% dari minggu lalu',
    this.onCategoryFilterChanged,
    this.rawData,
  });

  @override
  State<CardTrackingChart> createState() => _CardTrackingChartState();
}

class _CardTrackingChartState extends State<CardTrackingChart>
    with SingleTickerProviderStateMixin {
  int _selectedFilterIndex = -1; // -1 = Semua (All Categories)
  int? _inspectedIndex;

  late AnimationController _animController;
  late Animation<double> _animation;
  List<double> _prevWeights = [0.0, 0.0, 0.0, 0.0];
  List<double> _currentWeights = [1.2, 2.5, 4.2, 2.1];

  final List<Map<String, dynamic>> _filters = [
    {'name': 'Botol Plastik', 'icon': Icons.recycling_rounded},
    {'name': 'Kertas Bekas', 'icon': Icons.description_outlined},
    {'name': 'Baterai (B3)', 'icon': Icons.battery_charging_full_rounded},
    {'name': 'Bungkus Kaleng', 'icon': Icons.takeout_dining_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);

    _updateWeights(initial: true);
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant CardTrackingChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rawData != widget.rawData ||
        oldWidget.totalDisetor != widget.totalDisetor) {
      _updateWeights();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _updateWeights({bool initial = false}) {
    final newWeights = _calculateWeights(widget.rawData, _selectedFilterIndex);
    if (!initial) {
      _prevWeights = List.from(_currentWeights);
      _currentWeights = newWeights;
      _animController.forward(from: 0.0);
    } else {
      _prevWeights = List.from(newWeights);
      _currentWeights = newWeights;
    }
  }

  List<double> _calculateWeights(List<dynamic>? records, int filterIndex) {
    // Jika tidak ada data riil, gunakan grafik dasar default
    if (records == null || records.isEmpty) {
      return [1.2, 2.5, 4.2, 2.1];
    }

    double senSel = 0.0;
    double rabKam = 0.0;
    double jumSab = 0.0;
    double minggu = 0.0;

    String? filterName;
    if (filterIndex >= 0 && filterIndex < _filters.length) {
      filterName = _filters[filterIndex]['name'] as String;
    }

    for (final item in records) {
      if (item is! Map) continue;

      if (filterName != null) {
        final cat = (item['nama_kategori'] ?? '').toString().toLowerCase();
        final jenis = (item['jenis_sampah'] ?? '').toString().toLowerCase();
        final f = filterName.toLowerCase();

        bool match = false;
        if (f.contains('plastik') &&
            (cat.contains('plastik') || jenis.contains('plastik') || jenis.contains('botol'))) {
          match = true;
        } else if (f.contains('kertas') &&
            (cat.contains('kertas') || jenis.contains('kertas') || jenis.contains('karton') || jenis.contains('dus'))) {
          match = true;
        } else if (f.contains('kaleng') &&
            (cat.contains('logam') || cat.contains('kaleng') || jenis.contains('kaleng') || jenis.contains('logam'))) {
          match = true;
        } else if (f.contains('baterai') &&
            (cat.contains('baterai') || cat.contains('b3') || cat.contains('kaca') || jenis.contains('baterai') || jenis.contains('kaca'))) {
          match = true;
        }

        if (!match) continue;
      }

      final weight = double.tryParse(item['jumlah']?.toString() ?? '0') ?? 0.0;
      DateTime dt = DateTime.now();
      if (item['created_at'] != null) {
        try {
          dt = DateTime.parse(item['created_at'].toString()).toLocal();
        } catch (_) {}
      }

      final wd = dt.weekday; // 1 = Senin, 7 = Minggu
      if (wd == DateTime.monday || wd == DateTime.tuesday) {
        senSel += weight;
      } else if (wd == DateTime.wednesday || wd == DateTime.thursday) {
        rabKam += weight;
      } else if (wd == DateTime.friday || wd == DateTime.saturday) {
        jumSab += weight;
      } else if (wd == DateTime.sunday) {
        minggu += weight;
      }
    }

    return [
      double.parse(senSel.toStringAsFixed(1)),
      double.parse(rabKam.toStringAsFixed(1)),
      double.parse(jumSab.toStringAsFixed(1)),
      double.parse(minggu.toStringAsFixed(1)),
    ];
  }

  int _findPeakIndex(List<double> weights) {
    int maxIdx = 2; // Default Jum - Sab
    double maxW = -1;
    for (int i = 0; i < weights.length; i++) {
      if (weights[i] > maxW) {
        maxW = weights[i];
        maxIdx = i;
      }
    }
    return maxIdx;
  }

  @override
  Widget build(BuildContext context) {
    final hasRealData = widget.rawData != null && widget.rawData!.isNotEmpty;
    final totalSum = _currentWeights.fold(0.0, (a, b) => a + b);

    String displayedTotal;
    String displayedTrend;

    if (hasRealData) {
      if (_selectedFilterIndex >= 0) {
        displayedTotal = '${totalSum.toStringAsFixed(1)} kg';
        displayedTrend = '+${_countFilteredRecords()} setoran';
      } else {
        displayedTotal = widget.totalDisetor;
        displayedTrend = widget.trendPercent;
      }
    } else {
      displayedTotal = widget.totalDisetor;
      displayedTrend = widget.trendPercent;
    }

    final peakIdx = _findPeakIndex(_currentWeights);
    final activeIndex = _inspectedIndex ?? peakIdx;

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
                children: [
                  const Text(
                    'Riwayat Setor Sampah',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedFilterIndex >= 0
                        ? 'Kategori: ${_filters[_selectedFilterIndex]['name']}'
                        : 'Tren setoran limbah daur ulangmu',
                    style: const TextStyle(
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
                  Text(
                    _selectedFilterIndex >= 0
                        ? 'Total ${_filters[_selectedFilterIndex]['name']}:'
                        : 'Total Disetor:',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayedTotal,
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
                      displayedTrend,
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

          // ── Interactive Curved Line Chart ──
          GestureDetector(
            onTapUp: (details) {
              final box = context.findRenderObject() as RenderBox?;
              final w = box != null ? box.size.width - 40 : 300.0;
              final dx = details.localPosition.dx;
              final ratios = [0.08, 0.38, 0.68, 0.94];
              int closest = 0;
              double minDiff = 999999;
              for (int i = 0; i < 4; i++) {
                final diff = (dx - (w * ratios[i])).abs();
                if (diff < minDiff) {
                  minDiff = diff;
                  closest = i;
                }
              }
              setState(() {
                _inspectedIndex = closest;
              });
            },
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _CurvedLineChartPainter(
                      weights: _currentWeights,
                      oldWeights: _prevWeights,
                      animationProgress: _animation.value,
                      activeIndex: activeIndex,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 6),

          // X-Axis Labels (Interactive)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAxisLabel(0, 'Sen - Sel', activeIndex == 0),
              _buildAxisLabel(1, 'Rab - Kam', activeIndex == 1),
              _buildAxisLabel(2, 'Jum - Sab', activeIndex == 2),
              _buildAxisLabel(3, 'Minggu', activeIndex == 3),
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

  int _countFilteredRecords() {
    if (widget.rawData == null || _selectedFilterIndex < 0) return 0;
    final f = _filters[_selectedFilterIndex]['name'].toString().toLowerCase();
    int count = 0;
    for (final item in widget.rawData!) {
      if (item is! Map) continue;
      final cat = (item['nama_kategori'] ?? '').toString().toLowerCase();
      final jenis = (item['jenis_sampah'] ?? '').toString().toLowerCase();

      bool match = false;
      if (f.contains('plastik') && (cat.contains('plastik') || jenis.contains('plastik') || jenis.contains('botol'))) {
        match = true;
      } else if (f.contains('kertas') && (cat.contains('kertas') || jenis.contains('kertas') || jenis.contains('karton') || jenis.contains('dus'))) {
        match = true;
      } else if (f.contains('kaleng') && (cat.contains('logam') || cat.contains('kaleng') || jenis.contains('kaleng') || jenis.contains('logam'))) {
        match = true;
      } else if (f.contains('baterai') && (cat.contains('baterai') || cat.contains('b3') || cat.contains('kaca') || jenis.contains('baterai') || jenis.contains('kaca'))) {
        match = true;
      }
      if (match) count++;
    }
    return count;
  }

  Widget _buildAxisLabel(int index, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _inspectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.mintSoft,
                borderRadius: BorderRadius.circular(6),
              )
            : null,
        child: Text(
          label,
          style: TextStyle(
            fontSize: isActive ? 11 : 10.5,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.darkGreen : AppColors.textMuted,
          ),
        ),
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
            if (_selectedFilterIndex == index) {
              _selectedFilterIndex = -1; // Toggle off to show all
            } else {
              _selectedFilterIndex = index;
            }
            _inspectedIndex = null;
            _updateWeights();
          });
          if (widget.onCategoryFilterChanged != null) {
            widget.onCategoryFilterChanged!(
              _selectedFilterIndex >= 0 ? item['name'] as String : 'Semua',
            );
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
  final List<double> weights;
  final List<double>? oldWeights;
  final double animationProgress;
  final int activeIndex;

  _CurvedLineChartPainter({
    required this.weights,
    this.oldWeights,
    this.animationProgress = 1.0,
    required this.activeIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Interpolasi animasi data jika ada transisi filter
    final List<double> currentW = List.generate(4, (i) {
      final target = i < weights.length ? weights[i] : 0.0;
      final prev = (oldWeights != null && i < oldWeights!.length) ? oldWeights![i] : target;
      return prev + (target - prev) * animationProgress;
    });

    final x0 = w * 0.08;
    final x1 = w * 0.38;
    final x2 = w * 0.68;
    final x3 = w * 0.94;

    final yBottom = h * 0.74;
    final yTop = h * 0.28;

    double maxVal = currentW.reduce((a, b) => a > b ? a : b);

    // Hitung posisi Y untuk masing-masing titik
    final List<double> yPoints = List.generate(4, (i) {
      if (maxVal <= 0.0) return yBottom;
      final ratio = (currentW[i] / maxVal).clamp(0.0, 1.0);
      return yBottom - (ratio * (yBottom - yTop));
    });

    final p0 = Offset(x0, yPoints[0]);
    final p1 = Offset(x1, yPoints[1]);
    final p2 = Offset(x2, yPoints[2]);
    final p3 = Offset(x3, yPoints[3]);
    final points = [p0, p1, p2, p3];

    // Garis bantu horizontal grid
    final gridPaint = Paint()
      ..color = const Color(0xFFEAF2ED)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, yTop), Offset(w, yTop), gridPaint);
    canvas.drawLine(Offset(0, (yTop + yBottom) / 2), Offset(w, (yTop + yBottom) / 2), gridPaint);
    canvas.drawLine(Offset(0, yBottom), Offset(w, yBottom), gridPaint);

    // Buat kurva halus (Smooth Cubic Bezier)
    final path = Path();
    path.moveTo(p0.dx, p0.dy);
    path.cubicTo(
      p0.dx + (p1.dx - p0.dx) * 0.5, p0.dy,
      p0.dx + (p1.dx - p0.dx) * 0.5, p1.dy,
      p1.dx, p1.dy,
    );
    path.cubicTo(
      p1.dx + (p2.dx - p1.dx) * 0.5, p1.dy,
      p1.dx + (p2.dx - p1.dx) * 0.5, p2.dy,
      p2.dx, p2.dy,
    );
    path.cubicTo(
      p2.dx + (p3.dx - p2.dx) * 0.5, p2.dy,
      p2.dx + (p3.dx - p2.dx) * 0.5, p3.dy,
      p3.dx, p3.dy,
    );

    // Gradient fill di bawah garis
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

    // Stroke garis grafik
    final strokePaint = Paint()
      ..color = AppColors.darkGreen
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // Gambar titik koordinat pada grafik
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = AppColors.darkGreen
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final peakDotPaint = Paint()
      ..color = AppColors.limeAccent
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final pt = points[i];
      if (i == activeIndex) {
        canvas.drawCircle(pt, 6, peakDotPaint);
        canvas.drawCircle(pt, 6, dotBorderPaint);
      } else {
        canvas.drawCircle(pt, 4.5, dotPaint);
        canvas.drawCircle(pt, 4.5, dotBorderPaint);
      }
    }

    // Tooltip interaktif di atas titik aktif
    final activePt = points[activeIndex];
    final activeVal = activeIndex < weights.length ? weights[activeIndex] : 0.0;
    final tooltipText = '${activeVal.toStringAsFixed(1)} kg';

    final textPainter = TextPainter(
      text: TextSpan(
        text: tooltipText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeWidth = textPainter.width + 24;
    const badgeHeight = 22.0;

    double tooltipX = activePt.dx - (badgeWidth / 2);
    if (tooltipX < 4) tooltipX = 4;
    if (tooltipX + badgeWidth > w - 4) tooltipX = w - badgeWidth - 4;
    final tooltipY = (activePt.dy - 32).clamp(4.0, h - badgeHeight - 2);

    final tooltipRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tooltipX, tooltipY, badgeWidth, badgeHeight),
      const Radius.circular(12),
    );
    final tooltipBgPaint = Paint()
      ..color = AppColors.darkGreen
      ..style = PaintingStyle.fill;
    canvas.drawRRect(tooltipRRect, tooltipBgPaint);

    // Titik kecil hijau di tooltip
    final badgeDotPaint = Paint()
      ..color = AppColors.limeAccent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(tooltipX + 9, tooltipY + (badgeHeight / 2)), 3.5, badgeDotPaint);

    // Label teks angka di tooltip
    textPainter.paint(canvas, Offset(tooltipX + 16, tooltipY + (badgeHeight - textPainter.height) / 2));
  }

  @override
  bool shouldRepaint(covariant _CurvedLineChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.activeIndex != activeIndex ||
        oldDelegate.weights != weights;
  }
}
