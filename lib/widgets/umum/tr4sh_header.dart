import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/akun/halaman_notifikasi.dart';
import 'package:test23/widgets/umum/auth_required_modal.dart';

class Tr4shHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool showProfile;

  const Tr4shHeader({
    super.key,
    this.showProfile = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.darkGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              'assets/images/logo_trash.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'TR4SH',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
      actions: [
        if (showProfile) ...[
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              if (!UserAccountData.isLoggedIn) {
                AuthRequiredModal.show(
                  context,
                  title: 'Notifikasi Memerlukan Akun',
                  message:
                      'Silakan masuk terlebih dahulu untuk melihat notifikasi Anda.',
                );
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HalamanNotifikasi()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.person, size: 20, color: Colors.grey),
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