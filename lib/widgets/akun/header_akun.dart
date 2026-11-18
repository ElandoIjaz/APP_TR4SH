import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/widgets/umum/tr4sh_brand_logo.dart';

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
          const Tr4shBrandLogo(subtitle: 'AKUN'),

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
