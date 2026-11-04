import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test23/core/app_colors.dart';

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
  List<dynamic> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
    _fetchCategoriesFromApi();
  }

  /// Mengambil daftar kategori secara dinamis dari API Laravel
  Future<void> _fetchCategoriesFromApi() async {
    try {
      final String baseUrl = kIsWeb
          ? 'http://localhost:8000/api/kategori'
          : 'http://10.0.2.2:8000/api/kategori';

      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _categories = data['data'];
            _isLoading = false;
          });

          if (_categories.isNotEmpty && widget.onCategorySelected != null) {
            final first = _categories[_selectedIndex.clamp(0, _categories.length - 1)];
            widget.onCategorySelected!(
              first['id_kategori'] ?? 1,
              first['nama_kategori'] ?? 'Lainnya',
              'Kg / Gram',
              0.5,
              double.tryParse(first['harga_per_kg'].toString()) ?? 3000.0,
            );
          }
        }
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat kategori dari server (Code: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan koneksi: $e';
        _isLoading = false;
      });
    }
  }

  void _selectCategory(Map<String, dynamic> cat) {
    final actualIndex = _categories.indexWhere(
      (element) => element['id_kategori'] == cat['id_kategori'],
    );

    setState(() {
      _selectedIndex = actualIndex != -1 ? actualIndex : 0;
    });

    if (widget.onCategorySelected != null) {
      widget.onCategorySelected!(
        cat['id_kategori'] as int,
        cat['nama_kategori'] as String,
        'Kg / Gram',
        0.5,
        double.tryParse(cat['harga_per_kg'].toString()) ?? 3000.0,
      );
    }
  }

  /// Menampilkan BottomSheet berisi seluruh daftar kategori lengkap saat kartu "Lainnya" diktekan
  void _showAllCategoriesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
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
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index] as Map<String, dynamic>;
                  final title = cat['nama_kategori'] ?? 'Kategori';
                  final harga = double.tryParse(cat['harga_per_kg'].toString()) ?? 3000.0;
                  
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.cardBorder),
                    ),
                    tileColor: AppColors.bgScreen,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.mintSoft,
                      child: Icon(Icons.recycling_rounded, color: AppColors.darkGreen, size: 18),
                    ),
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    subtitle: Text('Rp ${harga.toStringAsFixed(0)}/kg', style: const TextStyle(fontSize: 11, color: Color(0xFF1E8850), fontWeight: FontWeight.w700)),
                    onTap: () {
                      _selectCategory(cat);
                      Navigator.pop(context);
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

    // Batasi data yang tampil maksimal 6 item (5 kategori asli + 1 kartu "Lainnya")
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

          // Grid Kategori 2 Kolom (Maksimal 6 Kartu Termasuk Lainnya)
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
              // Jika ini adalah kartu ke-6 dan ada lebih dari 5 kategori, tampilkan tombol "Lainnya"
              if (hasMore && index == displayList.length) {
                return _buildLainnyaCard();
              }
              return _buildAestheticCategoryCard(index, displayList[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAestheticCategoryCard(int index, dynamic cat) {
    final bool isSelected = _selectedIndex < _categories.length &&
        _categories[_selectedIndex]['id_kategori'] == cat['id_kategori'];

    final String title = cat['nama_kategori'] ?? 'Kategori';
    final double harga = double.tryParse(cat['harga_per_kg'].toString()) ?? 3000.0;

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
              backgroundColor: isSelected ? AppColors.darkGreen : AppColors.mintSoft,
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
                    title,
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
                    'Rp ${harga.toStringAsFixed(0)}/kg',
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

  /// Kartu khusus "Lainnya" untuk membuka seluruh daftar kategori
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
        child: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.mintSoft,
              child: Icon(
                Icons.grid_view_rounded,
                color: AppColors.darkGreen,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
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