import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class CardSorotanUtama extends StatefulWidget {
  final VoidCallback? onPlayTap;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onShareTap;

  const CardSorotanUtama({
    super.key,
    this.onPlayTap,
    this.onBookmarkTap,
    this.onCommentTap,
    this.onShareTap,
  });

  @override
  State<CardSorotanUtama> createState() => _CardSorotanUtamaState();
}

class _CardSorotanUtamaState extends State<CardSorotanUtama> {
  bool _isLiked = false;
  int _likeCount = 1420;
  bool _isBookmarked = false;

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    if (widget.onBookmarkTap != null) {
      widget.onBookmarkTap!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isBookmarked ? 'Video disimpan ke Koleksi!' : 'Dihapus dari Koleksi',
          ),
          duration: const Duration(milliseconds: 900),
          backgroundColor: AppColors.darkGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Header Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SOROTAN UTAMA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF285943),
                  letterSpacing: 0.9,
                ),
              ),
              Row(
                children: const [
                  Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '1 Menit Lalu',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Featured Video Card ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Thumbnail with Video Player UI ──
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Video Thumbnail Image
                      Image.asset(
                        'assets/images/konten_video_thumb.jpg',
                        height: 195,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to waste_guide or gradient container
                          return Image.asset(
                            'assets/images/waste_guide.jpg',
                            height: 195,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 195,
                              color: AppColors.darkGreen,
                              child: const Center(
                                child: Icon(Icons.play_circle_outline, size: 60, color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),

                      // Gradient Bottom Scrim for duration contrast
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.75),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Top-Left Badges (HD & 1080p)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.darkGreen,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'HD',
                                style: TextStyle(
                                  color: AppColors.limeAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '1080p',
                                style: TextStyle(
                                  color: AppColors.darkGreen,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Top-Right Bookmark Button
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _toggleBookmark,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                color: AppColors.darkGreen,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Center Play Button
                      GestureDetector(
                        onTap: widget.onPlayTap,
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.limeAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 34,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ),

                      // Bottom Progress & Duration Overlay
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 8,
                        child: Row(
                          children: [
                            const Text(
                              '04:12',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 3.5,
                                      color: Colors.white.withValues(alpha: 0.35),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: 0.35,
                                      child: Container(
                                        height: 3.5,
                                        color: AppColors.limeAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '12:45',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Card Details Section ──
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag & Author Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD8F4E4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Plastik • An-organik',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B6B44),
                              ),
                            ),
                          ),
                          const Text(
                            'by: Ibu Anin',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Title
                      const Text(
                        'Cara Mendaur Ulang Botol Plastik Minuman',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGreen,
                          height: 1.25,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Description
                      const Text(
                        'Pelajari langkah praktis memilah dan mengkreasikan botol untuk produk sirkular bernilai tinggi.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF5E7569),
                          height: 1.35,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Action Bar (Likes, Comments, Share)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Like
                              InkWell(
                                onTap: _toggleLike,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                        size: 17,
                                        color: _isLiked ? Colors.redAccent : const Color(0xFF285943),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${(_likeCount / 1000).toStringAsFixed(1).replaceAll('.', ',')}k',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.darkGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 14),

                              // Comment
                              InkWell(
                                onTap: widget.onCommentTap,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 16,
                                        color: Color(0xFF285943),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '238',
                                        style: TextStyle(
                                          fontSize: 12,
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

                          // Share Button
                          InkWell(
                            onTap: widget.onShareTap,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.share_outlined,
                                    size: 17,
                                    color: Color(0xFF285943),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Bagikan',
                                    style: TextStyle(
                                      fontSize: 12,
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
