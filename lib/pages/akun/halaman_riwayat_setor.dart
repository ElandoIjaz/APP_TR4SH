import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/tracking/halaman_tracking.dart';

class HalamanRiwayatSetor extends StatelessWidget {
  const HalamanRiwayatSetor({super.key});

  @override
  Widget build(BuildContext context) {
    final list = UserAccountData.listRiwayatSetor;

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
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.darkGreen, size: 20),
              ),
            ),
          ),
        ),
        title: const Text(
          'Riwayat Setor Sampah',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 14),

            // ── Top Summary Metrics Card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.darkGreen,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkGreen.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'TOTAL KONTRIBUSI ANDA',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.limeAccent,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Icon(Icons.recycling_rounded, color: AppColors.limeAccent, size: 18),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricColumn(
                          (UserAccountData.isNewAccount || UserAccountData.isGuest)
                              ? '0.0 kg'
                              : (UserAccountData.totalSampahKg > 0
                                  ? '${UserAccountData.totalSampahKg.toStringAsFixed(1)} kg'
                                  : '14.8 kg'),
                          'Sampah Disetor',
                        ),
                        Container(width: 1, height: 36, color: Colors.white24),
                        _buildMetricColumn(
                          (UserAccountData.isNewAccount || UserAccountData.isGuest) ? '+0' : '+1.900',
                          'Poin Diperoleh',
                        ),
                        Container(width: 1, height: 36, color: Colors.white24),
                        _buildMetricColumn(
                          (UserAccountData.isNewAccount || UserAccountData.isGuest)
                              ? '0.0 kg'
                              : (UserAccountData.totalSampahKg > 0
                                  ? '${(UserAccountData.totalSampahKg * 1.55).toStringAsFixed(1)} kg'
                                  : '23.0 kg'),
                          'Reduksi CO2e',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Section Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  Text(
                    'Catatan Penyetoran Terverifikasi',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Deposit History Cards
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.recycling_rounded, size: 48, color: AppColors.textMuted),
                      SizedBox(height: 10),
                      Text(
                        'Belum ada riwayat setoran sampah',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Mulai setor sampah daur ulang pertamamu sekarang!',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...list.map((item) => _buildSetorCard(context, item)),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HalamanTracking()),
              );
            },
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.limeAccent, size: 20),
            label: const Text(
              'Setor Sampah Sekarang',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildSetorCard(BuildContext context, RiwayatSetorModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFD6F3DD),
                      child: const Icon(Icons.recycling_rounded, size: 18, color: AppColors.darkGreen),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.kategori,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
                        ),
                        Text(item.tanggal, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mintSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+${item.poin} Poin',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF1E8850)),
                  ),
                ),
              ],
            ),
            const Divider(height: 18, color: Color(0xFFEDF5F0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Timbangan', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    Text(
                      '${item.beratKg} kg',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Mitra Bank Sampah', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    Text(
                      item.lokasiBankSampah,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.darkGreen),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F6EE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.eco_outlined, size: 14, color: Color(0xFF1E8850)),
                  const SizedBox(width: 6),
                  Text(
                    'Dampak: ${item.estimasiCo2}',
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1E8850)),
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
