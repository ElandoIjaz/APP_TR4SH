import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class CardMenuAkun extends StatelessWidget {
  final ValueChanged<String> onMenuTap;
  final String poinReward;

  const CardMenuAkun({
    super.key,
    required this.onMenuTap,
    this.poinReward = '500 Pts',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.receipt_long_rounded,
            title: 'Riwayat Transaksi',
            onTap: () => onMenuTap('Riwayat Transaksi'),
          ),
          const Divider(
            height: 1,
            indent: 64,
            endIndent: 20,
            color: Color(0xFFEDF5F0),
          ),
          _buildMenuItem(
            icon: Icons.recycling_rounded,
            title: 'Riwayat Setor Sampah',
            onTap: () => onMenuTap('Riwayat Setor Sampah'),
          ),
          const Divider(
            height: 1,
            indent: 64,
            endIndent: 20,
            color: Color(0xFFEDF5F0),
          ),
          _buildMenuItem(
            icon: Icons.video_library_rounded,
            title: 'Konten Edukasi Saya',
            onTap: () => onMenuTap('Konten Edukasi Saya'),
          ),
          const Divider(
            height: 1,
            indent: 64,
            endIndent: 20,
            color: Color(0xFFEDF5F0),
          ),
          _buildMenuItem(
            icon: Icons.redeem_rounded,
            title: 'Poin & Hadiah',
            trailingBadge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.limeAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                poinReward,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkGreen,
                ),
              ),
            ),
            onTap: () => onMenuTap('Poin & Hadiah'),
          ),
          const Divider(
            height: 1,
            indent: 64,
            endIndent: 20,
            color: Color(0xFFEDF5F0),
          ),
          _buildMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Alamat Pengiriman',
            onTap: () => onMenuTap('Alamat Pengiriman'),
          ),
          const Divider(
            height: 1,
            indent: 64,
            endIndent: 20,
            color: Color(0xFFEDF5F0),
          ),
          _buildMenuItem(
            icon: Icons.notifications_none_rounded,
            title: 'Notifikasi',
            onTap: () => onMenuTap('Notifikasi'),
          ),
          const Divider(
            height: 1,
            indent: 64,
            endIndent: 20,
            color: Color(0xFFEDF5F0),
          ),
          _buildMenuItem(
            icon: Icons.help_outline_rounded,
            title: 'Bantuan & FAQ',
            onTap: () => onMenuTap('Bantuan & FAQ'),
          ),
          const Divider(
            height: 1,
            indent: 64,
            endIndent: 20,
            color: Color(0xFFEDF5F0),
          ),
          _buildMenuItem(
            icon: Icons.tune_rounded,
            title: 'Pengaturan Akun',
            onTap: () => onMenuTap('Pengaturan Akun'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailingBadge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.mintSoft,
              child: Icon(icon, color: AppColors.darkGreen, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E33),
                ),
              ),
            ),
            if (trailingBadge != null) ...[
              trailingBadge,
              const SizedBox(width: 8),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFB5C7BD),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
