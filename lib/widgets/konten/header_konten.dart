import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class HeaderKonten extends StatelessWidget {
  final VoidCallback onBookmarkTap;
  final VoidCallback onNotificationTap;
  final bool hasUnreadNotification;
  final bool isBookmarked;

  const HeaderKonten({
    super.key,
    required this.onBookmarkTap,
    required this.onNotificationTap,
    this.hasUnreadNotification = true,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── TR4SH! Brand Logo ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.mintSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: AppColors.darkGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'TR4SH!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkGreen,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          // ── Right Action Buttons (Bookmark & Notification) ──
          Row(
            children: [
              // Bookmark Button
              IconButton(
                onPressed: onBookmarkTap,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(38, 38),
                ),
                icon: Icon(
                  isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  color: AppColors.darkGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 4),

              // Notification Bell with Lime Dot
              GestureDetector(
                onTap: onNotificationTap,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.darkGreen,
                        size: 24,
                      ),
                    ),
                    if (hasUnreadNotification)
                      Positioned(
                        top: 6,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.limeAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
