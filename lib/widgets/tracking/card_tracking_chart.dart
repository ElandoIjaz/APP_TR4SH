import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/user_account_data.dart';

enum TrackingPeriodMode { mingguan, bulanan }

class CardTrackingChart extends StatefulWidget {
  final String totalDisetor;
  final String trendPercent;
  final String? targetWeight;
  final bool isBeranda;
  final ValueChanged<String>? onCategoryFilterChanged;
  final List<dynamic>? rawData;

  const CardTrackingChart({
    super.key,
    this.totalDisetor = '0.0 kg',
    this.trendPercent = '+0 setoran',
    this.targetWeight,
    this.isBeranda = false,
    this.onCategoryFilterChanged,
    this.rawData,
  });

  @override
  State<CardTrackingChart> createState() => _CardTrackingChartState();
}

class _CardTrackingChartState extends State<CardTrackingChart>
    with SingleTickerProviderStateMixin {
  TrackingPeriodMode _periodMode = TrackingPeriodMode.mingguan;
  String? _selectedCategory; // Kategori dinamis terpilih
  int? _inspectedIndex;

  late AnimationController _animController;
  late Animation<double> _animation;

  List<double> _prevWeights = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  List<double> _currentWeights = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

  static const List<String> _weekLabels = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];
  static const List<String> _weekFullNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _monthLabels = ['Mg 1', 'Mg 2', 'Mg 3', 'Mg 4'];
  static const List<String> _monthFullNames = [
    'Minggu 1 (Tgl 1-7)',
    'Minggu 2 (Tgl 8-14)',
    'Minggu 3 (Tgl 15-21)',
    'Minggu 4 (Tgl 22+)',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

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

  /// Menghitung akumulasi berat secara dinamis berdasarkan kategori yang ada di rawData
  Map<String, double> _computeDynamicCategoryWeights() {
    final records = widget.rawData;
    if (records == null || records.isEmpty) return {};

    final Map<String, double> catMap = {};

    for (final item in records) {
      if (item is! Map) continue;
      final weight = double.tryParse(item['jumlah']?.toString() ?? '0') ?? 0.0;
      final cat = (item['nama_kategori'] ?? 'Lainnya').toString().trim();

      if (cat.isNotEmpty) {
        catMap[cat] = (catMap[cat] ?? 0.0) + weight;
      }
    }

    return catMap.map(
      (key, val) => MapEntry(key, double.parse(val.toStringAsFixed(2))),
    );
  }

  /// Menghitung estimasi Uang Hasil Jual (Rupiah) dari data transaksi (asumsi Rp 3.000/kg)
  double _calculateTotalIncome(double totalKg) {
    return totalKg * 3000;
  }

  /// Menghitung Ringkasan Data (Minggu ini & Bulan ini)
  Map<String, dynamic> _computeSummaryMetrics() {
    final records = widget.rawData;
    final bool isZeroState =
        UserAccountData.isNewAccount ||
        UserAccountData.isGuest ||
        widget.totalDisetor.startsWith('0.0') ||
        widget.totalDisetor.startsWith('0 kg');

    if (isZeroState || records == null || records.isEmpty) {
      return {
        'weeklyKg': 0.0,
        'weeklyCount': 0,
        'monthlyKg': 0.0,
        'monthlyCount': 0,
        'hasData': false,
      };
    }

    final now = DateTime.now();
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final nextMonday = monday.add(const Duration(days: 7));

    double weeklyKg = 0.0;
    int weeklyCount = 0;
    double monthlyKg = 0.0;
    int monthlyCount = 0;

    for (final item in records) {
      if (item is! Map) continue;

      // Filter jika kategori tertentu sedang dipilih
      if (_selectedCategory != null && _selectedCategory != 'Semua') {
        final cat = (item['nama_kategori'] ?? '').toString().trim();
        if (cat != _selectedCategory) continue;
      }

      final weight = double.tryParse(item['jumlah']?.toString() ?? '0') ?? 0.0;
      DateTime dt = now;
      if (item['created_at'] != null) {
        try {
          dt = DateTime.parse(item['created_at'].toString()).toLocal();
        } catch (_) {}
      }

      // Cek Minggu Ini
      if (dt.isAfter(monday.subtract(const Duration(seconds: 1))) &&
          dt.isBefore(nextMonday)) {
        weeklyKg += weight;
        weeklyCount++;
      } else {
        weeklyKg += weight;
        weeklyCount++;
      }

      // Cek Bulan Ini
      if (dt.year == now.year && dt.month == now.month) {
        monthlyKg += weight;
        monthlyCount++;
      } else {
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

  /// Menghitung bobot untuk titik grafik
  List<double> _calculateChartWeights() {
    final records = widget.rawData;
    final bool isZeroState =
        UserAccountData.isNewAccount ||
        UserAccountData.isGuest ||
        widget.totalDisetor.startsWith('0.0') ||
        widget.totalDisetor.startsWith('0 kg');

    if (isZeroState || records == null || records.isEmpty) {
      return _periodMode == TrackingPeriodMode.mingguan
          ? [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
          : [0.0, 0.0, 0.0, 0.0];
    }

    final now = DateTime.now();
    if (_periodMode == TrackingPeriodMode.mingguan) {
      final List<double> dayWeights = List.filled(7, 0.0);

      for (final item in records) {
        if (item is! Map) continue;

        if (_selectedCategory != null && _selectedCategory != 'Semua') {
          final cat = (item['nama_kategori'] ?? '').toString().trim();
          if (cat != _selectedCategory) continue;
        }

        final weight = double.tryParse(item['jumlah']?.toString() ?? '0') ?? 0.0;
        DateTime dt = now;
        if (item['created_at'] != null) {
          try {
            dt = DateTime.parse(item['created_at'].toString()).toLocal();
          } catch (_) {}
        }

        final idx = (dt.weekday - 1).clamp(0, 6);
        dayWeights[idx] += weight;
      }

      return dayWeights.map((w) => double.parse(w.toStringAsFixed(1))).toList();
    } else {
      final List<double> weekWeights = List.filled(4, 0.0);

      for (final item in records) {
        if (item is! Map) continue;

        if (_selectedCategory != null && _selectedCategory != 'Semua') {
          final cat = (item['nama_kategori'] ?? '').toString().trim();
          if (cat != _selectedCategory) continue;
        }

        final weight = double.tryParse(item['jumlah']?.toString() ?? '0') ?? 0.0;
        DateTime dt = now;
        if (item['created_at'] != null) {
          try {
            dt = DateTime.parse(item['created_at'].toString()).toLocal();
          } catch (_) {}
        }

        final day = dt.day;
        int weekIdx = day <= 7 ? 0 : (day <= 14 ? 1 : (day <= 21 ? 2 : 3));
        weekWeights[weekIdx] += weight;
      }

      return weekWeights.map((w) => double.parse(w.toStringAsFixed(1))).toList();
    }
  }

  int _findPeakIndex(List<double> weights) {
    if (weights.isEmpty) return 0;
    final allZero = weights.every((w) => w <= 0.0);
    if (allZero) {
      if (weights.length == 7) {
        return (DateTime.now().weekday - 1).clamp(0, 6);
      }
      return 0;
    }
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

  Color _getCategoryColor(int index) {
    const colors = [
      Color(0xFF0D4330),
      Color(0xFF2E8055),
      Color(0xFFE65100),
      Color(0xFF0D47A1),
      Color(0xFF7B1FA2),
      Color(0xFF5AB67B),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final summary = _computeSummaryMetrics();
    final double weeklyKg = summary['weeklyKg'] as double;
    final int weeklyCount = summary['weeklyCount'] as int;
    final double monthlyKg = summary['monthlyKg'] as double;
    final int monthlyCount = summary['monthlyCount'] as int;

    final isWeekly = _periodMode == TrackingPeriodMode.mingguan;
    final activeLabels = isWeekly ? _weekLabels : _monthLabels;
    final activeFullNames = isWeekly ? _weekFullNames : _monthFullNames;

    final double currentPeriodKg = isWeekly ? weeklyKg : monthlyKg;
    final int currentPeriodCount = isWeekly ? weeklyCount : monthlyCount;
    final double estimatedIncome = _calculateTotalIncome(currentPeriodKg);

    String mainWeightNumber = currentPeriodKg.toStringAsFixed(1);
    final String trendBadgeText = summary['hasData']
        ? '+$currentPeriodCount setoran'
        : widget.trendPercent;

    final dynamicCategoryWeights = _computeDynamicCategoryWeights();

    final peakIdx = _findPeakIndex(_currentWeights);
    final activeIndex = (_inspectedIndex ?? peakIdx).clamp(
      0,
      _currentWeights.length - 1,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          // ── Header Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isBeranda ? 'RIWAYAT SETOR SAMPAH' : 'Riwayat Setor Sampah',
                      style: TextStyle(
                        fontSize: widget.isBeranda ? 11 : 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                        letterSpacing: widget.isBeranda ? 0.8 : 0,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _selectedCategory != null
                          ? 'Kategori: $_selectedCategory'
                          : 'Tren setoran limbah daur ulangmu',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F6F3),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(2),
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

          const SizedBox(height: 10),

          // ── Summary Cards ──
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
              const SizedBox(width: 8),
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

          const SizedBox(height: 10),

          // ── Uang Hasil Jual & Trend Badge ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isWeekly ? 'Total Seluruh Sampah (Minggu Ini):' : 'Total Seluruh Sampah (Bulan Ini):',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          mainWeightNumber,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkGreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'kg',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E6B4E),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Badges Uang Hasil Jual (Rupiah)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFC8E6C9)),
                    ),
                    child: Text(
                      'Estimasi: Rp ${estimatedIncome.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.mintSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.trending_up_rounded, size: 12, color: Color(0xFF1E8850)),
                        const SizedBox(width: 4),
                        Text(
                          trendBadgeText,
                          style: const TextStyle(
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
            ],
          ),

          const SizedBox(height: 8),

          // ── Curved Line Chart ──
          GestureDetector(
            onTapUp: (details) {
              final box = context.findRenderObject() as RenderBox?;
              final w = box != null ? box.size.width - 28 : 300.0;
              final dx = details.localPosition.dx;
              final n = _currentWeights.length;
              final double padding = n == 7 ? 12.0 : 22.0;

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
              height: 100,
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

          const SizedBox(height: 3),

          // ── Label X-Axis ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(activeLabels.length, (i) {
              return _buildAxisLabel(i, activeLabels[i], activeIndex == i);
            }),
          ),

          const SizedBox(height: 12),

          // ── Kategori Dinamis berdasarkan Transaksi Asli Database ──
          const Text(
            'Kategori Disetorkan:',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
          ),
          const SizedBox(height: 6),
          dynamicCategoryWeights.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.bgScreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Belum ada kategori sampah disetorkan',
                      style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                  ),
                )
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    // Chip untuk Tampilkan Semua
                    _buildDynamicChip(
                      label: 'Semua',
                      weight: null,
                      color: AppColors.darkGreen,
                      isSelected: _selectedCategory == null || _selectedCategory == 'Semua',
                      onTap: () {
                        setState(() {
                          _selectedCategory = 'Semua';
                          _updateWeights();
                        });
                        if (widget.onCategoryFilterChanged != null) {
                          widget.onCategoryFilterChanged!('Semua');
                        }
                      },
                    ),
                    ...dynamicCategoryWeights.entries.toList().asMap().entries.map((entry) {
                      final idx = entry.key;
                      final catName = entry.value.key;
                      final catWeight = entry.value.value;
                      final catColor = _getCategoryColor(idx);
                      final isSelected = _selectedCategory == catName;

                      return _buildDynamicChip(
                        label: catName,
                        weight: catWeight,
                        color: catColor,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedCategory = isSelected ? 'Semua' : catName;
                            _updateWeights();
                          });
                          if (widget.onCategoryFilterChanged != null) {
                            widget.onCategoryFilterChanged!(_selectedCategory!);
                          }
                        },
                      );
                    }),
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
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE8F6ED) : const Color(0xFFF9FCFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.darkGreen : const Color(0xFFE2EFE7),
            width: isActive ? 1.4 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 12,
                  color: isActive ? AppColors.darkGreen : AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.darkGreen : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                Text(
                  '${weightKg.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isActive ? AppColors.darkGreen : const Color(0xFF2C4A3B),
                  ),
                ),
                Text(
                  '+$countSetor setor',
                  style: const TextStyle(
                    fontSize: 9.5,
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

  Widget _buildDynamicChip({
    required String label,
    required double? weight,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F6ED) : const Color(0xFFF9FCFA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.darkGreen : const Color(0xFFE2EFE7),
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppColors.darkGreen : const Color(0xFF334A3E),
              ),
            ),
            if (weight != null) ...[
              const SizedBox(width: 4),
              Text(
                '${weight.toStringAsFixed(1)}kg',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.darkGreen : const Color(0xFF2C4A3B),
                ),
              ),
            ],
          ],
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

    final double padding = n == 7 ? 12.0 : 22.0;
    const double topMargin = 22.0;
    const double bottomMargin = 10.0;
    final double chartHeight = h - topMargin - bottomMargin;

    double maxWeight = 0.1;
    for (final v in weights) {
      if (v > maxWeight) maxWeight = v;
    }
    if (oldWeights != null) {
      for (final v in oldWeights!) {
        if (v > maxWeight) maxWeight = v;
      }
    }
    maxWeight = (maxWeight * 1.25).clamp(2.0, 100.0);

    final List<Offset> points = [];
    final double stepX = (w - 2 * padding) / (n - 1);

    for (int i = 0; i < n; i++) {
      final double prevVal = (oldWeights != null && i < oldWeights!.length)
          ? oldWeights![i]
          : weights[i];
      final double currentVal = weights[i];
      final double animatedVal =
          prevVal + (currentVal - prevVal) * animationProgress;

      final double x = padding + i * stepX;
      final double normalized = (animatedVal / maxWeight).clamp(0.0, 1.0);
      final double y = topMargin + chartHeight * (1.0 - normalized);
      points.add(Offset(x, y));
    }

    // Grid Horizontal
    final gridPaint = Paint()
      ..color = const Color(0xFFEAF2ED)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int g = 0; g <= 3; g++) {
      final gy = topMargin + chartHeight * (g / 3);
      canvas.drawLine(Offset(padding, gy), Offset(w - padding, gy), gridPaint);
    }

    // Gradient Area
    final areaPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      areaPath.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }
    areaPath.lineTo(points.last.dx, topMargin + chartHeight);
    areaPath.lineTo(points.first.dx, topMargin + chartHeight);
    areaPath.close();

    final areaGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.limeAccent.withValues(alpha: 0.38),
        AppColors.mintSoft.withValues(alpha: 0.16),
        Colors.white.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.65, 1.0],
    );

    final areaPaint = Paint()
      ..shader = areaGradient.createShader(
        Rect.fromLTRB(padding, topMargin, w - padding, topMargin + chartHeight),
      )
      ..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, areaPaint);

    // Garis Kurva
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    final linePaint = Paint()
      ..color = AppColors.darkGreen
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(linePath, linePaint);

    // Titik Node
    final outerPointPaint = Paint()
      ..color = AppColors.darkGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final innerFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final activePointFill = Paint()
      ..color = AppColors.limeAccent
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final bool isActive = i == activeIndex;

      if (isActive) {
        final glowPaint = Paint()
          ..color = AppColors.limeAccent.withValues(alpha: 0.45)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pt, 8.5, glowPaint);

        canvas.drawCircle(pt, 5.0, activePointFill);
        canvas.drawCircle(pt, 5.0, outerPointPaint);
      } else {
        canvas.drawCircle(pt, 3.5, innerFillPaint);
        canvas.drawCircle(pt, 3.5, outerPointPaint);
      }
    }

    // Tooltip
    if (activeIndex >= 0 && activeIndex < points.length) {
      final activePt = points[activeIndex];
      final activeWeight = weights[activeIndex];
      final String labelName = activeIndex < pointLabels.length ? pointLabels[activeIndex] : '';
      final String tooltipText = '$labelName: ${activeWeight.toStringAsFixed(1)} kg';

      final tp = TextPainter(
        text: TextSpan(
          text: tooltipText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      const double bubblePadH = 6.0;
      const double bubblePadV = 3.0;
      final double bw = tp.width + (bubblePadH * 2);
      final double bh = tp.height + (bubblePadV * 2);

      double bx = activePt.dx - (bw / 2);
      bx = bx.clamp(4.0, w - bw - 4.0);
      final double by = (activePt.dy - bh - 6.0).clamp(2.0, h - bh);

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, bw, bh),
        const Radius.circular(6),
      );

      final bubblePaint = Paint()
        ..color = AppColors.darkGreen
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, bubblePaint);

      tp.paint(canvas, Offset(bx + bubblePadH, by + bubblePadV));
    }
  }

  @override
  bool shouldRepaint(covariant _DynamicCurvedLineChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.activeIndex != activeIndex ||
        oldDelegate.weights != weights;
  }
}