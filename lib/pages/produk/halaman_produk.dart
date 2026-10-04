import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:test23/core/api_config.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/produk_data.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/akun/halaman_akun.dart';
import 'package:test23/pages/beranda/halaman_beranda.dart';
import 'package:test23/pages/produk/halaman_detail_produk.dart';
import 'package:test23/pages/produk/halaman_keranjang.dart';
import 'package:test23/pages/konten/halaman_konten.dart';
import 'package:test23/pages/tracking/halaman_tracking.dart';
import 'package:test23/widgets/produk/banner_kirim_sampah.dart';
import 'package:test23/widgets/produk/card_produk_grid.dart';
import 'package:test23/widgets/produk/header_produk.dart';
import 'package:test23/widgets/produk/hero_banner_produk.dart';
import 'package:test23/widgets/produk/modal_filter_produk.dart';
import 'package:test23/widgets/umum/auth_required_modal.dart';
import 'package:test23/widgets/umum/bottom_nav_bar.dart';

class HalamanProduk extends StatefulWidget {
  const HalamanProduk({super.key});

  @override
  State<HalamanProduk> createState() => _HalamanProdukState();
}

class _HalamanProdukState extends State<HalamanProduk> {
  final int _currentNavIndex = 1;
  int _selectedCategoryIndex = 0;
  int _cartItemCount = 3;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'Semua',
    'Dekorasi Rumah',
    'Fashion Upcycle',
    'Aksesoris',
  ];

  late Future<List<dynamic>> _futureProduk;

  @override
  void initState() {
    super.initState();
    _futureProduk = fetchProdukApi();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi Memanggil API Laravel via IP WiFi dengan fallback offline/mock
  Future<List<dynamic>> fetchProdukApi() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.listPrakarya)).timeout(
        const Duration(seconds: 4),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final list = data['data'] as List?;
        if (list != null && list.isNotEmpty) {
          return list;
        }
      }
    } catch (_) {}

    // Fallback data lokal jika server offline / unit test
    return ProdukData.listProduk.map((p) => {
      'id': p.id,
      'nama_product': p.title,
      'nama_produk': p.title,
      'title': p.title,
      'harga': p.price,
      'foto': p.image,
      'gambar': p.image,
      'kategori': p.category,
      'deskripsi': p.materialTag,
      'hemat_plastik': p.plasticSaved,
      'terjual': p.soldCount,
      'rating': p.rating,
    }).toList();
  }

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalFilterProduk(
        onApply: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Filter produk berhasil diterapkan'),
              backgroundColor: AppColors.darkGreen,
            ),
          );
        },
      ),
    );
  }

  void _showNotificationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifikasi Marketplace',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgScreen,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFD6F5E1),
                    child: Icon(Icons.local_offer_rounded, color: AppColors.darkGreen, size: 18),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Flash sale karya daur ulang diskon hingga 25% sedang berlangsung!',
                      style: TextStyle(fontSize: 12.5, color: AppColors.darkGreen),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Header ──
              HeaderProduk(
                cartItemCount: _cartItemCount,
                onNotificationTap: _showNotificationSheet,
                onCartTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HalamanKeranjang()),
                  );
                },
              ),

              const SizedBox(height: 8),

              // ── 2. Search Bar & Filter ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.only(left: 14, right: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.darkGreen),
                          decoration: const InputDecoration(
                            hintText: 'Cari produk daur ulang & upcycle...',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.normal,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _openFilterModal,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6F3DD),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.tune_rounded, color: AppColors.darkGreen, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── 3. Category Filter Chips ──
              SizedBox(
                height: 36,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final bool isSelected = _selectedCategoryIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.darkGreen : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.darkGreen : AppColors.cardBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.limeAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              _categories[index],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? Colors.white : const Color(0xFF4C6656),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ── 4. Hero Banner ──
              HeroBannerProduk(
                onJelajahiTap: () {
                  _openFilterModal();
                },
              ),

              const SizedBox(height: 20),

              // ── 5. Section: Produk Pilihan ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Produk Pilihan',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Katalog kreasi daur ulang terverifikasi',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── 6. 2-Column Product Grid (FutureBuilder Data API) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FutureBuilder<List<dynamic>>(
                  future: _futureProduk,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(color: AppColors.darkGreen),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Gagal terhubung ke server.\nPastikan Laravel berjalan di ${ApiConfig.baseUrl}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('Belum ada produk prakarya tersedia.'),
                        ),
                      );
                    }

                    // Logika Filter Kategori Lokal
                    final String selectedKategori = _categories[_selectedCategoryIndex];
                    final listProdukApi = snapshot.data!.where((p) {
                      if (selectedKategori == 'Semua') return true;
                      final String kategoriAPI = p['kategori'] ?? p['jenis'] ?? '';
                      return kategoriAPI.toLowerCase().contains(selectedKategori.toLowerCase());
                    }).toList();

                    if (listProdukApi.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(30),
                          child: Text('Tidak ada produk di kategori ini.'),
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: listProdukApi.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.58,
                      ),
                      itemBuilder: (context, index) {
                        final item = listProdukApi[index];
                        return CardProdukGrid(
                          product: item,
                          onTap: () {
                            // Sementara lempar ke Halaman Detail dengan Dummy (agar tidak error)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HalamanDetailProduk(product: ProdukData.listProduk.first),
                              ),
                            );
                          },
                          onAddToCart: () {
                            setState(() {
                              _cartItemCount++;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item['nama_produk'] ?? 'Produk'} dimasukkan ke keranjang!'),
                                duration: const Duration(milliseconds: 900),
                                backgroundColor: AppColors.darkGreen,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ── 7. Kirim Sampah Anda Banner ──
              BannerKirimSampah(
                onSetorTap: () {
                  if (UserAccountData.isGuest) {
                    AuthRequiredModal.show(
                      context,
                      title: 'Fitur Setor Sampah Memerlukan Akun',
                      message: 'Silakan masuk atau buat akun terlebih dahulu untuk menyetor sampah daur ulang dan mengumpulkan poin hadiah.',
                      icon: Icons.recycling_rounded,
                    );
                    return;
                  }
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HalamanTracking()),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // ── 8. Bottom Navigation Bar ──
      bottomNavigationBar: TrashBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HalamanBeranda()),
            );
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HalamanKonten()),
            );
          } else if (index == 3) {
            if (UserAccountData.isGuest) {
              AuthRequiredModal.show(
                context,
                title: 'Fitur Tracking Sampah Memerlukan Akun',
                message: 'Pelacakan sampah daur ulang, grafik analitik, dan perolehan poin hanya dapat digunakan setelah Anda masuk atau membuat akun.',
                icon: Icons.query_stats_rounded,
              );
              return;
            }
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HalamanTracking()),
            );
          } else if (index == 4) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HalamanAkun()),
            );
          }
        },
      ),
    );
  }
}