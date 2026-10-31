import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class MerchantCard extends StatelessWidget {
  final String namaToko;
  final String lokasiToko;

  /// Opsional. Kalau diisi, Maps langsung menunjuk titik yang tepat.
  /// Kalau kosong, Maps mencari berdasarkan teks nama toko + lokasi.
  final double? latitude;
  final double? longitude;

  const MerchantCard({
    super.key,
    required this.namaToko,
    required this.lokasiToko,
    this.latitude,
    this.longitude,
  });

  Future<void> _bukaMaps(BuildContext context) async {
    final bool punyaKoordinat = latitude != null && longitude != null;

    final Uri uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': punyaKoordinat ? '$latitude,$longitude' : '$namaToko, $lokasiToko',
    });

    bool berhasil = false;
    try {
      berhasil = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Gagal membuka Maps: $e');
    }

    if (!berhasil && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _bukaMaps(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.mintSoft,
              radius: 22,
              child: Icon(Icons.storefront_rounded, color: AppColors.darkGreen),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          namaToko,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: Color(0xFF1E8850),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          lokasiToko,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
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