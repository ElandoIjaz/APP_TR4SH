import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test23/core/api_config.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/akun/halaman_riwayat_transaksi.dart';

class HalamanNotifikasi extends StatefulWidget {
  const HalamanNotifikasi({super.key});

  @override
  State<HalamanNotifikasi> createState() => _HalamanNotifikasiState();
}

class _HalamanNotifikasiState extends State<HalamanNotifikasi> {
  static const String _keyReadNotifs = 'tr4sh_read_notification_ids';

  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'Semua',
    'Transaksi',
    'Setor Sampah',
    'Info & Promo',
  ];

  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];
  Set<String> _readIds = {};

  @override
  void initState() {
    super.initState();
    _initAndLoadNotifications();
  }

  Future<void> _initAndLoadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRead = prefs.getStringList(_keyReadNotifs) ?? [];
    _readIds = savedRead.toSet();
    await _loadNotifications();
  }

  Future<void> _saveReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyReadNotifs, _readIds.toList());
  }

  Future<void> _loadNotifications() async {
    if (mounted) setState(() => _isLoading = true);

    final List<Map<String, dynamic>> loadedItems = [];

    // 1. Ambil Notifikasi Transaksi Riil (jika user sudah login)
    if (!UserAccountData.isGuest && UserAccountData.currentUserId != null) {
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
        ).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded['success'] == true && decoded['data'] is List) {
            for (final raw in decoded['data']) {
              if (raw is! Map) continue;
              final trx = Map<String, dynamic>.from(raw);
              final status = (trx['status_transaksi'] ?? 'pending')
                  .toString()
                  .toLowerCase();
              final orderId = trx['order_id']?.toString() ?? '-';
              final totalBayar = trx['total_bayar'] ?? 0;
              final waktu = trx['tanggal_tampil']?.toString() ?? '-';
              final notifId = 'trx-$orderId-$status';

              String title;
              String desc;
              IconData icon;

              if (status == 'pending') {
                title = 'Menunggu Pembayaran ($orderId)';
                desc =
                    'Segera selesaikan pembayaran sebesar Rp ${_formatPrice(totalBayar)} sebelum batas waktu 15 menit berakhir.';
                icon = Icons.access_time_filled_rounded;
              } else if (status == 'settlement' || status == 'capture') {
                title = 'Pembayaran Berhasil ($orderId)';
                desc =
                    'Pesanan lunas! Silakan ambil produk Anda di Bank Sampah Sahabat Ibu TR4SH dengan menunjukkan No. Order.';
                icon = Icons.check_circle_rounded;
              } else {
                title = 'Pesanan Kedaluwarsa / Dibatalkan ($orderId)';
                desc =
                    'Transaksi $orderId sebesar Rp ${_formatPrice(totalBayar)} telah dibatalkan atau melewati batas waktu pembayaran.';
                icon = Icons.cancel_rounded;
              }

              loadedItems.add({
                'id': notifId,
                'category': 'Transaksi',
                'icon': icon,
                'title': title,
                'desc': desc,
                'time': waktu,
                'isRead': _readIds.contains(notifId),
              });
            }
          }
        }
      } catch (_) {
        // Tetap lanjutkan memuat broadcast jika riwayat transaksi gagal dimuat
      }
    }

    // 2. Ambil Notifikasi Info & Promo dari Broadcast Admin (/api/broadcast)
    try {
      final broadcastRes = await ApiService.fetchBroadcast();
      if (broadcastRes.success && broadcastRes.data is List) {
        for (final raw in broadcastRes.data) {
          if (raw is! Map) continue;
          final b = Map<String, dynamic>.from(raw);
          final idBroadcast = b['id_broadcast']?.toString() ?? '0';
          final notifId = 'promo-$idBroadcast';

          loadedItems.add({
            'id': notifId,
            'category': 'Info & Promo',
            'icon': Icons.campaign_rounded,
            'title': b['judul']?.toString() ?? 'Info & Promo TR4SH',
            'desc': b['pesan']?.toString() ?? '',
            'time': _formatIsoDate(b['dikirim_pada']?.toString()),
            'isRead': _readIds.contains(notifId),
          });
        }
      }
    } catch (_) {}

    // 3. Bagian Notifikasi Setor Sampah
    // (Disiapkan untuk diintegrasikan oleh rekan tim dari endpoint /api/sampah/riwayat)

    if (!mounted) return;
    setState(() {
      _notifications = loadedItems;
      _isLoading = false;
    });
  }

  Future<void> _markAllAsRead() async {
    if (_notifications.isEmpty) return;
    setState(() {
      for (final n in _notifications) {
        n['isRead'] = true;
        _readIds.add(n['id'].toString());
      }
    });
    await _saveReadIds();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi ditandai telah dibaca'),
        duration: Duration(milliseconds: 800),
      ),
    );
  }

  Future<void> _onTapNotification(Map<String, dynamic> notif) async {
    final id = notif['id'].toString();
    if (!_readIds.contains(id)) {
      setState(() {
        notif['isRead'] = true;
        _readIds.add(id);
      });
      await _saveReadIds();
    }

    if (!mounted) return;
    if (notif['category'] == 'Transaksi') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HalamanRiwayatTransaksi()),
      ).then((_) => _loadNotifications());
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filtered = _selectedFilterIndex == 0
        ? _notifications
        : _notifications
            .where((n) => n['category'] == _filters[_selectedFilterIndex])
            .toList();

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
          'Notifikasi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGreen,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.done_all_rounded,
              color: AppColors.darkGreen,
            ),
            tooltip: 'Tandai Semua Dibaca',
            onPressed: _markAllAsRead,
          ),
          const SizedBox(width: 8),
        ],
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
                        horizontal: 14,
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

          // Notification List
          Expanded(
            child: RefreshIndicator(
              color: AppColors.darkGreen,
              onRefresh: _loadNotifications,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.darkGreen,
                      ),
                    )
                  : filtered.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.notifications_off_outlined,
                                    size: 54,
                                    color: AppColors.textMuted,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Belum ada notifikasi pada kategori ini',
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
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final notif = filtered[index];
                            final bool isRead = notif['isRead'] == true;

                            return InkWell(
                              onTap: () => _onTapNotification(notif),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isRead
                                      ? Colors.white
                                      : const Color(0xFFF0FAF4),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isRead
                                        ? AppColors.cardBorder
                                        : const Color(0xFFBBE5CB),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: isRead
                                          ? AppColors.mintSoft
                                          : AppColors.darkGreen,
                                      child: Icon(
                                        notif['icon'] as IconData,
                                        size: 18,
                                        color: isRead
                                            ? AppColors.darkGreen
                                            : AppColors.limeAccent,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  notif['title'].toString(),
                                                  style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: isRead
                                                        ? FontWeight.w700
                                                        : FontWeight.w900,
                                                    color: AppColors.darkGreen,
                                                  ),
                                                ),
                                              ),
                                              if (!isRead)
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppColors.limeAccent,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            notif['desc'].toString(),
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: Color(0xFF4C6656),
                                              height: 1.3,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            notif['time'].toString(),
                                            style: const TextStyle(
                                              fontSize: 10,
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
                          },
                        ),
            ),
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

  String _formatIsoDate(String? iso) {
    if (iso == null || iso.isEmpty) return 'Baru saja';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return iso;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hh:$mm WIB';
  }
}