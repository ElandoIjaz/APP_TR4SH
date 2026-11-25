import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test23/core/api_config.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/models/tracking_setor_model.dart';

class GridKategoriSetor extends StatefulWidget {
  final int initialSelectedIndex;
  final void Function(
    int idKategori,
    String title,
    String unit,
    double weightPerUnit,
    double hargaPerKg,
  )? onCategorySelected;

  const GridKategoriSetor({
    super.key,
    this.initialSelectedIndex = 0,
    this.onCategorySelected,
  });

  @override
  State<GridKategoriSetor> createState() => _GridKategoriSetorState();
}

class _GridKategoriSetorState extends State<GridKategoriSetor> {
  int _selectedIndex = 0;
  List<KategoriSampahModel> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
    _fetchCategoriesFromApi();
  }

  Future<void> _fetchCategoriesFromApi() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.kategoriSampah))
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final parsed = (data['data'] as List)
              .whereType()
              .map(
                (e) => KategoriSampahModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList();

          setState(() {
            _categories = parsed;
            _isLoading = false;
          });

          if (_categories.isNotEmpty) {
            final safeIdx = _selectedIndex.clamp(0, _categories.length - 1);
            final first = _categories[safeIdx];
            widget.onCategorySelected?.call(
              first.idKategori,
              first.namaKategori,
              'Kg / Gram',
              0.5,
              first.hargaPerKg,
            );
          }
        } else {
          setState(() {
            _errorMessage =
                data['message']?.toString() ?? 'Data kategori tidak tersedia';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Gagal memuat kategori dari server (Code: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan koneksi: $e';
        _isLoading = false;
      });
    }
  }

  void _selectCategory(KategoriSampahModel cat) {
    final actualIndex = _categories.indexWhere(
      (element) => element.idKategori == cat.idKategori,
    );

    setState(() {
      _selectedIndex = actualIndex != -1 ? actualIndex : 0;
    });

    widget.onCategorySelected?.call(
      cat.idKategori,
      cat.namaKategori,
      'Kg / Gram',
      0.5,
      cat.hargaPerKg,
    );
  }

  void _showAllCategoriesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Semua Kategori Sampah',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];

                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.cardBorder),
                    ),
                    tileColor: AppColors.bgScreen,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.mintSoft,
                      child: Icon(
                        Icons.recycling_rounded,
                        color: AppColors.darkGreen,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      cat.namaKategori,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                    subtitle: Text(
                      'Rp ${cat.hargaPerKg.toStringAsFixed(0)}/kg',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF1E8850),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: () {
                      _selectCategory(cat);
                      Navigator.pop(sheetContext);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.darkGreen),
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final bool hasMore = _categories.length > 5;
    final displayList = hasMore ? _categories.take(5).toList() : _categories;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kategori Sampah (4R)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                ),
              ),
              Text(
                'Sinkron Database',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayList.length + (hasMore ? 1 : 0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.3,
            ),
            itemBuilder: (context, index) {
              if (hasMore && index == displayList.length) {
                return _buildLainnyaCard();
              }
              return _buildAestheticCategoryCard(displayList[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAestheticCategoryCard(KategoriSampahModel cat) {
    final bool isSelected = _selectedIndex < _categories.length &&
        _categories[_selectedIndex].idKategori == cat.idKategori;

    return GestureDetector(
      onTap: () => _selectCategory(cat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F8F4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.darkGreen : AppColors.cardBorder,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.darkGreen.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  isSelected ? AppColors.darkGreen : AppColors.mintSoft,
              child: Icon(
                Icons.recycling_rounded,
                color: isSelected ? Colors.white : AppColors.darkGreen,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cat.namaKategori,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rp ${cat.hargaPerKg.toStringAsFixed(0)}/kg',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E8850),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLainnyaCard() {
    return GestureDetector(
      onTap: _showAllCategoriesSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.mintSoft,
              child: Icon(
                Icons.grid_view_rounded,
                color: AppColors.darkGreen,
                size: 18,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lainnya...',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Lihat semua',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}