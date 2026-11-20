import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/main_navigation.dart';
import 'package:test23/widgets/umum/auth_required_modal.dart';

class _SampahInfoData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final String highlightLabel;
  final Color badgeBg;
  final Color badgeTextColor;
  final Color accentColor;
  final List<Color> cardGradient;
  final String description;
  final List<String> contohBenda;
  final List<String> caraSiapkan;
  final String catatanNasabah;

  const _SampahInfoData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.highlightLabel,
    required this.badgeBg,
    required this.badgeTextColor,
    required this.accentColor,
    required this.cardGradient,
    required this.description,
    required this.contohBenda,
    required this.caraSiapkan,
    required this.catatanNasabah,
  });
}

class GridJenisSampah extends StatelessWidget {
  final void Function(
    String title,
    String badge,
    String subtitle,
    String description,
    IconData icon,
  )? onCategoryTap;

  const GridJenisSampah({super.key, this.onCategoryTap});

  static const List<_SampahInfoData> _items = [
    _SampahInfoData(
      icon: Icons.water_drop_outlined,
      title: 'Plastik',
      subtitle: 'Botol & Kresek',
      badge: '100% Recyclable',
      highlightLabel: 'Favorit Setor',
      badgeBg: Color(0xFFD8F4E4),
      badgeTextColor: Color(0xFF1E8850),
      accentColor: Color(0xFF1E8850),
      cardGradient: [Color(0xFFFFFFFF), Color(0xFFF3FBF6)],
      description:
          'Sampah plastik seperti botol air mineral (PET) dan tutup botol (HDPE) bernilai tinggi. Pastikan dicuci bersih dan dikeringkan sebelum disetorkan.',
      contohBenda: [
        'Botol air minum kemasan (PET)',
        'Tutup botol & jerigen bersih (HDPE)',
        'Gelas plastik minuman yang sudah dibilas',
      ],
      caraSiapkan: [
        'Kosongkan sisa cairan lalu bilas dengan air',
        'Lepas label plastik atau tutup bila terpisah',
        'Pipihkan botol agar hemat ruang saat disetor',
      ],
      catatanNasabah:
          'Plastik bersih dan kering lebih mudah dipilah serta meminimalkan bau saat penimbangan.',
    ),
    _SampahInfoData(
      icon: Icons.wine_bar_rounded,
      title: 'Kaca',
      subtitle: 'Beling & Botol',
      badge: 'Rapuh',
      highlightLabel: 'Hati-hati Pecah',
      badgeBg: Color(0xFFE1F5FE),
      badgeTextColor: Color(0xFF0288D1),
      accentColor: Color(0xFF0288D1),
      cardGradient: [Color(0xFFFFFFFF), Color(0xFFF1F9FE)],
      description:
          'Botol kecap, sirup, dan toples kaca dapat didaur ulang tanpa batas waktu. Bungkus secara aman untuk menghindari pecahan.',
      contohBenda: [
        'Botol kaca kecap, saus, atau sirup',
        'Stoples kaca selai atau makanan',
        'Wadah kaca utuh tanpa retak tajam',
      ],
      caraSiapkan: [
        'Bilas bagian dalam dan luar hingga bersih',
        'Pisahkan tutup logam atau plastik jika ada',
        'Bungkus dengan kardus atau koran tebal agar aman',
      ],
      catatanNasabah:
          'Jangan mencampur pecahan kaca tajam tanpa pelindung karena berisiko melukai petugas.',
    ),
    _SampahInfoData(
      icon: Icons.inventory_2_outlined,
      title: 'Kertas & Karton',
      subtitle: 'Kardus & Majalah',
      badge: 'Mudah Terurai',
      highlightLabel: 'Wajib Kering',
      badgeBg: Color(0xFFE8F5E9),
      badgeTextColor: Color(0xFF2E7D32),
      accentColor: Color(0xFF2E7D32),
      cardGradient: [Color(0xFFFFFFFF), Color(0xFFF5FBF5)],
      description:
          'Kardus belanja online, koran, dan kertas HVS dapat diproses ulang menjadi pulp kertas baru. Hindari kertas yang basah atau berminyak.',
      contohBenda: [
        'Kardus paket & kotak kemasan kering',
        'Kertas HVS, buku tulis bekas, atau majalah',
        'Koran atau kertas arsip yang tidak lembap',
      ],
      caraSiapkan: [
        'Lepaskan lakban tebal atau staples jika memungkinkan',
        'Lipat kardus menjadi rata agar mudah ditumpuk',
        'Simpan di tempat kering jauh dari air atau minyak',
      ],
      catatanNasabah:
          'Kertas yang basah, berjamur, atau terkena minyak makanan biasanya menurunkan nilai setoran.',
    ),
    _SampahInfoData(
      icon: Icons.delete_outline_rounded,
      title: 'Logam / Kaleng',
      subtitle: 'Aluminium & Seng',
      badge: 'Nilai Tinggi',
      highlightLabel: 'Nilai Unggulan',
      badgeBg: Color(0xFFFFF9C4),
      badgeTextColor: Color(0xFFF57F17),
      accentColor: Color(0xFFE68A00),
      cardGradient: [Color(0xFFFFFFFF), Color(0xFFFFFDF0)],
      description:
          'Kaleng minuman soda aluminium dan kaleng makanan/susu memiliki nilai jual tertinggi di bank sampah. Pipihkan kaleng untuk menghemat tempat.',
      contohBenda: [
        'Kaleng minuman aluminium',
        'Kaleng susu kental manis atau makanan bersih',
        'Potongan logam atau seng ringan rumah tangga',
      ],
      caraSiapkan: [
        'Bilas sisa minuman atau makanan sampai bersih',
        'Tiriskan air di dalamnya hingga kering',
        'Pipihkan kaleng agar lebih ringkas dibawa',
      ],
      catatanNasabah:
          'Logam bersih cenderung punya nilai jual yang menarik—pastikan tidak ada sisa cairan di dalam kaleng.',
    ),
  ];

