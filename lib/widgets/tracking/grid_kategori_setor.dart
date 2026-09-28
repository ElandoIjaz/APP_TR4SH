import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class GridKategoriSetor extends StatefulWidget {
  final int initialSelectedIndex;
  final void Function(int index, String title, String unit, double weightPerUnit, int pointsPerUnit)? onCategorySelected;

  const GridKategoriSetor({
    super.key,
    this.initialSelectedIndex = 0,
    this.onCategorySelected,
  });

  @override
  State<GridKategoriSetor> createState() => _GridKategoriSetorState();
}

class _GridKategoriSetorState extends State<GridKategoriSetor> {
  late int _selectedIndex;

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Plastik',
      'subtitle': 'Botol, kantong kresek',
      'badge': '100% Recyclable',
      'badgeBg': Color(0xFFD8F4E4),
      'badgeColor': Color(0xFF1E8850),
      'icon': Icons.water_drop_outlined,
      'unit': 'Botol',
      'weightPerUnit': 0.1,
      'pointsPerUnit': 10,
    },
    {
      'title': 'Kaca',
      'subtitle': 'Beling, Piring kaca,...',
      'badge': 'Rapuh',
      'badgeBg': Color(0xFFFFEBEE),
      'badgeColor': Color(0xFFE53935),
      'icon': Icons.wine_bar_rounded,
      'unit': 'Botol/Piring',
      'weightPerUnit': 0.4,
      'pointsPerUnit': 15,
    },
    {
      'title': 'Kertas & Karton',
      'subtitle': 'Kardus, buku, majalah',
      'badge': 'Mudah Terurai',
      'badgeBg': Color(0xFFE8F5E9),
      'badgeColor': Color(0xFF2E7D32),
      'icon': Icons.inventory_2_outlined,
      'unit': 'Lembar/Dus',
      'weightPerUnit': 0.2,
      'pointsPerUnit': 8,
    },
    {
      'title': 'Logam / Kaleng',
      'subtitle': 'Kaleng, aluminium',
      'badge': 'Nilai Tinggi',
      'badgeBg': Color(0xFFEDF8B6),
      'badgeColor': Color(0xFF0D4330),
      'icon': Icons.delete_outline_rounded,
      'unit': 'Kaleng',
      'weightPerUnit': 0.15,
      'pointsPerUnit': 25,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
  }

  void _selectCategory(int index) {
    setState(() {
      _selectedIndex = index;
    });
    final cat = _categories[index];
    if (widget.onCategorySelected != null) {
      widget.onCategorySelected!(
        index,
        cat['title'] as String,
        cat['unit'] as String,
        cat['weightPerUnit'] as double,
        cat['pointsPerUnit'] as int,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Kategori Sampah',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                ),
              ),
              Text(
                'Pilih kategori setor',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 2x2 Grid
          Row(
            children: [
              Expanded(child: _buildCategoryCard(0)),
              const SizedBox(width: 12),
              Expanded(child: _buildCategoryCard(1)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildCategoryCard(2)),
              const SizedBox(width: 12),
              Expanded(child: _buildCategoryCard(3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(int index) {
    final cat = _categories[index];
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _selectCategory(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.darkGreen : AppColors.cardBorder,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.darkGreen.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon circle + Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.mintSoft,
                  child: Icon(cat['icon'] as IconData, color: AppColors.darkGreen, size: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: cat['badgeBg'] as Color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    cat['badge'] as String,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: cat['badgeColor'] as Color,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              cat['title'] as String,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),

            const SizedBox(height: 2),

            // Subtitle
            Text(
              cat['subtitle'] as String,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
