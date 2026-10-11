import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class HalamanNotifikasi extends StatefulWidget {
  const HalamanNotifikasi({super.key});

  @override
  State<HalamanNotifikasi> createState() => _HalamanNotifikasiState();
}

class _HalamanNotifikasiState extends State<HalamanNotifikasi> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'Semua',
    'Transaksi',
    'Setor Sampah',
    'Info & Promo',
  ];

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'notif-1',
      'category': 'Transaksi',
      'icon': Icons.local_shipping_rounded,
      'title': 'Paket Daur Ulang Sedang Diantar!',
      'desc': 'Kurir Eco Express sedang menuju ke alamat Anda untuk pesanan Pot Bunga Sage Green.',
      'time': '15 menit yang lalu',
      'isRead': false,
    },
    {
      'id': 'notif-2',
      'category': 'Setor Sampah',
      'icon': Icons.check_circle_rounded,
      'title': 'Penyetoran Sampah 4.2 kg Terverifikasi',
      'desc': 'Selamat! Setoran botol plastik Anda telah dikonfirmasi. +630 EcoPoints telah ditambahkan ke akun Anda.',
      'time': 'Kemarin, 11:20 WIB',
      'isRead': false,
    },
    {
      'id': 'notif-3',
      'category': 'Info & Promo',
      'icon': Icons.local_fire_department_rounded,
      'title': 'Promo Spesial Hari Bebas Sampah',
      'desc': 'Dapatkan diskon 25% untuk semua produk upcycle rumah tangga dengan kode voucher ECOHERO-20K.',
      'time': '25 Sep 2026, 08:00 WIB',
      'isRead': true,
    },
    {
      'id': 'notif-4',
      'category': 'Setor Sampah',
      'icon': Icons.event_available_rounded,
      'title': 'Jadwal Penjemputan Sampah Dikonfirmasi',
      'desc': 'Petugas Bank Sampah akan menjemput sampah pilahan kardus di alamat Anda pukul 14.00 WIB.',
      'time': '21 Sep 2026, 09:30 WIB',
      'isRead': true,
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi ditandai telah dibaca'),
        duration: Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilterIndex == 0
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
            child: filtered.isEmpty
                ? const Center(
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
                          'Tidak ada notifikasi pada kategori ini',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    physics: const ClampingScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final notif = filtered[index];
                      final bool isRead = notif['isRead'];

                      return InkWell(
                        onTap: () {
                          setState(() {
                            notif['isRead'] = true;
                          });
                        },
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notif['title'],
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
                                            decoration: const BoxDecoration(
                                              color: AppColors.limeAccent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notif['desc'],
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF4C6656),
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      notif['time'],
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
        ],
      ),
    );
  }
}
