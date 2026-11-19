import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class _WawasanItem {
  final String badge;
  final String tag;
  final String title;
  final String summary;
  final String detail;
  final IconData icon;
  final Color badgeBg;
  final Color badgeFg;

  const _WawasanItem({
    required this.badge,
    required this.tag,
    required this.title,
    required this.summary,
    required this.detail,
    required this.icon,
    required this.badgeBg,
    required this.badgeFg,
  });
}

class SectionWawasanKomunitas extends StatelessWidget {
  final VoidCallback? onSeeAllTap;
  final VoidCallback? onCardQnATap;
  final VoidCallback? onCardKreasiTap;

  const SectionWawasanKomunitas({
    super.key,
    this.onSeeAllTap,
    this.onCardQnATap,
    this.onCardKreasiTap,
  });

  static const List<_WawasanItem> _items = [
    _WawasanItem(
      badge: 'TR4SH',
      tag: 'Tentang Platform',
      title: 'Apa itu TR4SH & Gerakan Sirkular?',
      summary:
          'TR4SH membantu warga memilah sampah, menyetor ke bank sampah, dan berbagi edukasi sirkular untuk meraih EcoPoints.',
      detail:
          'TR4SH menghubungkan edukasi lingkungan, penyetoran sampah terpilah, serta kontribusi komunitas dalam satu ekosistem. Setiap karya dan praktik baik yang terverifikasi membantu menekan timbulan sampah TPA sekaligus menambah EcoPoints.',
      icon: Icons.eco_rounded,
      badgeBg: Color(0xFFD8F4E4),
      badgeFg: Color(0xFF1B6B44),
    ),
    _WawasanItem(
      badge: 'RECYCLE',
      tag: 'Daur Ulang',
      title: 'Recycle: Mengolah Limbah Jadi Bahan Baru',
      summary:
          'Mengubah sampah seperti plastik HDPE/PET, kertas, atau logam melalui proses daur ulang menjadi produk bernilai guna.',
      detail:
          'Recycle memproses material bekas pakai menjadi bahan baku atau produk baru—misalnya mengolah tutup botol plastik menjadi tatakan gelas, pot, atau material kerajinan—sehingga ketergantungan pada sumber daya alam baru berkurang.',
      icon: Icons.autorenew_rounded,
      badgeBg: Color(0xFFD9EEFF),
      badgeFg: Color(0xFF155E9C),
    ),
    _WawasanItem(
      badge: 'REDUCE',
      tag: 'Mengurangi',
      title: 'Reduce: Mengurangi Timbulan Sejak Awal',
      summary:
          'Membatasi konsumsi barang sekali pakai dan memilih produk tahan lama agar sampah tidak menumpuk sejak sumbernya.',
      detail:
          'Reduce adalah langkah paling efektif sebelum sampah terbentuk: membawa botol minum isi ulang, menolak kemasan berlebih, dan membeli secukupnya sesuai kebutuhan harian.',
      icon: Icons.do_not_disturb_on_outlined,
      badgeBg: Color(0xFFFFF2CC),
      badgeFg: Color(0xFF8A5A00),
    ),
    _WawasanItem(
      badge: 'REUSE',
      tag: 'Menggunakan Kembali',
      title: 'Reuse: Memakai Ulang Tanpa Proses Berat',
      summary:
          'Memanfaatkan kembali wadah, botol kaca, atau kaleng untuk fungsi yang sama maupun fungsi baru secara langsung.',
      detail:
          'Reuse fokus memakai kembali barang yang masih layak tanpa harus melebur atau mengubah bentuk dasarnya secara industri—contohnya stoples kaca untuk menyimpan bumbu atau wadah kaleng untuk alat tulis.',
      icon: Icons.repeat_rounded,
      badgeBg: Color(0xFFE6E0FF),
      badgeFg: Color(0xFF4B2E9E),
    ),
    _WawasanItem(
      badge: 'RESELL',
      tag: 'Jual Kembali',
      title: 'Resell: Memberi Nilai Ekonomi Lanjutan',
      summary:
          'Menjual kembali barang layak pakai atau hasil kreasi sirkular agar tetap berputar di masyarakat dan bernilai ekonomi.',
      detail:
          'Resell memperpanjang umur pakai barang atau karya daur ulang dengan menyalurkannya kembali ke pihak yang membutuhkan, menciptakan sirkulasi ekonomi yang lebih hemat dan berkelanjutan.',
      icon: Icons.sell_outlined,
      badgeBg: Color(0xFFFFE0E6),
      badgeFg: Color(0xFF9E1B3B),
    ),
  ];

  void _bukaDetailModal(BuildContext context, _WawasanItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: item.badgeBg,
                  child: Icon(item.icon, color: item.badgeFg, size: 22),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.badgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${item.badge} • ${item.tag}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: item.badgeFg,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.detail,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF3E5449),
                height: 1.5,
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
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Mengerti',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _bukaDaftarLengkap(BuildContext context) {
    if (onSeeAllTap != null) {
      onSeeAllTap!();
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(20),
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
                  'Panduan TR4SH & Prinsip 4R',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.bgScreen,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.badge} — ${item.tag}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: item.badgeFg,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.detail,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF465A50),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 20,
                    color: AppColors.darkGreen,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Wawasan Komunitas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _bukaDaftarLengkap(context),
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Semua >',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E8850),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = _items[index];
              return InkWell(
                onTap: () {
                  if (index == 0 && onCardQnATap != null) {
                    onCardQnATap!();
                  } else if (index == 1 && onCardKreasiTap != null) {
                    onCardKreasiTap!();
                  }
                  _bukaDetailModal(context, item);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: item.badgeBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          color: item.badgeFg,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item.badgeBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.badge,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: item.badgeFg,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.tag,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.summary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF5E7569),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}