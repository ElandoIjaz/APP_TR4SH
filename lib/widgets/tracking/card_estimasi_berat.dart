import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class CardEstimasiBerat extends StatefulWidget {
  final String categoryName;
  final double hargaPerKg; // Harga akurat dari database
  final void Function(double totalWeight, double totalRupiah)? onInputSampah;

  const CardEstimasiBerat({
    super.key,
    this.categoryName = 'Plastik',
    this.hargaPerKg = 3500.0,
    this.onInputSampah,
  });

  @override
  State<CardEstimasiBerat> createState() => _CardEstimasiBeratState();
}

class _CardEstimasiBeratState extends State<CardEstimasiBerat> {
  double _currentWeightKg = 1.0; 
  bool _isGramUnit = false;     

  void _increment() {
    setState(() {
      if (_isGramUnit) {
        _currentWeightKg += 0.1; // Tambah 100 gram (ratusan gram)
      } else {
        _currentWeightKg += 0.5; // Tambah 0.5 kg
      }
    });
  }

  void _decrement() {
    setState(() {
      if (_isGramUnit) {
        if (_currentWeightKg > 0.1) {
          _currentWeightKg -= 0.1; // Kurang 100 gram (ratusan gram)
        }
      } else {
        if (_currentWeightKg > 0.5) {
          _currentWeightKg -= 0.5; // Kurang 0.5 kg
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double displayValue = _isGramUnit ? (_currentWeightKg * 1000) : _currentWeightKg;
    final String unitLabel = _isGramUnit ? 'gram' : 'kg';
    
    // Hitung total rupiah berdasarkan harga per kg database
    final double estimatedRupiah = _currentWeightKg * widget.hargaPerKg;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ESTIMASI BERAT & NILAI JUAL',
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
                child: Text(
                  'Tarif: Rp ${widget.hargaPerKg.toStringAsFixed(0)}/kg',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E8850),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Preview Box
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
                    Icons.scale_rounded,
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
                        'Kategori: ${widget.categoryName}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${displayValue.toStringAsFixed(_isGramUnit ? 0 : 1)} $unitLabel',
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Estimasi Uang Jual: Rp ${estimatedRupiah.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Toggle Satuan Kg / Gram
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ChoiceChip(
                label: const Text('Kilogram (Kg)', style: TextStyle(fontSize: 11)),
                selected: !_isGramUnit,
                onSelected: (selected) {
                  setState(() {
                    _isGramUnit = false;
                  });
                },
                selectedColor: AppColors.mintSoft,
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Gram (g)', style: TextStyle(fontSize: 11)),
                selected: _isGramUnit,
                onSelected: (selected) {
                  setState(() {
                    _isGramUnit = true;
                    // Pembulatan ke ratusan gram terdekat ketika berpindah ke Gram
                    _currentWeightKg = (_currentWeightKg * 10).round() / 10;
                    if (_currentWeightKg < 0.1) _currentWeightKg = 0.1;
                  });
                },
                selectedColor: AppColors.mintSoft,
              ),
            ],
          ),

          const SizedBox(height: 10),

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
                IconButton(
                  onPressed: _decrement,
                  icon: const Icon(Icons.remove, size: 20, color: AppColors.darkGreen),
                ),
                Text(
                  '${displayValue.toStringAsFixed(_isGramUnit ? 0 : 1)} $unitLabel',
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
                IconButton(
                  onPressed: _increment,
                  icon: const Icon(Icons.add, size: 20, color: AppColors.darkGreen),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (widget.onInputSampah != null) {
                  widget.onInputSampah!(_currentWeightKg, estimatedRupiah);
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