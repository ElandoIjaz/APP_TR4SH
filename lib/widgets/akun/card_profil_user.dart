import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class CardProfilUser extends StatelessWidget {
  final String name;
  final String username;
  final String status;
  final VoidCallback onEditTap;
  final String? avatarAsset;
  final bool isGuest;
  final bool isVerified;
  final String buttonText;

  const CardProfilUser({
    super.key,
    required this.name,
    required this.username,
    this.status = 'Anggota Aktif',
    required this.onEditTap,
    this.avatarAsset,
    this.isGuest = false,
    this.isVerified = true,
    this.buttonText = 'Edit Profil',
  });

  Widget _buildEmptyAvatar() {
    return Container(
      color: const Color(0xFFD6F3DD),
      alignment: Alignment.center,
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.darkGreen,
        size: 34,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with conditional verified badge (Profil Kosongan default)
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD6F3DD),
                  border: Border.all(color: const Color(0xFFBFE7CA), width: 2),
                ),
                child: ClipOval(
                  child: (avatarAsset != null && avatarAsset!.isNotEmpty && !isGuest)
                      ? Image.asset(
                          avatarAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildEmptyAvatar(),
                        )
                      : _buildEmptyAvatar(),
                ),
              ),
              if (isVerified && !isGuest)
                Positioned(
                  bottom: 0,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFF137547),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          // User details (Name, Username, Status)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.mintSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, size: 7, color: Color(0xFF1E8850)),
                      const SizedBox(width: 5),
                      Text(
                        status,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E8850),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Button (Edit Profil)
          OutlinedButton(
            onPressed: onEditTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.darkGreen,
              side: const BorderSide(color: Color(0xFF9FB9AB), width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

