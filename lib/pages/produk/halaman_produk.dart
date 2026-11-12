import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test23/core/api_config.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/produk/halaman_detail_produk.dart';
import 'package:test23/pages/produk/halaman_keranjang.dart';
import 'package:test23/pages/tracking/halaman_tracking.dart';
import 'package:test23/widgets/produk/banner_kirim_sampah.dart';
import 'package:test23/data/cart_service.dart';
import 'package:test23/widgets/produk/card_produk_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  ];

  late Future<List<dynamic>> _futureProduk;
  static const String _keyBroadcastDilihat = 'broadcast_id_terakhir_dilihat';
  bool _adaBelumDibaca = false;

  @override
  void initState() {
    super.initState();
    _futureProduk = fetchProdukApi();
    _loadBroadcast();
    _loadInitialCart();
  }

  // 2. Fungsi baru untuk mengambil total item asli dari CartService
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

  Future<List<dynamic>> fetchProdukApi() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.listPrakarya))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final list = data['data'] as List?;
        if (list != null && list.isNotEmpty) {
          return list;
        }
      }
      throw Exception('Server error: ${response.statusCode}');
    } catch (e) {
      debugPrint("Error Koneksi API: $e");
      throw Exception('Gagal menghubungi server API.');
    }
  }

  /// Mengambil nomor (id_broadcast) dari daftar data server.
  List<int> _idBroadcast(List data) {
    return data
        .whereType<Map>()
        .map((b) => int.tryParse('${b['id_broadcast']}') ?? 0)
        .toList();
  }

  /// Dipanggil saat halaman dibuka: titik menyala kalau ada broadcast yang belum dilihat.
  Future<void> _loadBroadcast() async {
    final res = await ApiService.fetchBroadcast();

    var belumDibaca = false;
    if (res.success && res.data is List) {
      final prefs = await SharedPreferences.getInstance();
      final terakhirDilihat = prefs.getInt(_keyBroadcastDilihat) ?? 0;
      belumDibaca = _idBroadcast(res.data as List).any((id) => id > terakhirDilihat);
    }

    if (!mounted) return;
    setState(() => _adaBelumDibaca = belumDibaca);
  }

  /// Dipanggil saat daftar tampil di sheet: simpan nomor terbesar sebagai "sudah dilihat".
  Future<void> _tandaiSudahDibaca(ApiResponse res) async {
    if (!res.success || res.data is! List) return;

    final ids = _idBroadcast(res.data as List);
    if (ids.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBroadcastDilihat, ids.reduce((a, b) => a > b ? a : b));

    if (!mounted) return;
    setState(() => _adaBelumDibaca = false);
  }

  void _showNotificationSheet() {
        final future = ApiService.fetchBroadcast().then((res) {
      _tandaiSudahDibaca(res); // titik padam begitu daftar sudah sampai
      return res;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(22),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
        ),
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
                  'Notifikasi',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: FutureBuilder<ApiResponse>(
                future: future,
                builder: (_, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.darkGreen),
                      ),
                    );
                  }

                  final res = snapshot.data;
                  if (res == null || !res.success) {
                    return _pesanKosongNotif('Gagal memuat notifikasi. Periksa koneksimu lalu coba lagi.');
                  }

                  final items = (res.data is List)
                      ? (res.data as List).whereType().toList()
                      : [];
                  if (items.isEmpty) return _pesanKosongNotif('Belum ada notifikasi.');

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _kartuNotifikasi(items[i]),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _pesanKosongNotif(String teks) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          teks,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
        ),
      ),
    );
  }

  Widget _kartuNotifikasi(Map item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgScreen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFD6F5E1),
            child: Icon(Icons.local_offer_rounded, color: AppColors.darkGreen, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item['judul'] ?? ''}',
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item['pesan'] ?? ''}',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.darkGreen, height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatWaktu(item['dikirim_pada']?.toString()),
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatWaktu(String? iso) {
    final t = DateTime.tryParse(iso ?? '')?.toLocal();
    if (t == null) return '';
    String dua(int n) => n.toString().padLeft(2, '0');
    return '${dua(t.day)}/${dua(t.month)}/${t.year}  ${dua(t.hour)}:${dua(t.minute)}';
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
                onNotificationTap: _showNotificationSheet,
                onCartTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HalamanKeranjang()),
                  );
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

              const SizedBox(height: 16),


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
                child: FutureBuilder<List<dynamic>>(
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

                    final String selectedKategori = _categories[_selectedCategoryIndex];
                    final String query = _searchController.text.trim().toLowerCase();

                    final listProdukApi = snapshot.data!.where((p) {
                      if (p is! Map) return false;
                      final item = Map<String, dynamic>.from(p);

                      final String nama = (
                        item['nama_produk'] ??
                        item['nama_prakarya'] ??
                        item['nama'] ??
                        item['nama_barang'] ??
                        item['title'] ??
                        item['name'] ??
                        item['judul'] ??
                        ''
                      ).toString().toLowerCase();

                      final String deskripsi = (
                        item['deskripsi'] ??
                        item['keterangan'] ??
                        item['detail'] ??
                        item['description'] ??
                        ''
                      ).toString().toLowerCase();

                      final String kategoriAPI = (
                        item['kategori'] ??
                        item['kategori_produk'] ??
                        item['category'] ??
                        ''
                      ).toString().toLowerCase();

                      if (selectedKategori != 'Semua') {
                        final bool matchKategoriChip = kategoriAPI.contains(selectedKategori.toLowerCase()) ||
                            nama.contains(selectedKategori.toLowerCase());
                        if (!matchKategoriChip) {
                          return false;
                        }
                      }

                      if (query.isNotEmpty) {
                        final bool matchNama = nama.contains(query);
                        final bool matchDeskripsi = deskripsi.contains(query);
                        final bool matchKategori = kategoriAPI.contains(query);

                        final bool matchAnyValue = item.values.any((val) {
                          if (val == null) return false;
                          return val.toString().toLowerCase().contains(query);
                        });

                        if (!matchNama && !matchDeskripsi && !matchKategori && !matchAnyValue) {
                          return false;
                        }
                      }

                      return true;
                    }).toList();

                    if (listProdukApi.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(36),
                          child: Column(
                            children: [
                              Icon(Icons.search_off_rounded, size: 40, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              const Text(
                                'Tidak ada produk yang sesuai.',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkGreen),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                query.isNotEmpty
                                    ? 'Tidak ada produk dengan kata kunci "$query"'
                                    : 'Belum ada produk untuk kategori ini.',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
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
                          onTap: () async {
                            // 1) Tampilkan loading
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(
                                child: CircularProgressIndicator(color: AppColors.darkGreen),
                              ),
                            );

                            // 2) Ambil detail. Hasilnya disimpan di variabel, error ditangkap di sini
                            Map<String, dynamic>? detailData;
                            try {
                              final response = await http
                                  .get(Uri.parse(ApiConfig.detailPrakarya(item['id_product'])))
                                  .timeout(const Duration(seconds: 10));

                              if (response.statusCode == 200) {
                                detailData = Map<String, dynamic>.from(json.decode(response.body)['data']);
                              }
                            } catch (e) {
                              debugPrint('Gagal memuat detail produk: $e');
                            }

                            // 3) Tutup loading TEPAT SATU KALI, apa pun hasilnya
                            if (!context.mounted) return;
                            Navigator.pop(context);

                            // 4) Lanjut sesuai hasil
                            final detail = detailData;
                            if (detail == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Gagal mengambil data detail produk dari server.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HalamanDetailProduk(productData: detail),
                              ),
                            );
                          },
                          onAddToCart: () async {
                            // 1. Eksekusi penambahan ke keranjang dengan context agar validasi jalan
                            final bool berhasil = await CartService.tambahProduk(
                              Map<String, dynamic>.from(item),
                              context: context,
                            );

                            // 2. HENTIKAN eksekusi jika stok habis / keranjang penuh
                            if (!context.mounted || !berhasil) return;

                            // 3. Perbarui tampilan badge di header atas JIKA BERHASIL
                            setState(() {
                              _cartItemCount = CartService.totalCount;
                            });

                            // 4. Tampilkan snackbar sukses hijau
                            final nama = item['nama_product'] ?? item['nama_produk'] ?? 'Produk';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$nama dimasukkan ke keranjang!'),
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
          const SizedBox(height: 24),
        ], // Penutup children (Column / ListView)
      ), 
      ),  // Penutup Body Widget (Column / SingleChildScrollView / CustomScrollView)
    ),
         );     // Penutup Scaffold
  }       // Penutup method build
}         // Penutup class _HalamanProdukState
