import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:test23/core/api_config.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/cart_service.dart';

class HalamanPembayaran extends StatefulWidget {
  final Map<String, dynamic> dataTransaksi;

  const HalamanPembayaran({
    super.key,
    required this.dataTransaksi,
  });

  @override
  State<HalamanPembayaran> createState() => _HalamanPembayaranState();
}

class _HalamanPembayaranState extends State<HalamanPembayaran> {
  late Timer _countdownTimer;
  late Timer _pollingTimer;
  int _secondsRemaining = 15 * 60; // 15 Menit
  bool _isChecking = false;
  bool _isLunas = false;

  @override
  void initState() {
    super.initState();
    // Ambil sisa detik aktual dari server (fallback ke 15 menit jika baru checkout)
    final dynamic sisa = widget.dataTransaksi['sisa_detik'];
    if (sisa != null) {
      _secondsRemaining = int.tryParse(sisa.toString()) ?? (15 * 60);
    }

    _startCountdown();
    // Otomatis cek status ke server tiap 5 detik
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkPaymentStatus(silent: true);
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _formattedTime {
    final int minutes = _secondsRemaining ~/ 60;
    final int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _checkPaymentStatus({bool silent = false}) async {
    if (_isLunas || _isChecking) return;
    if (!silent) setState(() => _isChecking = true);

    try {
      final orderId = widget.dataTransaksi['order_id'];
      final url = Uri.parse('${ApiConfig.baseUrl}/transaksi/cek-status/$orderId');
      final res = await http.get(url).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['is_lunas'] == true || data['status_transaksi'] == 'settlement') {
          _countdownTimer.cancel();
          _pollingTimer.cancel();
          // Kosongkan keranjang karena sudah lunas
          await CartService.kosongkanKeranjang();
          if (!mounted) return;
          setState(() {
            _isLunas = true;
            _isChecking = false;
          });
          return;
        }
      }
    } catch (_) {
      // Abaikan jika silent polling
    }

    if (!silent && mounted) {
      setState(() => _isChecking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran belum terdeteksi. Silakan selesaikan pembayaran terlebih dahulu.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    _pollingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLunas) {
      return _buildSuccessScreen();
    }

    final isQris = widget.dataTransaksi['metode'] == 'qris';
    final totalBayar = widget.dataTransaksi['total_bayar'] ?? 0;
    final orderId = widget.dataTransaksi['order_id'] ?? '-';
    final vaNumber = widget.dataTransaksi['va_number'] ?? '-';
    final qrUrl = widget.dataTransaksi['qr_url'];
    final bankName = widget.dataTransaksi['bank'] ?? 'BCA';

    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Menunggu Pembayaran',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGreen,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── 1. Timer Countdown Card ──
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFCC80)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined, color: Color(0xFFE65100), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Selesaikan Pembayaran Dalam: ',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFE65100)),
                  ),
                  Text(
                    _formattedTime,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFB71C1C),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── 2. Card Detail Pembayaran ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder, width: 1.2),
              ),
              child: Column(
                children: [
                 const Text(
                    'Total Tagihan',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${_formatPrice(totalBayar)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'No. Order: $orderId',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const Divider(height: 28, color: Color(0xFFE2EFE7)),

                  // Tampilan Khusus QRIS
                  if (isQris) ...[
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner_rounded, color: AppColors.darkGreen, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Scan QRIS untuk Bayar',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder, width: 2),
                      ),
                      child: qrUrl != null
                          ? Image.network(
                              qrUrl,
                              width: 200,
                              height: 200,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(Icons.qr_code_2, size: 180),
                            )
                          : const Icon(Icons.qr_code_2, size: 180),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Bisa discan pakai GoPay, ShopeePay, BCA, Mandiri, Dana, atau mobile banking lainnya.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ] else ...[
                    // Tampilan Khusus Virtual Account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bank Transfer ($bankName)',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.mintSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            bankName,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.bgScreen,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Nomor Virtual Account', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text(
                                vaNumber,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.darkGreen,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, color: AppColors.darkGreen),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: vaNumber));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Nomor VA disalin ke clipboard!'),
                                  duration: Duration(milliseconds: 900),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Petunjuk: Transfer tepat sesuai nominal ke nomor Virtual Account di atas sebelum batas waktu berakhir.',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.3),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Cek Status Pembayaran
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isChecking ? null : () => _checkPaymentStatus(silent: false),
                icon: _isChecking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  _isChecking ? 'Mengecek Pembayaran...' : 'Cek Status Pembayaran',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. Tampilan Layar Sukses & Pengambilan di Bank Sampah ──
  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFD6F5E1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF1E8850),
                  size: 54,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pembayaran Berhasil!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No. Order: ${widget.dataTransaksi['order_id']}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),

              // Kartu Pengambilan di Bank Sampah
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgScreen,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cardBorder, width: 1.2),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.storefront_rounded, color: AppColors.darkGreen, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Lokasi Pengambilan Barang',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
                        ),
                      ],
                    ),
                    const Divider(height: 18, color: Color(0xFFE2EFE7)),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Bank Sampah Sahabat Ibu TR4SH',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Perumahan Taman Gading, Tumpengsari, Tegal Besar, Kec. Kaliwates, Jember, Jawa Timur',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF4C6656), height: 1.35),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F6EE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 14, color: Color(0xFF1E8850)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Tunjukkan No. Order ini kepada petugas saat mengambil produk kreasi daur ulang Anda.',
                              style: TextStyle(fontSize: 10.5, color: Color(0xFF1E8850), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    // Kembali ke halaman utama / katalog produk
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Selesai & Kembali ke Beranda', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
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