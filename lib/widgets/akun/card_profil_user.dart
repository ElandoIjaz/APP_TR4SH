import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class CardProfilUser extends StatelessWidget {
  final String name;
  final String username;
  final String? status;
  final VoidCallback onEditTap;
  final String? avatarAsset;
  final bool isGuest;
  final bool isVerified;
  final String buttonText;

  const CardProfilUser({
    super.key,
    required this.name,
    required this.username,
    this.status,
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

  Widget _buildAvatarImage() {
    if (avatarAsset == null || avatarAsset!.isEmpty || isGuest) {
      return _buildEmptyAvatar();
    }

    if (avatarAsset!.startsWith('http://') ||
        avatarAsset!.startsWith('https://')) {
      return Image.network(
        avatarAsset!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildEmptyAvatar(),
      );
    }

    return Image.asset(
      avatarAsset!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildEmptyAvatar(),
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
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD6F3DD),
              border: Border.all(color: const Color(0xFFBFE7CA), width: 2),
            ),
            child: ClipOval(child: _buildAvatarImage()),
          ),

          const SizedBox(width: 14),

          // Nama & Username (tanpa lencana dummy Anggota Aktif)
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
                const SizedBox(height: 3),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Tombol Edit Profil
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