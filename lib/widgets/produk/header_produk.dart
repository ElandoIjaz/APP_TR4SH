import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/widgets/umum/tr4sh_brand_logo.dart';

class HeaderProduk extends StatelessWidget {
  final VoidCallback onNotificationTap;
  final VoidCallback onCartTap;
  final int cartItemCount;
  final bool adaNotifikasi;

  const HeaderProduk({
    super.key,
    required this.onNotificationTap,
    required this.onCartTap,
    this.cartItemCount = 3,
    this.adaNotifikasi = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── TR4SH! ECO MARKETPLACE Branding ──
         const Tr4shBrandLogo(subtitle: 'ECO MARKETPLACE'),

          // ── Right Action Buttons (Notification Bell & Cart / Avatar) ──
          Row(
            children: [
              // Notification Bell with Badge
              GestureDetector(
                onTap: onNotificationTap,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.darkGreen,
                        size: 24,
                      ),
                     if(adaNotifikasi)
                      Positioned(
                        top: 2,
                        right: 2,
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
              ),

              const SizedBox(width: 8),

              // Cart Button with Counter
              GestureDetector(
                onTap: onCartTap,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.mintSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.darkGreen,
                        size: 22,
                      ),
                      if (cartItemCount > 0)
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            padding: const EdgeInsets.all(3.5),
                            decoration: const BoxDecoration(
                              color: AppColors.darkGreen,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$cartItemCount',
                              style: const TextStyle(
                                color: AppColors.limeAccent,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Avatar Circle
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD6F3DD),
                  border: Border.all(
                    color: const Color(0xFFBFE7CA),
                    width: 1.5,
                  ),
                ),
                child: const ClipOval(
                  child: Center(
                    child: Icon(
                      Icons.person_rounded,
                      size: 20,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
