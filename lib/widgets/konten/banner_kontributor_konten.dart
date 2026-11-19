import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class _SlideBannerData {
  final String ribbon;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String ctaText;
  final IconData heroIcon;
  final List<Color> gradientColors;
  final Color accentColor;
  final Color decorCircleColor;

  const _SlideBannerData({
    required this.ribbon,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.heroIcon,
    required this.gradientColors,
    required this.accentColor,
    required this.decorCircleColor,
  });
}

class BannerKontributorKonten extends StatefulWidget {
  final VoidCallback onBerbagiIdeTap;

  const BannerKontributorKonten({super.key, required this.onBerbagiIdeTap});

  @override
  State<BannerKontributorKonten> createState() => _BannerKontributorKontenState();
}

class _BannerKontributorKontenState extends State<BannerKontributorKonten> {
  final PageController _pageController = PageController();
  int _activeIndex = 0;

  static const List<_SlideBannerData> _slides = [
    _SlideBannerData(
      ribbon: '✦ TR4SH CREATOR CLUB',
      eyebrow: 'TERTARIK JADI KONTRIBUTOR?',
      title: 'KIRIM KONTEN ANDA',
      subtitle:
          'Jadilah Penggerak #PeduliSampah dan dapatkan EcoPoints untuk setiap karya sirkular terverifikasi.',
      ctaText: 'Mulai Berbagi Ide',
      heroIcon: Icons.auto_awesome_motion_rounded,
      gradientColors: [Color(0xFF0E4B35), Color(0xFF083523), Color(0xFF052116)],
      accentColor: AppColors.limeAccent,
      decorCircleColor: Color(0xFF28B463),
    ),
    _SlideBannerData(
      ribbon: '✦ RECYCLE • REDUCE • REUSE • RESELL',
      eyebrow: 'INSPIRASI DARI RUMAH',
      title: 'PANDUAN & KREASI 4R',
      subtitle:
          'Bagikan video tutorial, foto hasil daur ulang, atau trik mengurangi limbah harian bersama komunitas.',
      ctaText: 'Unggah Karya Sekarang',
      heroIcon: Icons.recycling_rounded,
      gradientColors: [Color(0xFF0A3E4C), Color(0xFF072B36), Color(0xFF041A22)],
      accentColor: Color(0xFF7DF9C2),
      decorCircleColor: Color(0xFF1ABC9C),
    ),
    _SlideBannerData(
      ribbon: '✦ BONUS ECOPOINTS',
      eyebrow: 'KARYA TERVERIFIKASI ADMIN',
      title: 'RAIHECOPOINTS LEBIH BANYAK',
      subtitle:
          'Konten yang jelas, bermanfaat, dan orisinal berkesempatan tampil di beranda serta menambah poinmu.',
      ctaText: 'Buat Konten Edukasi',
      heroIcon: Icons.workspace_premium_rounded,
      gradientColors: [Color(0xFF1F4E23), Color(0xFF133617), Color(0xFF091E0C)],
      accentColor: Color(0xFFE9FF57),
      decorCircleColor: Color(0xFF82E0AA),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _pindahSlide(int delta) {
    final next = (_activeIndex + delta + _slides.length) % _slides.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 244,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (idx) => setState(() => _activeIndex = idx),
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: slide.gradientColors,
                    ),
                    border: Border.all(
                      color: slide.accentColor.withValues(alpha: 0.35),
                      width: 1.3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: slide.gradientColors.first.withValues(alpha: 0.32),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Hiasan lingkaran & ikon dekoratif latar belakang
                      Positioned(
                        right: -28,
                        top: -28,
                        child: Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: slide.decorCircleColor.withValues(alpha: 0.16),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 26,
                        bottom: 54,
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: slide.accentColor.withValues(alpha: 0.22),
                              width: 1.5,
                            ),
                            color: slide.accentColor.withValues(alpha: 0.08),
                          ),
                          child: Icon(
                            slide.heroIcon,
                            color: slide.accentColor.withValues(alpha: 0.55),
                            size: 32,
                          ),
                        ),
                      ),
                      Positioned(
                        left: -18,
                        bottom: -24,
                        child: Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: slide.accentColor.withValues(alpha: 0.09),
                          ),
                        ),
                      ),

                      // Konten utama slide
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: slide.accentColor.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Text(
                                    slide.ribbon,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: slide.accentColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    _buildMiniNavIcon(
                                      icon: Icons.chevron_left_rounded,
                                      color: slide.accentColor,
                                      onTap: () => _pindahSlide(-1),
                                    ),
                                    const SizedBox(width: 4),
                                    _buildMiniNavIcon(
                                      icon: Icons.chevron_right_rounded,
                                      color: slide.accentColor,
                                      onTap: () => _pindahSlide(1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              slide.eyebrow,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: slide.accentColor,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              slide.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Text(
                                slide.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.white.withValues(alpha: 0.82),
                                  height: 1.35,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              height: 42,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: slide.accentColor,
                                  foregroundColor: AppColors.darkGreen,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 18),
                                ),
                                onPressed: widget.onBerbagiIdeTap,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_circle_rounded,
                                      size: 17,
                                      color: AppColors.darkGreen,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      slide.ctaText,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.darkGreen,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 17,
                                      color: AppColors.darkGreen,
                                    ),
                                  ],
                                ),
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
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (index) {
            final isActive = _activeIndex == index;
            return GestureDetector(
              onTap: () => _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 22 : 8,
                height: 8,
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

  Widget _buildMiniNavIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}