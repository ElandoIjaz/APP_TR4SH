import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class ModalFilterProduk extends StatefulWidget {
  final VoidCallback onApply;

  const ModalFilterProduk({super.key, required this.onApply});

  @override
  State<ModalFilterProduk> createState() => _ModalFilterProdukState();
}

class _ModalFilterProdukState extends State<ModalFilterProduk> {
  final Set<String> _selectedCategories = {'Fashion Daur Ulang'};
  bool _filterPlastik = true;
  bool _filterKain = true;
  bool _filterKertas = false;
  String _selectedPriceRange = '> 100rb';
  String _selectedRating = '4.0';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Header Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      color: AppColors.darkGreen,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Filter Produk',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.darkGreen,
                  ),
                  onPressed: () => Navigator.pop(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── 1. Kategori (Multi-Pilihan) ──
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kategori',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
                Text(
                  'MULTI-PILIHAN',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E8850),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Fashion Daur Ulang', 'Rumah Tangga', 'Aksesoris'].map(
                (category) {
                  final bool isSelected = _selectedCategories.contains(
                    category,
                  );
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedCategories.remove(category);
                        } else {
                          _selectedCategories.add(category);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.darkGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.darkGreen
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF3B5646),
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: AppColors.limeAccent,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ).toList(),
            ),

            const SizedBox(height: 18),

            // ── 2. Dampak Lingkungan ──
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dampak Lingkungan',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
                Icon(Icons.eco_outlined, size: 16, color: Color(0xFF1E8850)),
              ],
            ),

            const SizedBox(height: 10),

            _buildImpactCheckbox(
              title: 'Plastik Didaur Ulang',
              subtitle: 'Mengurangi beban limbah laut & TPA',
              itemCount: '12 item',
              isChecked: _filterPlastik,
              onChanged: (val) => setState(() => _filterPlastik = val),
            ),
            const SizedBox(height: 8),
            _buildImpactCheckbox(
              title: 'Kain / Karung Bekas',
              subtitle: 'Upcycle tekstil & kemasan logistik',
              itemCount: '6 item',
              isChecked: _filterKain,
              onChanged: (val) => setState(() => _filterKain = val),
            ),
            const SizedBox(height: 8),
            _buildImpactCheckbox(
              title: 'Kertas Tereduksi',
              subtitle: 'Pulp daur ulang tanpa klorin',
              itemCount: '0 item',
              isChecked: _filterKertas,
              onChanged: (val) => setState(() => _filterKertas = val),
            ),

            const SizedBox(height: 18),

            // ── 3. Rentang Harga ──
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rentang Harga',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
                Text(
                  'IDR (Rupiah)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgScreen,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Minimum',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Rp 0',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgScreen,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Maksimum',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Rp 150.000',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                _buildPriceChip('< 50rb'),
                const SizedBox(width: 8),
                _buildPriceChip('50rb - 100rb'),
                const SizedBox(width: 8),
                _buildPriceChip('> 100rb'),
              ],
            ),

            const SizedBox(height: 18),

            // ── 4. Rating Produk ──
            const Text(
              'Rating Produk',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.darkGreen,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedRating = '4.0'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedRating == '4.0'
                            ? AppColors.darkGreen
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedRating == '4.0'
                              ? AppColors.darkGreen
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: _selectedRating == '4.0'
                                ? AppColors.limeAccent
                                : const Color(0xFFF9A825),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '4.0★ ke atas',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _selectedRating == '4.0'
                                  ? Colors.white
                                  : AppColors.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedRating = 'all'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedRating == 'all'
                            ? AppColors.darkGreen
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedRating == 'all'
                              ? AppColors.darkGreen
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_outline_rounded,
                            size: 16,
                            color: _selectedRating == 'all'
                                ? AppColors.limeAccent
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Semua Rating',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _selectedRating == 'all'
                                  ? Colors.white
                                  : AppColors.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ── Footer Buttons (Reset & Terapkan Filter) ──
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                        color: AppColors.cardBorder,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedCategories.clear();
                        _filterPlastik = false;
                        _filterKain = false;
                        _filterKertas = false;
                        _selectedPriceRange = '';
                        _selectedRating = 'all';
                      });
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onApply();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Terapkan Filter',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.limeAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '(18 Hasil)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactCheckbox({
    required String title,
    required String subtitle,
    required String itemCount,
    required bool isChecked,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isChecked ? AppColors.darkGreen : AppColors.cardBorder,
            width: isChecked ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.darkGreen : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isChecked ? AppColors.darkGreen : AppColors.cardBorder,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.limeAccent,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.bgScreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                itemCount,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceChip(String label) {
    final bool isSelected = _selectedPriceRange == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriceRange = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.darkGreen : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.darkGreen : AppColors.cardBorder,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.darkGreen,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
