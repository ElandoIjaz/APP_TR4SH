import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/lokasi_service.dart';
import 'package:test23/pages/akun/halaman_pilih_lokasi_akurat.dart';

class CardAutoTrackLokasi extends StatefulWidget {
  final VoidCallback? onLocationUpdated;

  const CardAutoTrackLokasi({super.key, this.onLocationUpdated});

  @override
  State<CardAutoTrackLokasi> createState() => _CardAutoTrackLokasiState();
}

class _CardAutoTrackLokasiState extends State<CardAutoTrackLokasi> {
  bool _isRefreshing = false;

  void _refreshGpsLocation() {
    setState(() {
      _isRefreshing = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _isRefreshing = false;
        LokasiTrackingService.currentAccuracy =
            '±1.1 meter (GPS Terkunci Presisi)';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🛰️ Lokasi penjemputan sampah berhasil diperbarui via GPS!',
          ),
          backgroundColor: AppColors.darkGreen,
          duration: Duration(seconds: 1),
        ),
      );
      widget.onLocationUpdated?.call();
    });
  }

  void _showGmapsInfo() {
    final lat = LokasiTrackingService.currentLatitude;
    final lng = LokasiTrackingService.currentLongitude;
    final url = LokasiTrackingService.getGoogleMapsUrl(lat, lng);

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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F6EE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.map_rounded,
                        color: AppColors.darkGreen,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Terkoneksi Google Maps',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgScreen,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'URL Koordinat Google Maps:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    url,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF1E8850),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Koordinat: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Kurir penjemputan sampah TR4SH! akan otomatis menavigasi ke titik koordinat Google Maps ini secara presisi.',
              style: TextStyle(
                fontSize: 11.5,
                color: Color(0xFF4C6656),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Membuka tautan navigasi Google Maps...'),
                      backgroundColor: AppColors.darkGreen,
                    ),
                  );
                },
                icon: const Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: AppColors.limeAccent,
                ),
                label: const Text(
                  'Buka di Google Maps',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HalamanPilihLokasiAkurat()),
    );

    if (result != null) {
      setState(() {});
      widget.onLocationUpdated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Live Indicator & Action
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF00C853),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'AUTO-TRACK LOKASI PENJEMPUTAN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkGreen,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              InkWell(
                onTap: _isRefreshing ? null : _refreshGpsLocation,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgScreen,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD6E8DC)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _isRefreshing
                          ? const SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.8,
                                color: AppColors.darkGreen,
                              ),
                            )
                          : const Icon(
                              Icons.refresh_rounded,
                              size: 12,
                              color: AppColors.darkGreen,
                            ),
                      const SizedBox(width: 4),
                      const Text(
                        'Refresh GPS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Address & Coordinates
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6F3DD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.darkGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LokasiTrackingService.currentAddress,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Koordinat: ${LokasiTrackingService.currentLatitude.toStringAsFixed(6)}, ${LokasiTrackingService.currentLongitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF1E8850),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Accuracy & Partner Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDCEFE3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.gps_fixed_rounded,
                  size: 14,
                  color: Color(0xFF00C853),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${LokasiTrackingService.currentAccuracy} • ${LokasiTrackingService.nearestBankSampah}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF235E40),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Actions: Ubah Titik & Buka di GMaps
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFA1CCA8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _openPickLocation,
                  icon: const Icon(
                    Icons.edit_location_alt_outlined,
                    size: 14,
                    color: AppColors.darkGreen,
                  ),
                  label: const Text(
                    'Ubah Titik Lokasi',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _showGmapsInfo,
                  icon: const Icon(
                    Icons.map_outlined,
                    size: 14,
                    color: AppColors.limeAccent,
                  ),
                  label: const Text(
                    'Buka di GMaps',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
