import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/core/validators/konten_validator.dart';

class CardSorotanUtama extends StatefulWidget {
  final Map<String, dynamic>? item;
  final String? title;
  final String? description;
  final String? author;
  final String? category;
  final String? mediaUrl;
  final String? timeAgo;
  final VoidCallback? onPlayTap;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onShareTap;

  const CardSorotanUtama({
    super.key,
    this.item,
    this.title,
    this.description,
    this.author,
    this.category,
    this.mediaUrl,
    this.timeAgo,
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

  String get _title {
    if (widget.title != null && widget.title!.trim().isNotEmpty) return widget.title!.trim();
    if (widget.item != null && widget.item!['title'] != null && widget.item!['title'].toString().trim().isNotEmpty) {
      return widget.item!['title'].toString().trim();
    }
    return 'Edukasi Pengolahan Sampah';
  }

  String get _description {
    if (widget.description != null && widget.description!.trim().isNotEmpty) return widget.description!.trim();
    if (widget.item != null && widget.item!['description'] != null && widget.item!['description'].toString().trim().isNotEmpty) {
      return widget.item!['description'].toString().trim();
    }
    return 'Pelajari langkah praktis memilah dan mengolah sampah untuk lingkungan yang lebih asri.';
  }

  String get _author {
    if (widget.author != null && widget.author!.trim().isNotEmpty) return widget.author!.trim();
    if (widget.item != null) {
      if (widget.item!['penulis'] != null && widget.item!['penulis'].toString().trim().isNotEmpty) {
        return widget.item!['penulis'].toString().trim();
      }
      if (widget.item!['user'] != null && widget.item!['user'] is Map && widget.item!['user']['nama'] != null) {
        return widget.item!['user']['nama'].toString().trim();
      }
    }
    return 'Administrator';
  }

  String get _category {
    if (widget.category != null && widget.category!.trim().isNotEmpty) return widget.category!.trim();
    if (widget.item != null && widget.item!['jenis_edukasi'] != null && widget.item!['jenis_edukasi'].toString().trim().isNotEmpty) {
      return widget.item!['jenis_edukasi'].toString().trim();
    }
    return 'Edukasi Lingkungan';
  }

  String get _mediaUrl {
    if (widget.mediaUrl != null && widget.mediaUrl!.trim().isNotEmpty) return widget.mediaUrl!.trim();
    if (widget.item != null && widget.item!['media_url'] != null) {
      return widget.item!['media_url'].toString().trim();
    }
    return '';
  }

  String get _timeAgo {
    if (widget.timeAgo != null && widget.timeAgo!.isNotEmpty) return widget.timeAgo!;
    return 'Terbaru';
  }

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
    final thumbUrl = KontenValidator.getYoutubeThumbnail(_mediaUrl);

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
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _timeAgo,
                    style: const TextStyle(
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
                      if (thumbUrl != null && thumbUrl.startsWith('http'))
                        Image.network(
                          thumbUrl,
                          height: 195,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 195,
                            color: AppColors.darkGreen,
                            child: const Center(
                              child: Icon(Icons.videocam_rounded, size: 60, color: Colors.white),
                            ),
                          ),
                        )
                      else
                        Image.asset(
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
                                'YouTube',
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
                              '00:00',
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
                                      widthFactor: 0.65,
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
                              'Video Edukasi',
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
                      // Tag & Author Row (Safe from overflow)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD8F4E4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1B6B44),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'by: $_author',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Title
                      Text(
                        _title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGreen,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // Description
                      Text(
                        _description,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF5E7569),
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                                          color: Color(0xFF285943),
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
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 16,
                                        color: Color(0xFF285943),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'Komentar',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF285943),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Share
                          InkWell(
                            onTap: widget.onShareTap,
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.share_outlined,
                                    size: 16,
                                    color: Color(0xFF285943),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Bagikan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF285943),
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
