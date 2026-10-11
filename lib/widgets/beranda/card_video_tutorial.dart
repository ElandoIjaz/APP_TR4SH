import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class CardVideoTutorial extends StatefulWidget {
  final VoidCallback onPlayTap;
  final VoidCallback onSeeAllTap;
  final String duration;
  final String title;
  final String subtitle;
  final String sectionTitle;
  final String? thumbnailUrl;
  final String? author;
  final String? badgeText;

  const CardVideoTutorial({
    super.key,
    required this.onPlayTap,
    required this.onSeeAllTap,
    this.duration = '03:40 min',
    this.title = 'Panduan Pilah Sampah Rumah Tangga',
    this.subtitle = 'Langkah mudah memisahkan sampah organik & anorganik',
    this.sectionTitle = 'Cara Menabung Sampah',
    this.thumbnailUrl,
    this.author,
    this.badgeText,
  });

  @override
  State<CardVideoTutorial> createState() => _CardVideoTutorialState();
}

class _CardVideoTutorialState extends State<CardVideoTutorial> {
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & "Lihat Semua"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.sectionTitle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                ),
              ),
              InkWell(
                onTap: widget.onSeeAllTap,
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E8850),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Video Container Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail with Play Button
                GestureDetector(
                  onTap: widget.onPlayTap,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (widget.thumbnailUrl != null &&
                            widget.thumbnailUrl!.startsWith('http'))
                          Image.network(
                            widget.thumbnailUrl!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildFallbackThumbnail(),
                          )
                        else
                          _buildFallbackThumbnail(),

                        // Play Button
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.limeAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 32,
                            color: AppColors.darkGreen,
                          ),
                        ),

                        // Badge Top-Left if present
                        if (widget.badgeText != null)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.limeAccent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Text(
                                widget.badgeText!,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ),
                          ),

                        // Duration Badge
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.schedule_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.duration,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Video Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                height: 1.3,
                              ),
                            ),
                            if (widget.author != null &&
                                widget.author!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Oleh: ${widget.author}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: _isBookmarked
                              ? AppColors.darkGreen
                              : AppColors.textMuted,
                        ),
                        onPressed: () {
                          setState(() {
                            _isBookmarked = !_isBookmarked;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _isBookmarked
                                    ? 'Video ditambahkan ke bookmark!'
                                    : 'Bookmark dihapus',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
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

  Widget _buildFallbackThumbnail() {
    return Image.asset(
      'assets/images/waste_guide.jpg',
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 180,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF25664B), Color(0xFF104A34)],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.recycling_rounded,
              size: 60,
              color: Colors.white38,
            ),
          ),
        );
      },
    );
  }
}
