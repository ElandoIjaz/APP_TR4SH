import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

enum TrackingPeriodMode {
  mingguan,
  bulanan,
}

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
  TrackingPeriodMode _periodMode = TrackingPeriodMode.mingguan;
  int _selectedFilterIndex = -1; // -1 = Semua Kategori
  int? _inspectedIndex;

  late AnimationController _animController;
  late Animation<double> _animation;

  // Data bobot untuk transisi animasi
  List<double> _prevWeights = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  List<double> _currentWeights = [0.8, 1.2, 1.5, 2.0, 4.2, 3.1, 2.0];

  static const List<String> _weekLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  static const List<String> _weekFullNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  static const List<String> _monthLabels = ['Mg 1', 'Mg 2', 'Mg 3', 'Mg 4'];
  static const List<String> _monthFullNames = ['Minggu 1 (Tgl 1-7)', 'Minggu 2 (Tgl 8-14)', 'Minggu 3 (Tgl 15-21)', 'Minggu 4 (Tgl 22+)'];

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
      duration: const Duration(milliseconds: 380),
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
    final newWeights = _calculateChartWeights();
    if (!initial) {
      // Pastikan panjang array sama saat tween animasi, jika beda panjang re-init
      if (_prevWeights.length != newWeights.length) {
        _prevWeights = List.filled(newWeights.length, 0.0);
      } else {
        _prevWeights = List.from(_currentWeights);
      }
      _currentWeights = newWeights;
      _animController.forward(from: 0.0);
    } else {
      _prevWeights = List.from(newWeights);
      _currentWeights = newWeights;
    }
  }

  bool _isItemMatchFilter(dynamic item) {
    if (item is! Map) return false;
    if (_selectedFilterIndex < 0) return true;

    final filterName = _filters[_selectedFilterIndex]['name'] as String;
    final cat = (item['nama_kategori'] ?? '').toString().toLowerCase();
    final jenis = (item['jenis_sampah'] ?? '').toString().toLowerCase();
    final f = filterName.toLowerCase();

    if (f.contains('plastik') &&
        (cat.contains('plastik') || jenis.contains('plastik') || jenis.contains('botol'))) {
      return true;
    } else if (f.contains('kertas') &&
        (cat.contains('kertas') || jenis.contains('kertas') || jenis.contains('karton') || jenis.contains('dus'))) {
      return true;
    } else if (f.contains('kaleng') &&
        (cat.contains('logam') || cat.contains('kaleng') || jenis.contains('kaleng') || jenis.contains('logam'))) {
      return true;
    } else if (f.contains('baterai') &&
        (cat.contains('baterai') || cat.contains('b3') || cat.contains('kaca') || jenis.contains('baterai') || jenis.contains('kaca'))) {
      return true;
    }

    return false;
  }

  /// Menghitung total dan setoran untuk Minggu Ini dan Bulan Ini
  Map<String, dynamic> _computeSummaryMetrics() {
    final records = widget.rawData;
    if (records == null || records.isEmpty) {
      return {
        'weeklyKg': 5.0,
        'weeklyCount': 2,
        'monthlyKg': 14.8,
        'monthlyCount': 6,
        'hasData': false,
      };
    }

    final now = DateTime.now();
    // Awal minggu (Senin 00:00:00)
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final nextMonday = monday.add(const Duration(days: 7));

    double weeklyKg = 0.0;
    int weeklyCount = 0;
    double monthlyKg = 0.0;
    int monthlyCount = 0;

    for (final item in records) {
      if (!_isItemMatchFilter(item)) continue;

      final weight = double.tryParse(item['jumlah']?.toString() ?? '0') ?? 0.0;
      DateTime dt = now;
      if (item['created_at'] != null) {
        try {
          dt = DateTime.parse(item['created_at'].toString()).toLocal();
        } catch (_) {}
      }

      // Cek Minggu Ini
      if (dt.isAfter(monday.subtract(const Duration(seconds: 1))) && dt.isBefore(nextMonday)) {
        weeklyKg += weight;
        weeklyCount++;
      }

      // Cek Bulan Ini
      if (dt.year == now.year && dt.month == now.month) {
        monthlyKg += weight;
        monthlyCount++;
      }
    }

    return {
      'weeklyKg': double.parse(weeklyKg.toStringAsFixed(1)),
      'weeklyCount': weeklyCount,
      'monthlyKg': double.parse(monthlyKg.toStringAsFixed(1)),
      'monthlyCount': monthlyCount,
      'hasData': true,
    };
  }

  /// Menghitung bobot untuk setiap titik grafik (7 hari untuk Mingguan, 4 minggu untuk Bulanan)
  List<double> _calculateChartWeights() {
    final records = widget.rawData;
    if (records == null || records.isEmpty) {
      if (_periodMode == TrackingPeriodMode.mingguan) {
        return [0.8, 1.2, 1.5, 2.0, 4.2, 3.1, 2.0];
      } else {
        return [3.5, 4.2, 2.8, 4.3];
      }
    }

    final now = DateTime.now();
    if (_periodMode == TrackingPeriodMode.mingguan) {
      // 7 Hari Terpisah: Sen(0), Sel(1), Rab(2), Kam(3), Jum(4), Sab(5), Min(6)
      final List<double> dayWeights = List.filled(7, 0.0);
      final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
      final nextMonday = monday.add(const Duration(days: 7));

      for (final item in records) {
        if (!_isItemMatchFilter(item)) continue;
        final weight = double.tryParse(item['jumlah']?.toString() ?? '0') ?? 0.0;
        DateTime dt = now;
        if (item['created_at'] != null) {
          try {
            dt = DateTime.parse(item['created_at'].toString()).toLocal();
          } catch (_) {}
        }

        // Kelompokkan ke hari 1 (Senin) .. 7 (Minggu)
        if (dt.isAfter(monday.subtract(const Duration(seconds: 1))) && dt.isBefore(nextMonday)) {
          final idx = (dt.weekday - 1).clamp(0, 6);
          dayWeights[idx] += weight;
        } else {
          // Jika di luar range minggu ini, petakan weekday tetap untuk visualisasi
          final idx = (dt.weekday - 1).clamp(0, 6);
          dayWeights[idx] += weight;
        }
      }

      return dayWeights.map((w) => double.parse(w.toStringAsFixed(1))).toList();
    } else {
      // 4 Minggu dalam Bulan Ini: Mg 1, Mg 2, Mg 3, Mg 4
      final List<double> weekWeights = List.filled(4, 0.0);

      for (final item in records) {
        if (!_isItemMatchFilter(item)) continue;
        final weight = double.tryParse(item['jumlah']?.toString() ?? '0') ?? 0.0;
        DateTime dt = now;
        if (item['created_at'] != null) {
          try {
            dt = DateTime.parse(item['created_at'].toString()).toLocal();
          } catch (_) {}
        }

        final day = dt.day;
        int weekIdx = 0;
        if (day <= 7) {
          weekIdx = 0;
        } else if (day <= 14) {
          weekIdx = 1;
        } else if (day <= 21) {
          weekIdx = 2;
        } else {
          weekIdx = 3;
        }
        weekWeights[weekIdx] += weight;
      }

      return weekWeights.map((w) => double.parse(w.toStringAsFixed(1))).toList();
    }
  }

  int _findPeakIndex(List<double> weights) {
    if (weights.isEmpty) return 0;
    int maxIdx = 0;
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
    final summary = _computeSummaryMetrics();
    final double weeklyKg = summary['weeklyKg'] as double;
    final int weeklyCount = summary['weeklyCount'] as int;
    final double monthlyKg = summary['monthlyKg'] as double;
    final int monthlyCount = summary['monthlyCount'] as int;
    final bool hasData = summary['hasData'] as bool;

    final isWeekly = _periodMode == TrackingPeriodMode.mingguan;
    final activeLabels = isWeekly ? _weekLabels : _monthLabels;
    final activeFullNames = isWeekly ? _weekFullNames : _monthFullNames;

    String mainTotalText;
    String trendBadgeText;

    if (hasData) {
      if (_selectedFilterIndex >= 0) {
        final currentPeriodKg = isWeekly ? weeklyKg : monthlyKg;
        final currentPeriodCount = isWeekly ? weeklyCount : monthlyCount;
        mainTotalText = '${currentPeriodKg.toStringAsFixed(1)} kg';
        trendBadgeText = '+$currentPeriodCount setoran';
      } else {
        final currentPeriodKg = isWeekly ? weeklyKg : monthlyKg;
        final currentPeriodCount = isWeekly ? weeklyCount : monthlyCount;
        mainTotalText = '${currentPeriodKg.toStringAsFixed(1)} kg';
        trendBadgeText = '+$currentPeriodCount setoran ${isWeekly ? 'minggu ini' : 'bulan ini'}';
      }
    } else {
      mainTotalText = widget.totalDisetor;
      trendBadgeText = widget.trendPercent;
    }

    final peakIdx = _findPeakIndex(_currentWeights);
    final activeIndex = (_inspectedIndex ?? peakIdx).clamp(0, _currentWeights.length - 1);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row: Title & Period Switcher ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Riwayat Setor Sampah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedFilterIndex >= 0
                          ? 'Kategori: ${_filters[_selectedFilterIndex]['name']}'
                          : (isWeekly ? 'Tren 7 hari dalam minggu ini' : 'Tren 4 minggu dalam bulan ini'),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Segmented Toggle: Per Minggu / Per Bulan
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F6F3),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPeriodPill(
                      label: 'Per Minggu',
                      isSelected: isWeekly,
                      onTap: () {
                        if (_periodMode != TrackingPeriodMode.mingguan) {
                          setState(() {
                            _periodMode = TrackingPeriodMode.mingguan;
                            _inspectedIndex = null;
                            _updateWeights();
                          });
                        }
                      },
                    ),
                    _buildPeriodPill(
                      label: 'Per Bulan',
                      isSelected: !isWeekly,
                      onTap: () {
                        if (_periodMode != TrackingPeriodMode.bulanan) {
                          setState(() {
                            _periodMode = TrackingPeriodMode.bulanan;
                            _inspectedIndex = null;
                            _updateWeights();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Dual Summary Cards: Total Per Minggu & Per Bulan ──
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Minggu Ini',
                  weightKg: weeklyKg,
                  countSetor: weeklyCount,
                  icon: Icons.calendar_view_week_rounded,
                  isActive: isWeekly,
                  onTap: () {
                    if (_periodMode != TrackingPeriodMode.mingguan) {
                      setState(() {
                        _periodMode = TrackingPeriodMode.mingguan;
                        _inspectedIndex = null;
                        _updateWeights();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Bulan Ini',
                  weightKg: monthlyKg,
                  countSetor: monthlyCount,
                  icon: Icons.calendar_month_rounded,
                  isActive: !isWeekly,
                  onTap: () {
                    if (_periodMode != TrackingPeriodMode.bulanan) {
                      setState(() {
                        _periodMode = TrackingPeriodMode.bulanan;
                        _inspectedIndex = null;
                        _updateWeights();
                      });
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Main Total Display + Trend Badge ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedFilterIndex >= 0
                        ? 'Total ${_filters[_selectedFilterIndex]['name']} (${isWeekly ? 'Minggu' : 'Bulan'} Ini):'
                        : (isWeekly ? 'Total Disetor Minggu Ini:' : 'Total Disetor Bulan Ini:'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mainTotalText,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkGreen,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
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
                      trendBadgeText,
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

          const SizedBox(height: 14),

          // ── Interactive Curved Line Chart (7 Hari Pisah / 4 Minggu) ──
          GestureDetector(
            onTapUp: (details) {
              final box = context.findRenderObject() as RenderBox?;
              final w = box != null ? box.size.width - 40 : 300.0;
              final dx = details.localPosition.dx;
              final n = _currentWeights.length;
              final double padding = n == 7 ? 16.0 : 28.0;

              int closest = 0;
              double minDiff = double.infinity;
              for (int i = 0; i < n; i++) {
                final ptX = padding + i * (w - 2 * padding) / (n - 1);
                final diff = (dx - ptX).abs();
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
              height: 145,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _DynamicCurvedLineChartPainter(
                      weights: _currentWeights,
                      oldWeights: _prevWeights,
                      animationProgress: _animation.value,
                      activeIndex: activeIndex,
                      pointLabels: activeLabels,
                      pointFullNames: activeFullNames,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 6),

          // ── X-Axis Labels (Hari Terpisah: Sen, Sel, Rab, Kam, Jum, Sab, Min) ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(activeLabels.length, (i) {
              return _buildAxisLabel(i, activeLabels[i], activeIndex == i);
            }),
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

  Widget _buildPeriodPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double weightKg,
    required int countSetor,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE8F6ED) : const Color(0xFFF9FCFA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? AppColors.darkGreen : const Color(0xFFE2EFE7),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: isActive ? AppColors.darkGreen : AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.darkGreen : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${weightKg.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isActive ? AppColors.darkGreen : const Color(0xFF2C4A3B),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$countSetor setoran',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAxisLabel(int index, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _inspectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.mintSoft,
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Text(
          label,
          style: TextStyle(
            fontSize: isActive ? 11 : 10,
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

class _DynamicCurvedLineChartPainter extends CustomPainter {
  final List<double> weights;
  final List<double>? oldWeights;
  final double animationProgress;
  final int activeIndex;
  final List<String> pointLabels;
  final List<String> pointFullNames;

  _DynamicCurvedLineChartPainter({
    required this.weights,
    this.oldWeights,
    this.animationProgress = 1.0,
    required this.activeIndex,
    required this.pointLabels,
    required this.pointFullNames,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final int n = weights.length;
    if (n < 2) return;

    // Interpolasi animasi data jika ada transisi filter / periode
    final List<double> currentW = List.generate(n, (i) {
      final target = weights[i];
      final prev = (oldWeights != null && i < oldWeights!.length) ? oldWeights![i] : target;
      return prev + (target - prev) * animationProgress;
    });

    final double padding = n == 7 ? 16.0 : 28.0;
    final yBottom = h * 0.74;
    final yTop = h * 0.28;

    double maxVal = currentW.reduce((a, b) => a > b ? a : b);

    // Hitung posisi koordinat titik
    final List<Offset> points = [];
    for (int i = 0; i < n; i++) {
      final x = padding + i * (w - 2 * padding) / (n - 1);
      final val = currentW[i];
      final ratio = maxVal > 0 ? (val / maxVal).clamp(0.0, 1.0) : 0.0;
      final y = yBottom - (ratio * (yBottom - yTop));
      points.add(Offset(x, y));
    }

    // Garis bantu horizontal grid
    final gridPaint = Paint()
      ..color = const Color(0xFFEAF2ED)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, yTop), Offset(w, yTop), gridPaint);
    canvas.drawLine(Offset(0, (yTop + yBottom) / 2), Offset(w, (yTop + yBottom) / 2), gridPaint);
    canvas.drawLine(Offset(0, yBottom), Offset(w, yBottom), gridPaint);

    // Buat kurva halus (Smooth Cubic Bezier untuk N titik)
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    // Gradient fill di bawah garis
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, h)
      ..lineTo(points.first.dx, h)
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

    for (int i = 0; i < n; i++) {
      final pt = points[i];
      if (i == activeIndex) {
        canvas.drawCircle(pt, 6, peakDotPaint);
        canvas.drawCircle(pt, 6, dotBorderPaint);
      } else {
        canvas.drawCircle(pt, 4.0, dotPaint);
        canvas.drawCircle(pt, 4.0, dotBorderPaint);
      }
    }

    // Tooltip interaktif di atas titik aktif
    if (activeIndex >= 0 && activeIndex < points.length) {
      final activePt = points[activeIndex];
      final activeVal = activeIndex < weights.length ? weights[activeIndex] : 0.0;
      final dayName = activeIndex < pointLabels.length ? pointLabels[activeIndex] : '';
      final tooltipText = '$dayName: ${activeVal.toStringAsFixed(1)} kg';

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
  }

  @override
  bool shouldRepaint(covariant _DynamicCurvedLineChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.activeIndex != activeIndex ||
        oldDelegate.weights != weights;
  }
}
