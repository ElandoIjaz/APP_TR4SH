import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class HeaderAkun extends StatelessWidget {
  final VoidCallback onNotificationTap;
  final VoidCallback onSettingsTap;

  const HeaderAkun({
    super.key,
    required this.onNotificationTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo TR4SH!
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

          // Notification & Settings Icons
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.darkGreen,
                  size: 23,
                ),
                onPressed: onNotificationTap,
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.darkGreen,
                  size: 23,
                ),
                onPressed: onSettingsTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
