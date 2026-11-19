import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class _WorkshopScheduleItem {
  final String periode;
  final String scheduleLabel;
  final String title;
  final String description;
  final String timeInfo;
  final String locationInfo;
  final String focusTag;
  final IconData icon;

  const _WorkshopScheduleItem({
    required this.periode,
    required this.scheduleLabel,
    required this.title,
    required this.description,
    required this.timeInfo,
    required this.locationInfo,
    required this.focusTag,
    required this.icon,
  });
}

class CardWorkshop extends StatefulWidget {
  final VoidCallback? onDaftarTap;
  final String? date;
  final String? title;
  final String? description;
  final String? badgeLabel;
  final String? timeInfo;
  final String? locationInfo;
  final String? quotaInfo;

  const CardWorkshop({
    super.key,
    this.onDaftarTap,
    this.date,
    this.title,
    this.description,
    this.badgeLabel,
    this.timeInfo,
    this.locationInfo,
    this.quotaInfo,
  });

  @override
  State<CardWorkshop> createState() => _CardWorkshopState();
}

class _CardWorkshopState extends State<CardWorkshop> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const List<_WorkshopScheduleItem> _schedules = [
    _WorkshopScheduleItem(
      periode: 'MINGGUAN',
      scheduleLabel: 'Setiap Minggu • Pekan Berjalan',
      title: 'KREASI LILIN DARI LIMBAH\nMINYAK JELANTAH',
      description:
          'Sesi rutin mingguan mengolah minyak jelantah rumah tangga menjadi lilin aromaterapi bernilai guna.',
      timeInfo: '09.00 - 11.30 WIB',
      locationInfo: 'Rumah Komunitas TR4SH!',
      focusTag: 'Reuse Jelantah',
      icon: Icons.local_fire_department_rounded,
    ),
    _WorkshopScheduleItem(
      periode: 'BULANAN',
      scheduleLabel: 'Awal Bulan • Rutin Tiap Bulan',
      title: 'KOMPOS ORGANIK & PILAH\nSAMPAH RUMAH TANGGA',
      description:
          'Kelas bulanan praktik memisahkan organik-anorganik, mengompos sisa dapur, dan menabung sampah bernilai.',
      timeInfo: '08.30 - 11.30 WIB',
      locationInfo: 'Bank Sampah Sahabat TR4SH',
      focusTag: 'Reduce & Recycle',
      icon: Icons.eco_rounded,
    ),
    _WorkshopScheduleItem(
      periode: 'TAHUNAN',
      scheduleLabel: 'Agenda Tahunan • Puncak Komunitas',
      title: 'FESTIVAL KARYA SIRKULAR &\nDAUR ULANG TR4SH',
      description:
          'Pameran tahunan produk daur ulang plastik, kertas, dan logam karya warga serta berbagi praktik baik pengelolaan sampah.',
      timeInfo: '08.00 - 16.00 WIB',
      locationInfo: ' Ruang Terbuka Komunitas TR4SH',
      focusTag: 'Circular Showcase',
      icon: Icons.autorenew_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.event_repeat_rounded,
                    size: 18,
                    color: AppColors.darkGreen,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Agenda Workshop TR4SH',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.mintSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Geser Jadwal',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 236,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _schedules.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final item = _schedules[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF13553D),
                      Color(0xFF0F4733),
                      Color(0xFF082B1E),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.limeAccent.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkGreen.withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -28,
                      top: -26,
                      child: Container(
                        width: 115,
                        height: 115,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.limeAccent.withValues(alpha: 0.10),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 18,
                      top: 20,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                          border: Border.all(
                            color: AppColors.limeAccent.withValues(alpha: 0.24),
                          ),
                        ),
                        child: Icon(
                          item.icon,
                          color: AppColors.limeAccent.withValues(alpha: 0.85),
                          size: 24,
                        ),
                      ),
                    ),
                    const Positioned(
                      right: -20,
                      bottom: -24,
                      child: Opacity(
                        opacity: 0.12,
                        child: Icon(
                          Icons.recycling_rounded,
                          size: 135,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.limeAccent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item.periode,
                                  style: const TextStyle(
                                    color: AppColors.darkGreen,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 12,
                                    color: AppColors.limeAccent,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    item.scheduleLabel,
                                    style: const TextStyle(
                                      color: Color(0xFFDCEEE4),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                              height: 1.22,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFD2E8DB),
                                fontSize: 11.5,
                                height: 1.35,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildInfoChip(
                                icon: Icons.schedule_rounded,
                                label: item.timeInfo,
                              ),
                              _buildInfoChip(
                                icon: Icons.location_on_outlined,
                                label: item.locationInfo,
                              ),
                              _buildInfoChip(
                                icon: Icons.label_important_outline_rounded,
                                label: item.focusTag,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_schedules.length, (index) {
            final bool isActive = _currentIndex == index;
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.darkGreen
                      : AppColors.darkGreen.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11.5,
            color: AppColors.limeAccent,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}