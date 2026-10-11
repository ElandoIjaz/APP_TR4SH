import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/akun/halaman_pilih_lokasi_akurat.dart';

class HalamanAlamatPengiriman extends StatefulWidget {
  const HalamanAlamatPengiriman({super.key});

  @override
  State<HalamanAlamatPengiriman> createState() =>
      _HalamanAlamatPengirimanState();
}

class _HalamanAlamatPengirimanState extends State<HalamanAlamatPengiriman> {
  void _setAsPrimary(String id) {
    setState(() {
      for (var a in UserAccountData.listAlamat) {
        a.isUtama = (a.id == id);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alamat utama berhasil diperbarui!'),
        backgroundColor: AppColors.darkGreen,
        duration: Duration(milliseconds: 900),
      ),
    );
  }

  void _deleteAddress(String id) {
    setState(() {
      UserAccountData.listAlamat.removeWhere((a) => a.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alamat telah dihapus'),
        duration: Duration(milliseconds: 900),
      ),
    );
  }

  void _openAddOrEdit({AlamatModel? alamat}) async {
    final result = await Navigator.push<AlamatModel>(
      context,
      MaterialPageRoute(
        builder: (_) => HalamanPilihLokasiAkurat(initialAlamat: alamat),
      ),
    );

    if (result != null) {
      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            alamat != null
                ? 'Alamat & titik GPS berhasil diperbarui!'
                : 'Alamat baru berhasil ditambahkan!',
          ),
          backgroundColor: AppColors.darkGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = UserAccountData.listAlamat;

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
          'Alamat Pengiriman',
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
              Icons.add_location_alt_outlined,
              color: AppColors.darkGreen,
            ),
            tooltip: 'Tambah Alamat',
            onPressed: () => _openAddOrEdit(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: list.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_off_rounded,
                    size: 60,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Belum ada alamat tersimpan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _openAddOrEdit(),
                    icon: const Icon(
                      Icons.my_location_rounded,
                      color: AppColors.limeAccent,
                    ),
                    label: const Text('Tentukan Lokasi Akurat'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 14),

                  // ── GPS Accuracy Guarantee Banner ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D4330),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.limeAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.gps_fixed_rounded,
                              size: 18,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Penentuan Lokasi Akurat via GPS',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Titik pin koordinat presisi memastikan kurir TR4SH! mengantar tepat di depan pintu Anda.',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: Colors.white70,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── List of Saved Addresses ──
                  ...list.map((alamat) => _buildAddressCard(alamat)),

                  const SizedBox(height: 80),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => _openAddOrEdit(),
            icon: const Icon(
              Icons.add_location_alt_rounded,
              color: AppColors.limeAccent,
              size: 20,
            ),
            label: const Text(
              'Tambah Alamat Baru (GPS Akurat)',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard(AlamatModel alamat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: alamat.isUtama ? AppColors.darkGreen : AppColors.cardBorder,
            width: alamat.isUtama ? 1.6 : 1.2,
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
            // Top Row: Label & Status Badges
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6F3DD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    alamat.label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ),
                if (alamat.isUtama) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Utama',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.limeAccent,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                InkWell(
                  onTap: () => _openAddOrEdit(alamat: alamat),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Text(
                      'Ubah Pin / Edit',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E8850),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Penerima & Telepon
            Text(
              '${alamat.penerima} • ${alamat.telepon}',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.darkGreen,
              ),
            ),

            const SizedBox(height: 6),

            // Alamat Lengkap
            Text(
              '${alamat.alamatLengkap}, ${alamat.kota} ${alamat.kodePos}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF4C6656),
                height: 1.35,
              ),
            ),

            if (alamat.patokan.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.flag_outlined,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Patokan: ${alamat.patokan}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 10),

            // GPS Coordinates & Precision Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bgScreen,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD6E8DC)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.my_location_rounded,
                    size: 14,
                    color: Color(0xFF00C853),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Titik GPS: ${alamat.latitude.toStringAsFixed(6)}, ${alamat.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                  Text(
                    alamat.akurasiGps,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E8850),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action Buttons (Set Utama & Delete)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!alamat.isUtama) ...[
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF98CCA8)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _setAsPrimary(alamat.id),
                    child: const Text(
                      'Jadikan Alamat Utama',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Color(0xFFE53935),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _deleteAddress(alamat.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
