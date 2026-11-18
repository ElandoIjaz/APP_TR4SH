import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class Tr4shHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool showProfile; // Opsional: Sembunyikan profil di halaman tertentu jika perlu

  const Tr4shHeader({
    super.key,
    this.showProfile = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false, // Matikan tombol back default
      title: Row(
        children: [
          // Bingkai Hijau Tua dengan Logo Baru di dalamnya
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(6), // Padding agar ikon tidak mepet
            decoration: BoxDecoration(
              color: AppColors.darkGreen, // Hijau tua dari web
              borderRadius: BorderRadius.circular(10), // Radius rounded
            ),
            child: Image.asset(
              'assets/images/logo_trash.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          // Teks TR4SH (Tanpa tanda seru)
          const Text(
            'TR4SH',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'Poppins', // Sesuaikan font jika pakai GoogleFonts
            ),
          ),
        ],
      ),
      actions: [
        if (showProfile) ...[
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              // Aksi notifikasi
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.person, size: 20, color: Colors.grey),
                // Ganti dengan NetworkImage jika user sudah login
                // backgroundImage: UserAccountData.currentAvatar.isNotEmpty
                //     ? NetworkImage(UserAccountData.currentAvatar)
                //     : null,
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}