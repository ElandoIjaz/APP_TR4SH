import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test23/core/api_config.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/cart_service.dart';
import 'package:test23/data/models/produk_model.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/akun/halaman_notifikasi.dart';
import 'package:test23/pages/main_navigation.dart';
import 'package:test23/pages/produk/halaman_detail_produk.dart';
import 'package:test23/pages/produk/halaman_keranjang.dart';
import 'package:test23/widgets/produk/banner_kirim_sampah.dart';
import 'package:test23/widgets/produk/card_produk_grid.dart';
import 'package:test23/widgets/produk/header_produk.dart';
import 'package:test23/widgets/produk/search_and_category_bar.dart';
import 'package:test23/widgets/umum/auth_required_modal.dart';

class HalamanProduk extends StatefulWidget {
  const HalamanProduk({super.key});

  @override
  State<HalamanProduk> createState() => _HalamanProdukState();
}

class _HalamanProdukState extends State<HalamanProduk> {
  int _selectedCategoryIndex = 0;
  int _cartItemCount = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'Semua',
    'Dekorasi Rumah',
    'Fashion Upcycle',
    'Aksesoris',
    'Setengah Jadi',
  ];

  late Future<List<ProdukModel>> _futureProduk;
  bool _adaBelumDibaca = false;

  @override
  void initState() {
    super.initState();
    _futureProduk = fetchProdukApi();
    _loadBroadcast();
    _loadInitialCart();
  }

  Future<void> _loadInitialCart() async {
    await CartService.loadCart();
    if (!mounted) return;
    setState(() {
      _cartItemCount = CartService.totalCount;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<ProdukModel>> fetchProdukApi() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.listPrakarya))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final list = data['data'] as List?;
        if (list != null && list.isNotEmpty) {
          return list
              .whereType()
              .map((e) => ProdukModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      throw Exception('Server error: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error Koneksi API: $e');
      throw Exception('Gagal menghubungi server API.');
    }
  }

  Future<void> _bukaDetailProduk(ProdukModel item) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.darkGreen),
      ),
    );

    ProdukModel? detailProduk;
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.detailPrakarya(item.idProduct)))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final rawData = Map<String, dynamic>.from(
          json.decode(response.body)['data'] as Map,
        );
        detailProduk = ProdukModel.fromJson(rawData);
      }
    } catch (e) {
      debugPrint('Gagal memuat detail produk: $e');
    }

    if (!mounted) return;
    Navigator.pop(context);

    if (detailProduk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengambil data detail produk dari server.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HalamanDetailProduk(productData: detailProduk!),
      ),
    );
    _loadInitialCart();
  }

  /// Titik hanya menyala saat sudah login dan masih ada notifikasi/broadcast belum diklik.
  Future<void> _loadBroadcast() async {
    final belumDibaca = await HalamanNotifikasi.hasUnreadNotifications();
    if (!mounted) return;
    setState(() => _adaBelumDibaca = belumDibaca);
  }

  Future<void> _navigateToNotifikasi() async {
    if (!UserAccountData.isLoggedIn) {
      AuthRequiredModal.show(
        context,
        title: 'Notifikasi Memerlukan Akun',
        message: 'Silakan masuk terlebih dahulu untuk melihat notifikasi Anda.',
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HalamanNotifikasi()),
    );
    _loadBroadcast();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Header ──
              HeaderProduk(
                cartItemCount: _cartItemCount,
                adaNotifikasi: _adaBelumDibaca,
                onNotificationTap: _navigateToNotifikasi,
                onCartTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HalamanKeranjang()),
                  );
                  _loadInitialCart();
                },
              ),

              const SizedBox(height: 8),

              // ── 2 & 3. Search Bar & Filter Chips (Modular Widget) ──
              SearchAndCategoryBar(
                searchController: _searchController,
                onSearchChanged: (val) {
                  setState(() {});
                },
                onClearSearch: () {
                  _searchController.clear();
                  setState(() {});
                },
                categories: _categories,
                selectedCategoryIndex: _selectedCategoryIndex,
                onCategorySelected: (index) {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                },
              ),

              const SizedBox(height: 20),

              // ── 4. Section: Produk Pilihan ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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

              // ── 5. 2-Column Product Grid ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FutureBuilder<List<ProdukModel>>(
                  future: _futureProduk,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(
                            color: AppColors.darkGreen,
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.wifi_off_rounded,
                                size: 48,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Ups, koneksi terputus!',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Periksa jaringanmu atau coba beberapa saat lagi ya.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.darkGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _futureProduk = fetchProdukApi();
                                  });
                                },
                                icon: const Icon(Icons.refresh_rounded, size: 16),
                                label: const Text(
                                  'Coba Lagi',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final String selectedKategori =
                        _categories[_selectedCategoryIndex];
                    final String query =
                        _searchController.text.trim().toLowerCase();

                    final listProdukApi = snapshot.data!
                        .where(
                          (p) => p.matchesFilter(
                            selectedKategori: selectedKategori,
                            query: query,
                          ),
                        )
                        .toList();

                    if (listProdukApi.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(36),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Tidak ada produk yang sesuai.',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                query.isNotEmpty
                                    ? 'Tidak ada produk dengan kata kunci "$query"'
                                    : 'Belum ada produk untuk kategori ini.',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: listProdukApi.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.58,
                      ),
                      itemBuilder: (context, index) {
                        final item = listProdukApi[index];
                        return CardProdukGrid(
                          product: item,
                          onTap: () => _bukaDetailProduk(item),
                          onAddToCart: () async {
                            final bool berhasil = await CartService.tambahProduk(
                              item.toCartMap(),
                              context: context,
                            );

                            if (!context.mounted || !berhasil) return;

                            setState(() {
                              _cartItemCount = CartService.totalCount;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${item.namaProduk} dimasukkan ke keranjang!',
                                ),
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

              // ── 6. Kirim Sampah Anda Banner ──
              BannerKirimSampah(
                onSetorTap: () {
                  if (UserAccountData.isGuest) {
                    AuthRequiredModal.show(
                      context,
                      title: 'Fitur Setor Sampah Memerlukan Akun',
                      message:
                          'Silakan masuk atau buat akun terlebih dahulu untuk menyetor sampah daur ulang dan mencatat riwayat setoran Anda.',
                      icon: Icons.recycling_rounded,
                    );
                    return;
                  }
                  MainNavigationPage.jumpToTab(context, 3);
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}