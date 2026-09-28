import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class HeaderBeranda extends StatelessWidget {
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  final String greeting;
  final String userName;

  const HeaderBeranda({
    super.key,
    required this.onNotificationTap,
    required this.onProfileTap,
    this.greeting = 'SELAMAT PAGI',
    this.userName = 'Bintang',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Top Header Bar (Logo TR4SH! & Notification) ──
        Padding(
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

              // Bell Notification Button with Dot
              GestureDetector(
                onTap: onNotificationTap,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.darkGreen,
                        size: 22,
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.limeAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Greeting & PROFILE ANDA Button ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Greeting Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF386B52),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Halo, $userName 👋',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGreen,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              // PROFILE ANDA Button
              InkWell(
                onTap: onProfileTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6F3DD),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFBFE7CA)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircleAvatar(
                        radius: 11,
                        backgroundColor: Color(0xFF88D89F),
                        child: Icon(
                          Icons.person,
                          size: 15,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      SizedBox(width: 7),
                      Text(
                        'PROFILE ANDA',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGreen,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
