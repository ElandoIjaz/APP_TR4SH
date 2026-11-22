import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/tracking/halaman_tracking.dart';

class HalamanRiwayatSetor extends StatefulWidget {
  const HalamanRiwayatSetor({super.key});

  @override
  State<HalamanRiwayatSetor> createState() => _HalamanRiwayatSetorState();
}

class _HalamanRiwayatSetorState extends State<HalamanRiwayatSetor> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (UserAccountData.isGuest || UserAccountData.currentUserId == null) {
      return;
    }
    setState(() => _isLoading = true);
    await ApiService.fetchRiwayatSetor();
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final list = UserAccountData.listRiwayatSetor;
    final int totalSetoran = UserAccountData.isGuest
        ? 0
        : UserAccountData.totalSetoran;
    final double totalKg = UserAccountData.isGuest
        ? 0.0
        : UserAccountData.totalSampahKg;

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
          'Riwayat Setor Sampah',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGreen,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppColors.darkGreen,
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          child: Column(
            children: [
              const SizedBox(height: 14),

              // ── Top Summary Metrics Card (Selaras dengan Halaman Akun) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 20,
                  ),
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.recycling_rounded,
                                  color: AppColors.limeAccent,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$totalSetoran Kali',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.limeAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Frekuensi Setoran',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 38, color: Colors.white24),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${totalKg.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Total Sampah Disetor',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Section Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Catatan Penyetoran',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Deposit History Cards
              if (_isLoading && list.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.darkGreen,
                    ),
                  ),
                )
              else if (list.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.recycling_rounded,
                          size: 48,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Belum ada riwayat setoran sampah',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Mulai setor sampah daur ulang pertamamu sekarang!',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...list.map((item) => _buildSetorCard(item)),

              const SizedBox(height: 24),
            ],
          ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HalamanTracking()),
              ).then((_) => _loadData());
            },
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.limeAccent,
              size: 20,
            ),
            label: const Text(
              'Setor Sampah Sekarang',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetorCard(RiwayatSetorModel item) {
    final statusLower = item.status.toLowerCase();
    Color badgeBg = const Color(0xFFFFF4E5);
    Color badgeText = const Color(0xFFE65100);

    if (statusLower == 'disetujui') {
      badgeBg = const Color(0xFFD6F5E1);
      badgeText = const Color(0xFF1E8850);
    } else if (statusLower == 'ditolak') {
      badgeBg = const Color(0xFFFFEBEE);
      badgeText = const Color(0xFFC62828);
    }

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
                Expanded(
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFFD6F3DD),
                        child: Icon(
                          Icons.recycling_rounded,
                          size: 18,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.kategori,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkGreen,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              item.tanggal,
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
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: badgeText,
                    ),
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
                    const Text(
                      'Total Timbangan',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      '${item.beratKg} kg',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Keterangan / Mitra',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      item.lokasiBankSampah,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}