  void _tampilkanPanduanNasabah(BuildContext context, _SampahInfoData item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.82,
        ),
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: item.badgeBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      item.icon,
                      color: item.accentColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: item.badgeBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item.badge,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: item.badgeTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.subtitle} • ${item.highlightLabel}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                item.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF3E5449),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildPanduanBox(
                title: 'Contoh di Rumah',
                icon: Icons.home_work_outlined,
                accentColor: item.accentColor,
                bgColor: item.badgeBg.withValues(alpha: 0.45),
                points: item.contohBenda,
              ),
              const SizedBox(height: 12),
              _buildPanduanBox(
                title: 'Cara Menyiapkan Sebelum Setor',
                icon: Icons.checklist_rounded,
                accentColor: AppColors.darkGreen,
                bgColor: AppColors.bgScreen,
                points: item.caraSiapkan,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6FBF8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      size: 18,
                      color: item.accentColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.catatanNasabah,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.darkGreen,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (!UserAccountData.isLoggedIn) {
                      AuthRequiredModal.show(
                        context,
                        title: 'Fitur Setor Sampah Memerlukan Akun',
                        message:
                            'Silakan masuk atau daftar akun terlebih dahulu untuk menyetor sampah daur ulang dan mengelola saldo uang Anda.',
                        icon: Icons.recycling_rounded,
                      );
                      return;
                    }
                    MainNavigationPage.jumpToTab(context, 3);
                  },
                  child: const Text(
                    'Siap Setor',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanduanBox({
    required String title,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
    required List<String> points,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...points.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      p,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3E5449),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(
    BuildContext context,
    List<_SampahInfoData> rowItems,
  ) {
    return Row(
      children: rowItems
          .asMap()
          .entries
          .map(
            (entry) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: entry.key == 0 ? 6 : 0,
                  left: entry.key == 1 ? 6 : 0,
                ),
                child: _CategoryCard(
                  data: entry.value,
                  onTap: () => _tampilkanPanduanNasabah(context, entry.value),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pilih Jenis Sampah',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.mintSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Panduan Nasabah',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCategoryRow(context, [_items[0], _items[1]]),
          const SizedBox(height: 12),
          _buildCategoryRow(context, [_items[2], _items[3]]),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final _SampahInfoData data;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.data,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.data;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform:
            Matrix4.translationValues(0.0, _isHovered ? -6.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.03),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            hoverColor: AppColors.mintSoft.withValues(alpha: 0.25),
            splashColor: AppColors.mintSoft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: item.cardGradient,
                ),
                border: Border.all(
                  color: _isHovered
                      ? item.accentColor.withValues(alpha: 0.55)
                      : AppColors.cardBorder,
                  width: _isHovered ? 1.5 : 1.0,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: item.badgeBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          color: item.accentColor,
                          size: 19,
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: item.badgeBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.badge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: item.badgeTextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.highlightLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: item.accentColor,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: item.accentColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}