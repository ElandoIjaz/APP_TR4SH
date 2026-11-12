import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:test23/core/api_config.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/data/cart_service.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/produk/halaman_keranjang.dart';
import 'package:test23/pages/produk/halaman_pembayaran.dart';

class HalamanRiwayatTransaksi extends StatefulWidget {
  const HalamanRiwayatTransaksi({super.key});

  @override
  State<HalamanRiwayatTransaksi> createState() =>
      _HalamanRiwayatTransaksiState();
}

class _HalamanRiwayatTransaksiState extends State<HalamanRiwayatTransaksi> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'Semua',
    'Menunggu Pembayaran',
    'Selesai',
    'Dibatalkan',
  ];

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchRiwayatTransaksi();
  }

  Future<void> _fetchRiwayatTransaksi() async {
    if (UserAccountData.isGuest || UserAccountData.currentUserId == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _transactions = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await ApiService.getToken();
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/transaksi/riwayat/${UserAccountData.currentUserId}',
      );

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          final list = (decoded['data'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          if (!mounted) return;
          setState(() {
            _transactions = list;
            _isLoading = false;
          });
          return;
        }
      }

      throw Exception('Gagal memuat data transaksi (${response.statusCode})');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal terhubung ke server. Tarik ke bawah untuk muat ulang.';
      });
    }
  }

    List<Map<String, dynamic>> get _filteredList {
    if (_selectedFilterIndex == 0) return _transactions;
    final filter = _filters[_selectedFilterIndex];

    return _transactions.where((trx) {
      final status = (trx['status_transaksi'] ?? '').toString().toLowerCase();
      if (filter == 'Menunggu Pembayaran') {
        return status == 'pending';
      } else if (filter == 'Selesai') {
        return status == 'settlement' || status == 'capture';
      } else if (filter == 'Dibatalkan') {
        return ['expire', 'cancel', 'failed', 'deny'].contains(status);
      }
      return true;
    }).toList();
  }

  void _lanjutkanPembayaran(Map<String, dynamic> trx) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HalamanPembayaran(dataTransaksi: trx),
      ),
    ).then((_) {
      // Refresh otomatis setelah kembali dari layar pembayaran
      _fetchRiwayatTransaksi();
    });
  }

  void _showBuktiOrderModal(Map<String, dynamic> trx) {
    final orderId = trx['order_id']?.toString() ?? '-';
    final metode = (trx['metode'] == 'qris')
        ? 'QRIS'
        : 'Transfer VA (${trx['bank'] ?? 'Bank'})';
    final totalBayar = trx['total_bayar'] ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
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
                  'Bukti Pengambilan Pesanan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Kotak No. Order
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F6EE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF98CCA8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NO. ORDER (TUNJUKKAN KE PETUGAS)',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E8850),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          orderId,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkGreen,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: AppColors.darkGreen),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: orderId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No. Order berhasil disalin!'),
                          duration: Duration(milliseconds: 900),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Detail Pembayaran
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Metode Pembayaran',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                Text(
                  metode,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Lunas',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                Text(
                  'Rp ${_formatPrice(totalBayar)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkGreen,
                  ),
                ),
              ],
            ),

            const Divider(height: 22, color: Color(0xFFE2EFE7)),

            // Lokasi Pengambilan Mandiri
            const Row(
              children: [
                Icon(Icons.storefront_rounded, color: AppColors.darkGreen, size: 18),
                SizedBox(width: 6),
                Text(
                  'Lokasi Pengambilan Barang',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Bank Sampah Sahabat Ibu TR4SH',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Perumahan Taman Gading, Tumpengsari, Tegal Besar, Kec. Kaliwates, Jember, Jawa Timur',
              style: TextStyle(
                fontSize: 11.5,
                color: Color(0xFF4C6656),
                height: 1.35,
              ),
            ),

            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text(
                  'Tutup',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _beliLagi(Map<String, dynamic> trx) async {
    final List items = (trx['items'] is List) ? trx['items'] : [];
    if (items.isEmpty) return;

    int addedCount = 0;
    for (final rawItem in items) {
      if (rawItem is! Map) continue;
      final stok = int.tryParse('${rawItem['stok_saat_ini'] ?? 0}') ?? 0;
      if (stok <= 0) continue;

      final productMap = {
        'id_product': rawItem['id_product'],
        'nama_product': rawItem['nama_product'],
        'harga': rawItem['harga_satuan'],
        'diskon_persen': rawItem['diskon_persen'] ?? 0,
        'foto': rawItem['foto'] ?? '',
        'jumlah': stok,
      };

      final ok = await CartService.tambahProduk(productMap);
      if (ok) addedCount++;
    }

    if (!mounted) return;
    if (addedCount > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HalamanKeranjang()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maaf, stok produk pada pesanan ini sedang habis.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6F3DD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.darkGreen,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGreen,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final bool isSelected = _selectedFilterIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilterIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.darkGreen
                            : AppColors.bgScreen,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.darkGreen
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isSelected
                              ? AppColors.limeAccent
                              : AppColors.darkGreen,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Transaction List
          Expanded(
            child: RefreshIndicator(
              color: AppColors.darkGreen,
              onRefresh: _fetchRiwayatTransaksi,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.darkGreen,
                      ),
                    )
                  : _errorMessage != null
                      ? ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.wifi_off_rounded,
                                    size: 48,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : _filteredList.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 120),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.receipt_long_outlined,
                                        size: 54,
                                        color: AppColors.textMuted,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Belum ada transaksi pada kategori ini',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(20),
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: ClampingScrollPhysics(),
                              ),
                              itemCount: _filteredList.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = _filteredList[index];
                                return _buildTransactionCard(item);
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> trx) {
    final String rawStatus =
        (trx['status_transaksi'] ?? 'pending').toString().toLowerCase();
    final bool isPending = rawStatus == 'pending';
    final bool isSelesai =
        rawStatus == 'settlement' || rawStatus == 'capture';

    String statusLabel = 'Dibatalkan';
    Color badgeBg = const Color(0xFFFFEBEE);
    Color badgeText = const Color(0xFFC62828);

    if (isPending) {
      statusLabel = 'Menunggu Pembayaran';
      badgeBg = const Color(0xFFFFF4E5);
      badgeText = const Color(0xFFE65100);
    } else if (isSelesai) {
      statusLabel = 'Selesai';
      badgeBg = const Color(0xFFD6F5E1);
      badgeText = const Color(0xFF1E8850);
    } else if (rawStatus == 'expire') {
      statusLabel = 'Kedaluwarsa';
    }

    final List items = (trx['items'] is List) ? trx['items'] : [];
    final firstItem =
        items.isNotEmpty ? Map<String, dynamic>.from(items.first) : null;
    final int extraItemsCount = items.length > 1 ? items.length - 1 : 0;

    final String orderId = trx['order_id']?.toString() ?? '-';
    final String tanggal = trx['tanggal_tampil']?.toString() ?? '-';
    final int totalBayar = int.tryParse('${trx['total_bayar'] ?? 0}') ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPending ? const Color(0xFFFFCC80) : AppColors.cardBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store & Status Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      size: 16,
                      color: AppColors.darkGreen,
                    ),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Bank Sampah Sahabat Ibu TR4SH',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGreen,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: badgeText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderId,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
              Text(
                tanggal,
                style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
              ),
            ],
          ),

          const Divider(height: 18, color: Color(0xFFEDF5F0)),

          // Product item row
          if (firstItem != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: (firstItem['foto'] ?? '').toString().isNotEmpty
                      ? Image.network(
                          firstItem['foto'].toString(),
                          width: 58,
                          height: 58,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 58,
                            height: 58,
                            color: AppColors.mintSoft,
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        )
                      : Container(
                          width: 58,
                          height: 58,
                          color: AppColors.mintSoft,
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: AppColors.darkGreen,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstItem['nama_product']?.toString() ?? 'Produk',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${firstItem['jumlah']} Barang • Rp ${_formatPrice(firstItem['subtotal'])}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (extraItemsCount > 0) ...[
                        const SizedBox(height: 3),
                        Text(
                          '+ $extraItemsCount produk lainnya',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E8850),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F6EE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.store_mall_directory_outlined,
                              size: 10,
                              color: Color(0xFF1E8850),
                            ),
                            SizedBox(width: 3),
                            Text(
                              'Ambil di Bank Sampah',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E8850),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          const Divider(height: 18, color: Color(0xFFEDF5F0)),

          // Total & Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    'Rp ${_formatPrice(totalBayar)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (isPending)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _lanjutkanPembayaran(trx),
                      icon: const Icon(Icons.qr_code_2_rounded, size: 14),
                      label: const Text(
                        'Lanjutkan Pembayaran',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (isSelesai) ...[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF98CCA8)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _beliLagi(trx),
                      child: const Text(
                        'Beli Lagi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _showBuktiOrderModal(trx),
                      child: const Text(
                        'Bukti Order',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ] else
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF98CCA8)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _beliLagi(trx),
                      child: const Text(
                        'Beli Lagi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(dynamic price) {
    final int p = int.tryParse(price.toString()) ?? 0;
    return p.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}